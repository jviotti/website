---
title: Backend Development
description: Various notes on backend development and data system
---

Glossary
--------

- **Failure**: when the system stops providing the service to the user (i.e. a
  fault can cause a failure)
- **Faults**: a component of the system deviating from its spec
- **Fault-tolerant (or resilient) system**: a system that anticipates faults
  and copes with them

Performance Metrics
-------------------

**Load parameters** are sets of metrics to describe the load of a system
(specific to the actual application).

Different systems may have different types of performance.

### Throughput

> The number of records that can be processed in X amount of time.

### Response-time

> The time between a client sending a request and receiving a response.

We should measure response-time using percentiles rather than averages, as the
latter doesn't tell us how many users experienced a delay.

In order to calculate percentiles, take a list of the response-times, sort them
from fastest to slowest, and check the element at the Xth percentile. For
example, if the 95th percentile response time is 1.5 seconds, that means 95 out
of 100 requests take less than 1.5 seconds, and 5 out of 100 requests take 1.5
seconds or more.

The chances of getting a slow response-time increases if the same user performs
multiple calls to the service. This is called **tail latency amplification**.

Data Models
-----------

The structure of the application data should determine the best data model.

| Model      | Locality | One-to-many | Many-to-one | Many-to-many | Schema flexibility | Evolvability |
|------------|----------|-------------|-------------|--------------|--------------------|--------------|
| Relational | Bad      | Good        | Good        | Good         | Bad                | Bad          |
| Document   | Good     | Great       | Bad         | Bad          | Good               | Good         |
| Graph      | Bad      | Good        | Good        | Great        | Great              | Great        |

In the relational model, rows usually can't contain nested structures, but the
model has great support for various types of relationships through joins.
Locality is the compromise, as the database needs to potentially look at many
tables to resolve all foreign keys.

The document model provides poor support for foreign keys, necessary to model
many-to-one and many-to-many relationships. In this model, documents may point
to other documents using their unique identifiers, and such relationship is
resolved through follow-up queries. Support for joins is usually not well
supported.

The document model provides better locality, as all the relevant information is
usually located in one place, and therefore can be accessed with one query.
Locality is preserved on one-to-many relationships, as documents may contain
array of other elements, or other nested structures. Keep in mind that document
databases need to load up the whole document before allowing you to read or
write any property, which can be wasteful on large documents if you only need
to access a subset of it.

If the data is expected to change over time, a schemaless document model
provides an advantage, as the application code can simply start inserting
documents with the new structure, and add extra code to deal with the legacy
structures. In the relational model, we would need to write plan and write data
migrations.

The graph model excels when we have many-to-many relationships are very common
in the application.

Data Storage
------------

### Logs Segments + Hash Indexes

Every write is appended to a log file containing all writes. This is fast, as
append I/O is constant. Each entry of the log contains the record's unique
identifier and all the record properties at that time.

Searching through the log is an O(n) operation, so we create a hash map data
structure that maps unique identifiers to offsets in the log file (an index).
Whenever we append to the log file, we update the hash map to point to the
right offsets. Indexes may speed up certain read queries, but every index slows
down writes, as the indexes data structures need to be updated on every write.

The log file can keep growing forever, so we break the log into segments of a
certain size. Once the current segment reaches such size, we close the file and
start appending to a new segment. Every segment has its own key-to-offset hash
map. In order to search for a key, we start with the current segment. If we
don't find they key, we continue searching in the older segment, and so forth.

In order to delete a key, we append a special deletion record called a
*tombstone* to the current segment. The compacting/merging process will then
find the tombstone, and discard previous values of the deleted key.

Then we have a separate process that periodically *compacts* and *merges* the
segments by throwing away duplicate keys, and always preserving the latest one.
The segments are never updated in-place. The compaction process creates new
segments, and the database can continue serving requests from the current
segments, and switch to the compacted ones once they are ready.

