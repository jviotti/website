---
title: Graph Theory
description: Graph theory is the study of mathematical structures used to model relations between objects
---

Undirected Graphs
-----------------

An undirected graph is defined as a tuple containing a set of vertices and a
set of edges, where the vertices correspond to the graph nodes, and the edges
correspond to the connections between them.

For example: $(\{ A, B, C \}, \{ \{ A, B\}, \{ A, C \} \})$ is a
graph which three nodes, where A is connected to B and C.

Notice that the edges are declared by unordered sets, therefore we call these
kinds of graph *undirected*.

Undirected graphs don't have the concept of more than one edge between a set of
vertices, therefore the edges must be a set, and not a multi-set.

Given a set of vertices $V$, the set of all possible connections is denoted
as $\frac{V}{2} = \{ \{ x, y \} \mid x \in V \land y \in V \land
x \neq y \}$. Notce that given edges $E$, is must hold that $E \subseteq
\frac{V}{2}$.

### Degree

The degree of a vertex is the number of edges incident to such vertex.
Formally, $degree(u) = |\{ v \in V \mid \{ v, u \} \in E \}|$. A vertex
whose degree is 0 is called an isolated vertex.

Directed Graphs
---------------

A directed graph is similar to an undirected graph with the addition of
encoding the direction of the edges. A directed graph consists of a set of
vertices and a set of edges containing tuples instead of other sets. For
example: $(V, E)$ where $V = \{ A, B \}$ and $E = \{ (A, B) \}$
denotes a directed graph where A is connected to B, but B is not connected to
A, since $(B, A) \notin E$.

If each edge goes in both directions, then the graph is undirected.

### Degree

Directed graphs have two types of degrees. The **in-degree** of a vertex is the
number of edges *to* that vertex. The **out-degree** of a vertex is the number
of edges *from* that vertex to other vertices.

The degree if a vertex, denoted $deg(v)$, is the cardinality of its
neighborhood. Notice that given a graph with vertices $V$ and $m$ number of
edges, then $2m = \sum_{v \in V} deg(v)$.

Incidence (Neighborhoods)
-------------------------

If an edge connects vertices A and B, then we say such vertices are
*neighbors*, or *adjacent*. We also say that such edge is *incident* on A and
B. Formally, given edges $E$ and vertices $A, B \in V$, the neighborhood of
$A$ is $N(A) = \{ x \in V \mid (A, v) \in E \}$.

Self-loops
----------

An edge from a node to itself is called a self-loop.

Subgraphs
---------

A graph is a subset of another graph if its nodes and edges are subsets of the
other graph. Given graphs $G_{1} = (E_{1}, P_{1})$ and $G_{2} =
(E_{2}, P_{2})$, $G_{1}$ is a *subgraph* of $G_{2}$ if $E_{1}
\subseteq E_{2}$ and $P_{1} \subseteq P_{2}$.

Paths
-----

A path is a sequence of neighbor edges in a graph that goes from vertices A to
B. Given $(\{ A, B, C \}, \{ \{ A, B\}, \{ A, C \} \})$, a valid
path from B to C would be $\langle\{ B, A \}, \{ A, C \}\rangle$.

A path is *simple* if the starting and ending vertices are different. A
**cycle** is a path which starts and ends in the same vertex.

A path from A to B with repeated edges is called a *walk* from A to B. A *tour*
is a walk that starts and ends on the same vertex.

A walk that that uses each edge exactly once is called an Eulerian walk. If
such walk starts and ends on the same vertex, then its called an Eulerian tour.

Properties
----------

### Connected

A graph is said to be connected if there is a path between any two distinct
vertices. Notice that even a disconnected graph consists of a collection of
connected components.

### Even Degree

A graph in which all vertices have even degrees.

### Planar

A graph is planar if it can be drawn without overlapping edges.

### Complete

A complete graph contains the maximum number of edges possible. For every pair
of distinct vertices, there exists an edge between then. We say that a complete
graph is *strongly connected*. In the case of directed graphs, for every pair
of vertices $u$ and $v$ the graph contains two edges: $(u, v)$ and
$(v, u)$.

$K_{n}$ denotes the unique complete graph on $n$ vertices. The number
of edges in $K_{n}$ is $n \times \frac{(n - 1)}{2}$. The degree of any
vertex in $K_{n}$ is $|V| - 1$.

Trees
-----

A graph is a tree if it contains no cycles. A tree is a connected acyclic
graph. Its a minimally connected graph, the opposite of a complete graph, and
the most effective graph we can use to connect any set of vertices. A tree has
$|V| - 1$ number of edges. A node with a degree of 1 is called a *leave*.

Removing any single edge disconnects the graph and adding any single edge
creates a cycle.

### Rooted Trees

A rooted tree is a tree with a designated *root node*. The botton-most nodes
are called *leaves*, and the intermediate nodes are called *internal nodes*.

The depth of a tree is determined by the length of the longest path from the
root to a leaf. A tree may contain many *levels*, which are determined by the
length of every subsets of the longest path that determines the depth.

Hypercubes
----------

Hypercubes are a case of graphs that can be used to achieve strong connectivity
without an exhaustive number of edges. The number of vertices in an hypercube
is $2^{n}$. The number of edges in an n-dimension hypercube is
$n2^{n-1}$.

A line is a 1-dimension hypercube, a square of a 2-dimension hypercube, and a
cube is a 3-dimension hypercube.  Notice that in any hypercube, the vertices
have $n$ number of neighbors where $n$ equals the dimension of the
hypercube.

In the case of a 3-dimension hypercube, there are 8 vertices where each has 3
neighbors, so the graph has a total of 12 edges. A complete graph of the same
number of vertices would require 28 edges.

References
----------

- https://en.wikipedia.org/wiki/Graph_theory
- http://www.eecs70.org/static/notes/n5.html
