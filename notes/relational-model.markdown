---
title: Relational Model
description: Notes on relational model
---

Tuples
------

A tuple is an unordered set of triplets (also called *components*) consisting
of attribute names, types, and values $\{ (\alpha_1, T_1, v_1), (\alpha_2,
T_2, v_2), ..., (\alpha_i, T_i, v_i) \}$. It loosely corresponds to the
concept of a "row" in SQL. A tuple is also a functional mapping from attributes
to their respective values.

Given a tuple $S$:

- Attribute names are unique: $\vert \{ \alpha \mid (\alpha, T, v) \in S \}
  \vert = \vert S \vert$
- The values of each triplet are of the right type: $\forall (\alpha, T, v)
  \in S \bullet v \in T$

A pair $(\alpha, T)$ is an *attribute* of a tuple $S$ if the tuple has a
matching triplet: $\exists v \bullet (\alpha, T, v) \in S$. The set of all
attributes of a tuple $S$ is the *heading* of $S$.

The type of a tuple of determined by its heading. Two tuples $S_1$ and
$S_2$ are of the same type iff $heading(S_1) = heading(S_2)$.

Every subset of a tuple is also a valid tuple, including the empty set (the
zero-tuple).

### Degree (or Arity)

The arity or degree of a tuple $S$ is its set cardinality, which corresponds
to the number of triplets it contains.

Notice that the degree of a tuple $S$ is also equal to the set cardinality of
its heading: $degree(S) = \vert heading(S) \vert$.

### Equality

Two tuples $S_1$ and $S_2$ are considered equal if they share the same
heading and attribute values:

$$\begin{align}
S_1 = S_2 \iff &heading(S_1) = heading(S_2) \land \\
  &\forall (\alpha, T) \in heading(S_1) \exists v \in T \bullet (\alpha, T, v) \in S_1 \land (\alpha, T, v) \in S_2
\end{align}$$

### Zero Tuple

The unique tuple with arity zero is called the *nullary* or *zero* tuple. Its
heading is the empty set: $heading(\emptyset) = \emptyset$.

Attributes
----------

An attribute is a pair $(\alpha, T)$ where $\alpha$ is the attribute name
and $T$ corresponds to its type.

### Closure

Given a relation $R$ and a set of attributes $M \subseteq heading(R)$, the
closure $M^{+}$ of $M$ under a set of functional dependencies $S$ is the
family union of all the attributes that are *dependent* of $M$ in $S^{+}$:
$M^{+} = \bigcup \{ \alpha \mid (M \rightarrow \alpha) \in S^{+} \}$.

If $M^{+} = heading(R)$ then $M$ is a *super key* for $R$.

Headings
--------

A heading is a set of attributes $\{ (\alpha_1, T_1), (\alpha_2, T_2), ...,
(\alpha_i, T_i) \}$. The heading of a tuple $S$ determines the type of the
tuple and its equal to its set of attributes: $heading(S) = \{ (\alpha, T)
\mid (\alpha, T, v) \in S \}$.

Given a heading $H$:

- Attribute names are unique: $\vert dom(H) \vert = \vert H \vert$
- All subsets of a heading $H$ are also valid headings

Relations
---------

A relation is an object $(H, B)$ containing a *heading* and a *body* where
the body is an unordered set of *tuples* (which means no duplicates), and where
$heading(H, B) = H$ and $body(H, B) = B$. The type of a relation is
determined by the type of its heading.

Given a relation $R$:

- Each tuple's heading matches the relation heading: $\forall S \in body(R)
  \bullet heading(S) = heading(R)$
- Every subset of $body(R)$ is also a valid body

### Keys

#### Super Keys

Given a relation $R$, a set of attributes $M \subseteq heading(R)$ is a
*super key* for $R$ if all the attributes of $R$ are funtionally dependent
on $M$. More formally: $M \rightarrow heading(R)$.

In terms of candidate keys, super keys are sets of attributes that contain some
candidate key as a subset.

#### Candidate Keys

A candidate key is an *irreducible* super key. Given a relation $R$, a set of
attributes $M \subseteq heading(R)$ is a *candidate key* for $R$ it is the
minimal $M \subseteq heading(R)$ such that $M \rightarrow heading(R)$.

### Operations

#### Cardinality

The cardinality of a relation $R$ is equal to the cardinality of its body:
$\vert R \vert = \vert body(R) \vert$.

#### Degree (or Arity)

