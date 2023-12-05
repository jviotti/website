---
title: SQL
description: A collection of mostly implementation-independent notes
---

Selections (`SELECT`, `FROM`, `AS`, `DISTINCT`, `CASE`, `WHEN`, `ELSE`, `END`)
------------------------------------------------------------------------------

- Select all rows from a table `MY_TABLE`: `SELECT * FROM MY_TABLE`
- Select a particular column, `foo`, from a table `MY_TABLE`: `SELECT foo FROM
  MY_TABLE`
- Select multiple columns, `foo` and `bar`, from a table `MY_TABLE`: `SELECT
  foo, bar FROM MY_TABLE`. Notice the order doesn't need to follow the
  structure of the table. We can do `SELECT bar, foo FROM MY_TABLE` and the
  result of the query will have the columns inverted
- Select column `foo` from a table `MY_TABLE`, but return it as `bar`: `SELECT
  foo AS bar FROM MY_TABLE`
- Select column `foo` from a table `MY_TABLE`, map it with a simple expression,
  and return the result as `bar`: `SELECT foo * 5 AS bar FROM MY_TABLE`
- Select column `foo` from a table `MY_TABLE` but omit duplicates: `SELECT
  DISTINCT foo FROM MY_TABLE`. Notice `DISTINCT` applies to a single column and
  not to the whole query, thus we can do `SELECT DISTINCT foo, bar FROM
  MY_TABLE`, and `bar` will not be de-duplicated
- Select `id`, and create a column `temperature` based on columns `celsius` and
  `humid` from a table `MY_TABLE`:

```sql
SELECT id,
CASE
  WHEN celsius >= 30 OR (celsius >= 20 AND humid) THEN `HOT`
  WHEN celsius <= 10 THEN `COLD` ELSE `COOL`
END AS temperature FROM MY_TABLE
```

The `WHEN` clauses are evaluated from top to bottom, and evaluation stops on
the first match. Notice a `WHEN` or `ELSE` clause can also return `NULL`.

Filters (`WHERE`, `BETWEEN`, `IN`, `IS`, `LIKE`, `REGEXP`)
----------------------------------------------------------

- Select a column `foo` based on its value from a table `MY_TABLE`: `SELECT foo
  FROM MY_TABLE WHERE foo > 5`
- Select a column `foo` based on the value of a column `bar` from a table
  `MY_TABLE`: `SELECT foo FROM MY_TABLE WHERE (bar = 0) OR (bar > 99)`
- String literals must be enclosed in single quotes: `WHERE name = 'John'`
- Select a column `foo` from a table `MY_TABLE` based on an inclusive range:
  `SELECT foo FROM MY_TABLE WHERE foo BETWEEN 5 AND 8`. Notice this is a
  shorthand for `SELECT foo FROM MY_TABLE WHERE foo >= 5 AND foo <= 8`
- Select a column `foo` from a table `MY_TABLE` based on whether its value is
  on a set: `SELECT foo FROM MY_TABLE WHERE foo IN ('Foo', 'Bar', 'Baz')`. We
  can also negate the `IN`: `SELECT foo FROM MY_TABLE WHERE foo NOT IN ('Baz',
  'Qux')`
- Select a column `foo` from a table `MY_TABLE` based on whether its value is
  `NULL`: `SELECT foo FROM MY_TABLE WHERE foo IS NULL` or `SELECT foo FROM
  MY_TABLE WHERE foo IS NOT NULL`
- Select a string column `name` from a table `MY_TABLE` based on simple
  wildcards: `SELECT name FROM MY_TABLE WHERE name LIKE 'J%'`. These are the
  available wildcards:

| Wildcard | Description                                 |
|----------|---------------------------------------------|
| `%`      | Any number of characters, including nothing |
| `_`      | A single character                          |

Notice that the wildcard pattern must be a string literal, surrounded by single
quotes.

- Select a string column `state` from a table `MY_TABLE` based on a regular
  expression: `SELECT state FROM MY_TABLE WHERE name REGEXP '[A-Z]{2}'`. Notice
  that the regular expression is surrounded by single quotes

- Select from the results of a subquery:

```sql
SELECT NORMALIZED_PEOPLE.name
  FROM (SELECT name || ' ' || surname AS name FROM PEOPLE) AS NORMALIZED_PEOPLE
```

- Select a column using a subquery:

```sql
SELECT name, (
  SELECT count(*) FROM MESSAGE WHERE MESSAGE.to = PEOPLE.name
) AS messages FROM PEOPLE
```

- Select rows based on the result of a subquery:

```sql
SELECT name FROM PEOPLE WHERE name IN (SELECT VIPs.name FROM VIPs)
```

Orders (`ORDER`, `BY`, `ASC`, `DESC`)
-------------------------------------

- Order results based on a single column, in ascending order: `SELECT foo FROM
  MY_TABLE ORDER BY foo`. This is a shorthand for `SELECT foo FROM MY_TABLE
  ORDER BY foo ASC`

- Order results based on multiple columns: `SELECT foo, bar FROM MY_TABLE ORDER
  BY bar, foo`. We can also use `DESC` and `ASC` on each column independently:
  `SELECT foo, bar FROM MY_TABLE ORDER BY bar DESC, foo ASC`