There is usually only one writer process appending to the segments, while many
processes can read from them at the same time.

The main limitation is that range queries are not efficient.

### SSTables (Sorted String Table) + LSM-Trees (Log Structured Merge Trees)

This approach builds on *Logs Segments + Hash Indexes*. Writes are processed on
an in-memory tree data structure called a *memtable*. Once this tree reaches a
certain size, we write it out to disk as an SSTable (a sorted segment). While
the SSTable file is being written, the database can keep processing writes
using a new memtable.

In order to process a read, we search for a key in the memtable. If its not
there, we search in the next SSTable, and so forth. Because SSTables are
ordered, we don't need to keep an index data structure that covers all the
entries in the segment. We can have sparse indexes, go to one that is close
enough, and find our way from there.

We periodically run a compacting/merging process on the SSTables that ensure
that the result will remain sorted.

Because we have an in-memory tree, if the database crashes, all writes not
saved to an SSTable are lost. Therefore we also keep an unordered append file
whose only task is to help the database recover from crashes. Everytime a
memtable is written to disk, the log file can be discarded.

This approach offers efficient range queries and high write throughput.

SSTables and LSM-Trees are usually faster than B-Trees for writes, but slower
on reads.

A big downside is that the compacting/merging process can interfere with the
database's performance. B-trees are more predictable in this regard.

### B-Trees

B-Trees are tree data structures consisting of fixed-size blocks called
*pages*. Each page is a sorted key-value data structure that can point to
values or to other pages. The amount of references a page has to other pages is
called the *branching factor*. One of the pages is considered to be the root of
the B-tree.

If a page entry is a reference to another page, then it means that a given key
is in that referenced page if its larger or equal than the page's key, but
smaller than the subsequence page's key. For example, a page might look like this:

```
[ (100, <ref>), (200, <ref>), (300, <ref>), (400, <ref>), (500, <ref>) ]
```

If we want to find the element with a key 250, we should follow the second
reference, as 250 >= 200, and 250 < 300.

If we want to update the value of an element, we first have to find the page
containing such key. If the length of the new value is the same as the current
value, or if the page has available space, then we load the whole page, modify
it, and write it back.

If we don't have enough space, then the page is split into 2 new pages, and the
parent page is updated with the new references. This ensures the tree remains
balanced.

Since we're modifying pages in place, we can prevent data inconsistencies
during a crash by writing pages into new locations, and then doing a rename,
which is atomic.

In order to provide efficient range queries, sibling pages might be continuosly
located in disk. Also, each leaf page might contain references to its sibling
pages.

B-Trees are usually faster than SSTables and LSM-Trees for reads, but slower
for writes.

Access Patterns
---------------

### Online Transaction Processing (OLTP)

Look-up a small number of records by some key, using indexes. Records are
inserted or updated by the user's input. The data usually represents the
current point in time.

### Online Analytics Processing (OLAP)

Read a large number of records, usually just a few columns of each, and
calculate aggregates. Writes happen through big bulk imports, or streaming. The
data usually represents events over time. The dataset is usually much bigger
than when dealing with OLTP.

Data Warehousing
----------------

### Column-oriented Storage

OLAP databases usually consume a small set of columns from a large amount of
rows. All the methods discussed below handle storage at a row level, so
performing big aggregates on data can be inefficient. For these kind of
analytics databases, we might store data in a column-oriented way, where each
column of the whole table is stored in separate files.

Columns usually contain a lot of duplicate values, so they are amenable to
compression.

For performance reasons, database administrators can sort the elements of a
column-oriented database based on a particular column. Notice that we can't
re-order every column independently. We can usually specify secondary sorted
keys that keep sorting the elements within the top level sorting.

### Materialized Views

Warehousing database will be running aggregate functions over a large amount of
elements. For performance reasons, we can cache the result of certain queries
as a table-like object written to disk. Subsequent reads can use these
materialized views rather than re-running the aggregate functions on every
element from scratch every time.