The arity or degree of a relation $R$ is equal to the arity of its heading:
$degree(R) = degree(heading(R))$.

#### Membership

Given relation $R$ and tuple $S$, we may use the set membership operator to
express that a relation contains a tuple in its body: $S \in R \iff S \in
body(R)$.

#### Equality

Two relations $R_1$ and $R_2$ are considered equal if they have the same
heading (i.e. they are of the same type) and the same body: $R_1 = R_2 \iff
heading(R_1) = heading(R_2) \land body(R_1) = body(R_2)$.

#### Subset

A relation $R_1$ is a subset of another relation $R_2$ if they have the
same type (i.e. they share the same heading) and the body of $R_1$ is a
subset of the body of $R_2$: $R_1 \subseteq R_2 \iff heading(R_1) =
heading(R_2) \land body(R_1) \subseteq body(R_2)$.

### Special Relations

#### Dum

The special relation $Dum$ contains an empty heading and an empty body:

- $heading(Dum) = \emptyset$
- $body(Dum) = \emptyset$
- $degree(Dum) = 0$

#### Dee

The special relation $Dee$ contains an empty heading and a body containing
the empty tuple, which matches the type of the empty heading:

- $heading(Dee) = \emptyset$
- $body(Dee) = \{ \emptyset \}$
- $degree(Dee) = 0$

The relation $Dee$ can only have at most the empty tuple as an element.

Functional Dependency
---------------------

Given a relation $R$ and two sets of attributes $X \subseteq heading(R)$
and $Y \subseteq heading(R)$, the functional dependency $X \rightarrow Y$
means that in $R$ the values of $Y$ are determined by the values of $X$.
The set of attributes at the left hand side of the arrow ($X$) is called the
*determinant*, and the other set of attributes ($Y$) is called the
*dependent*.

### Trivial Dependencies

A functional dependency $X \rightarrow Y$ is *trivial* if its *dependent* is
a subset of its *determinant*: $Y \subseteq X$.  For example: $\{ P, Q \}
\rightarrow \{ P \}$.

### Armstrong's Axioms (Inference Rules)

Also called *inference rules*, are a set of primary rules to infer new
functional dependencies from an existing set of functional dependencies. Given
relation $R$ and $A, B, C \subseteq heading(R)$:

- **Reflexivity**: If $B \subseteq A$, then $A \rightarrow B$
- **Augmentation**: If $A \rightarrow B$, then $(A \cup C) \rightarrow (B
  \cup C)$
- **Transitivity**: If $A \rightarrow B$ and $B \rightarrow C$, then $A
  \rightarrow C$

The following additional inference rules are derived from the primary rules:

- **Decomposition**: If $A \rightarrow (B \cup C)$, then $A \rightarrow B$
  and $A \rightarrow C$
- **Union**: If $A \rightarrow B$ and $A \rightarrow C$, then $A
  \rightarrow (B \cup C)$
- **Composition**: If $A \rightarrow B$ and $C \rightarrow D$, then $(A
  \cup C) \rightarrow (B \cup D)$
- **Self-determination**: $A \rightarrow A$

#### General Unification Theorem

The theorem states that if $A \rightarrow B$ and $C \rightarrow D$, then
$(A \cup (C \setminus B)) \rightarrow (B \cup D)$.

### Closure

The *closure of functional dependency* of a set of functional dependencies
$S$ is denoted $S^{+}$, and it corresponds to the union of $S$ and the
functional dependencies that are derived from $S$.

### Cover

Given two sets of functional dependencies $P$ and $Q$ for a given relation,
$Q$ is a *cover* for $P$ if $P^{+} \subseteq Q^{+}$.

### Equivalence

Given two sets of functional dependencies $P$ and $Q$ for a given relation,
$P$ is *equivalent* to $Q$ if $P^{+} = Q^{+}$, which means that $P$ is
a cover for $Q$ and $Q$ is a cover for $P$.

### Irreducibility

A set of functional dependencies $S$ is *irreducible* (also called *minimal*)
if and only if:

- The dependent of every functional dependency in $S$ involves only one
  attribute (has cardinality 1)
- Removing any functional dependency from $S$ affects $S^{+}$
- All the functional dependencies are *left irreducible*, which means that
  removing any attributes from their determinant affects $S^{+}$

Every set of functional dependencies has *at least* one equivalent set that is
irreducible. These sets are called *irreducible equivalents*.