Unions (`UNION`, `ALL`)
-----------------------

- Get the union of two queries, removing duplicates: `SELECT name FROM PEOPLE
  UNION SELECT name FROM EMPLOYEE`
- Get the union of two queries, considering duplicates: `SELECT name FROM
  PEOPLE UNION ALL SELECT name FROM EMPLOYEE`

Inserts (`INSERT`, `INTO`, `VALUES`)
------------------------------------

- Insert a single row into a table `PEOPLE`: `INSERT INTO PEOPLE (first_name,
  last_name) VALUES ('John', 'Doe')`. Notice that we don't have to define the
  schema of the whole table before `VALUES`. Any defaults will take place here
- Insert multiple rows into a table `PEOPLE`: `INSERT INTO PEOPLE (first_name,
  last_name) VALUES ('John', 'Doe'), ('Jane', 'Doe')`

Updates (`UPDATE`, `SET`)
-------------------------

- Update a single column in all rows of a table `MY_TABLE`: `UPDATE MY_TABLE
  SET email = NULL`
- Update more than one column in all rows of a table `MY_TABLE`: `UPDATE
  MY_TABLE SET flag = true, year = 2018`
- Update a column certain rows based on a filter: `UPDATE MY_TABLE SET VIP = 1
  WHERE price >= 1000`

Deletes (`DELETE`, `TRUNCATE`)
------------------------------

- Delete all the rows of a table `MY_TABLE`: `DELETE FROM MY_TABLE`. This will
  reset auto-increments, etc on SQLite
- **(NOT SUPPORTED IN SQLite)** Reset a table `MY_TABLE`, including
  auto-increments, etc: `TRUNCATE TABLE MY_TABLE`. SQLite infers this
  automatically when doing a `DELETE` without a filter
- Delete certain rows of a table `MY_TABLE` using a filter: `DELETE FROM
  MY_TABLE WHERE email IS NULL`

Indexes (`CREATE`, `INDEX`, `ON`, `UNIQUE`, `DROP`)
---------------------------------------------------

- Create a simple index named `my_index` on column `name` of a table
  `MY_TABLE`: `CREATE INDEX my_table ON MY_TABLE(name)`
- If the column we want to create an index on, for example `id` on `MY_TABLE`,
  is ensured to contain unique values (i.e. its a primary key), then we can do
  `CREATE UNIQUE INDEX my_unique_index ON MY_TABLE(id)`, and the database will
  optimize the index taking uniqueness into consideration
- Drop an index `my_index`: `DROP INDEX my_index`
- Create a composite index named `my_index` for columns `name` and `age` of a
  table `MY_TABLE`: `CREATE INDEX my_index ON MY_TABLE(name, age)`

Joins (`JOIN`, `INNER`, `OUTER`, `LEFT`, `RIGHT`, `ON`)
-------------------------------------------------------

- Do a single join between tables `CUSTOMER` and `ORDER`, discarding rows that
  don't take part in the association:

```sql
SELECT CUSTOMER.ID, ORDER.DATE
FROM CUSTOMER INNER JOIN ORDER
ON CUSTOMER.ID = ORDER.ID
```

Notice we had to write `CUSTOMER.ID` on the `SELECT` part as `ID` belongs to
both tables, and therefore the query would be ambiguous.

- Do two inner joins between `CUSTOMER`, `ORDER`, and `PRODUCT`:

```sql
SELECT CUSTOMER.ID, PRODUCT.PRICE, ORDER.DATE
FROM CUSTOMER INNER JOIN ORDER
ON CUSTOMER.ID = ORDER.ID
INNER JOIN PRODUCT
ON ORDER.PRODUCT_ID = PRODUCT.ID
```

- Do a single join between tables `CUSTOMER` and `ORDER`, considerinng
  `CUSTOMER` rows that don't take part in the association:

```sql
SELECT CUSTOMER.ID, ORDER.DATE
FROM CUSTOMER LEFT JOIN ORDER
ON CUSTOMER.ID = ORDER.ID
```

The only difference is `LEFT JOIN` instead of `INNER JOIN`. If a customer
didn't place any order, then any column from `ORDER` we select is going to be
null.

- **(NOT SUPPORTED IN SQLite)** We can use `RIGHT JOIN` to do the same as a
  `LEFT JOIN`, but preserving rows from the right part of the join
- **(NOT SUPPORTED IN SQLite)** We can use `OUTER JOIN` to do the same as a
  combined `LEFT JOIN` and `RIGHT JOIN`, preserving rows from both tables

Tables
------

The skeleton command to create a table is:

```sql
CREATE TABLE <name> (
  <column1> <type> <constraints...>,
  <column2> <type> <constraints...>,
  <column3> <type> <constraints...>
)
```

Some of the main supported types are:

- `INTEGER`
- `BOOLEAN`
- `TEXT`
- `REAL`

Some of the main constraints are:

| Structure | Description |
|-----------|-------------|
| `PRIMARY KEY` | The column is a primary key (there can be more than one) |
| `AUTOINCREMENT` | The column value will increment automatically |
| `NOT NULL` | This column can never be `NULL` |
| `DEFAULT(value)` | Set a default value for the column. If the type is `BOOLEAN`, use `DEFAULT(1)` and `DEFAULT(0)` for `true` and `false`, respectively |
| `REFERENCES table (column)` | A foreign key to column `column` from table `table` |

To drop a table `MY_TABLE`, use `DROP TABLE MY_TABLE`.

Views (`CREATE`, `VIEW`, `AS`)
------------------------------

A *view* is a pre-packaged `SELECT` operation that can be referred to as if it
was a real table.

- Create view named `MY_VIEW` out of a simple filter on `MY_TABLE`: `CREATE
  VIEW MY_VIEW AS SELECT * FROM MY_TABLE WHERE id % 2 = 0`. We can then do
  operations using `FROM MY_VIEW`

Transactions (`BEGIN`, `TRANSACTION`, `COMMIT`)
-----------------------------------------------

A utility to execute more than one SQL statement atomically. The skeleton to create a transaction is:

```sql
BEGIN TRANSACTION
<statement1>;
<statement2>;
<statement3>;
<statementN>;
COMMIT;
```

For example:

```sql
BEGIN TRANSACTION
UPDATE ACCOUNTS SET balance = balance - 1000 WHERE ACCOUNT_ID = 123;
UPDATE ACCOUNTS SET balance = balance + 1000 WHERE ACCOUNT_ID = 456;
COMMIT;
```

Notice that its required to end every statement with a semicolon.

Aggregations
------------

Here are some of the most common aggregation functions. As a rule of thumb,
aggregate functions never consider null values in their computations.

| Name | Arguments | Description |
|------|-----------|-------------|
| `COUNT(column)` | Any column, or `*` | Count the number of non `NULL` occurences of a column, or the number of returned records if the column is `*` |
| `SUM(column)` | A number column | Sum all the selected values from the column |
| `MIN(column)` | A number column | The lowest instance of the selected values from the column |
| `MAX(column)` | A number column | The highest instance of the selected values from the column |
| `AVG(column)` | A number column | The average of the selected values from the column |

For example: `SELECT AVG(temperature) AS average_temperature FROM MY_TABLE 
WHERE year >= 2000`. Notice we always rename aggregation columns, otherwise the
name will literally be the aggregation formula, i.e. `AVG(temp)`.

### Grouping

- Group an aggregation by a single column: `SELECT year, COUNT(*) AS count FROM
  MESSAGE WHERE destination = 'johndoe@test.com' GROUP BY year`. In this case,
  we will go through all unique values of `year`, and for each of those, count
  the number of messages sent to John Doe. The result will look like this:

| year | count |
|------|-------|
| 2015 | 36    |
| 2016 | 58    |
| 2017 | 54    |

- Group an aggregation by two columns: `SELECT year, month, COUNT(*) AS count
  FROM MESSAGE WHERE destination = 'johndoe@example.com' GROUP BY year, month`.
  This will consider the unique valid combinations of `year` and `month. The
  result will look like this:

| year | month | count |
|------|-------|-------|
| 2015 | jan   | 4     |
| 2015 | feb   | 6     |
| 2015 | mar   | 5     |
| 2015 | apr   | 6     |

The `GROUP BY` keyword also accepts *ordinal positions*. For example:

```sql
SELECT year, month, COUNT(*) AS count
FROM MESSAGE
WHERE destination = 'johndoe@example.com'
GROUP BY 1, 2
```

And in this case `1` and `2` match to `year` and `month`, respectively, based
on the `SELECT` operation from above.

### Filtering

We can't filter over aggregated columns using `WHERE`. This is invalid:

```sql
SELECT year, SUM(precipitation) as total_precipitation
FROM station_data 
GROUP BY year 
WHERE total_precipitation > 30
```

We have to instead use `HAVING`, which is a variant of `WHERE` that works with
aggregates:

```sql
SELECT year, SUM(precipitation) as total_precipitation
FROM station_data 
GROUP BY year 
HAVING total_precipitation > 30
```

### Mapping

We can use `CASE` expression inside aggregates. Notice we need to add the `END`
keyword after each `CASE` expression.

```sql
SELECT year
	SUM(CASE WHEN has_precipitation THEN precipitation ELSE 0 END) AS total_precipitation
FROM MY_TABLE GROUP BY year
```

Utility Functions
-----------------

| Name                       | Arguments              | Return Value | Description |
|----------------------------|------------------------|--------------|-------------|
| `round(num, decimals)`     | A float and an integer | A rounded version of the float | Round the float to X number of decimals |
| `length(string)`           | A string               | An integer   | Get the length of a string |
| `coalesce(value, default)` | Any for both           | Either the value or the default | Return `default` if `value` is `NULL`, or `value` otherwise |
| `string || string`         | Two strings            | Concatenated string | An infix function to concatenate strings |

SQLite Commands
---------------

- `sqlite <db>`: Open a database (it can be a new file) with the CLI
- `.tables`: List available tables
- `.schema <table>`: Print the schema of a table
- `.quit`: Exit for the CLI REPL