### Dimensional Modelling (Star Schema)

A good way to organize the data in a warehousing database is to have a "facts"
table where each row represents an event that occured. These rows contain
mostly foreign keys to other tables called *dimension tables*, which contain
the actual information about the entities involved in the fact rows.

### Subdimensional Modelling (Snowflake Schema)

A variation of *dimensional modelling*, where the dimension tables are broken
down into subdimensions. With this approach, the data is more normalized, but
it might be harder to work with.

Replication
-----------

### Synchronous

The node that processed the writes waits until one or mode nodes replicated the
write before confirming the write with the user.

The advantage is that we can be sure that there is one or more followers with
up-to-date information, so there won't be any data loss. On the other side, if
the follower/s don't respond, the write can't be processed. Any one node that
goes node would bring the whole write-system down.

### Asynchronous

The node that processed the writes doesn't wait until one or mode nodes
replicated the write before confirming the write with the user.

If the leader fails, and the data hasn't been replicated, then the data is
lost. In the other hand, such system can keep processing writes even if all the
followers go down.

### Semi-Sychronous

An hybrid approach. Writes are replicated synchronous to a small amount of
nodes, and asynchronously to the rest.

### Guarantees

A replication system must aim to fulfil the following guarantees:

- Reading your own writes: If you write something to the system, subsequent
  reads must never ignore such write
- Monotonic reads: If a user performed a read, then no subsequent reads must
  return data from an older point in time than such read
- Consistent prefix reads: If a sequence of writes happens on a certain order,
  then anyone reading those writes should see them in the same order

### Architectures

#### Single-Leader

All writes are processed by the leader node. Data changes are streamed to the
followers. The followers apply the writes in the same order as the leader.
Clients can read from any node in the system.

#### Multi-Leader

More than one node can be a leader, and process writes. This is usually helpful
on databases with replicas across different datacenters. Leaders propagate
changes to their followers, but also reach concensus with the other leaders.
This approach can increase performance and reliability given than more than one
node can process writes.

The main problem is that conflicts might occur, so there must be a way to
resolve them.

#### Leaderless

Clients send reads and writes to many nodes in parallel. We consider reads or
writes to be successful if a certain subset of the nodes acknowledge the
request. Given N nodes, we have to pick numbers W and R of nodes to acknowledge
reads and writes, and W + R > N. This is called *quorum* reads and writes.

Every read response contains a version number, and since W + R > N, we can be
sure that the number of nodes that received a write will overlap with the
number of nodes you query, and therefore you can drop any response with an
older version number on the application's code.

Partitioning
------------

### By Key Range

Assign a contiguous range of keys to each partition. Range queries can be
effective. However, certain access patterns can lead to overload in specific
partitions. Typically, we can use dynamic partitioning if the partition gets
too big

### By Hash of Key

The dataset is more evenly distributed, but range queries become complicated.

### Scatter/Gather

Imagine that a dataset is partitioned by the key range, but we also want to
maintain a secondary index. Each partition will contain a copy of the secondary
index data structure including the elements it contains, therefore to query the
whole database using a secondary index, we will have to query every single
partition and combine the results. This is called scatter/gather.

You should try to structure partitions so that secondary index queries can be
accessed from a single partition, but this is not always possible.

We could have a global index, but then we would have to store it in one of the
nodes, which can become the bottleneck, and thus negate the benefits of
partitioning.

### Rebalancing Partitions

Partitioning by the hash of the key using `<hash> mod N`, where N is the number
of nodes, can be problematic during rebalancing, as if a node is added or
removed from the system, then large amounts of data must be moved around to
properly rebalance the partitions.

The easy fix is to create a fixed number of partitions such that the number is
greater than the number of nodes. Then, if the number of nodes change, and that
still falls within the range of configured partitions, only a minimal amount of
data needs to be moved around.

References
----------

- [Designing Data-Intensive Applications](https://www.amazon.com/dp/1449373321)
