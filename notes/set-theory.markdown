---
title: Set Theory
description: Set theory is a branch of mathematical logic that studies sets, which informally are collections of objects
---

Basic Operations
----------------

### Subset

A set is a subset of another set if all its elements are also member of the
other set: $A \subseteq B = \forall a \in A \bullet a \in B$.

A *proper*, or *strict* subset adds the additional requirement that the sets
may not be equal:  $A \subset B = A \subseteq B \land A \neq B$.

### Intersection

An intersection represents the elements that are members of both sets: $A
\cap B = \{ x \mid x \in A \land x \in B \}$.

- $A$ and $B$ are *disjoint* if $A \cap B = \emptyset$

### Union

A union represents the elements that are members of at least one of the sets:
$A \cup B = \{ x \mid x \in A \lor x \in B \}$.

### Difference

A difference represents the elements that are members of one set, but not of
the other: $A \setminus B = \{ x \mid x \in A \land x \notin B \}$.

### Symmetric Difference

A symmetric difference represents the elements that are member of any of the
sets, but not of both: $A \triangle B = (A \setminus B)
\cup (B \setminus A) = (A \cup B) \setminus (A \cap B)$.

### Cardinality

The number of elements in the set $A$ is expressed as $\vert A \vert$.
For example, $\vert\{ 1, 2, 3 \}\vert = 3$. There also exists the
alternate notation $\#A = \vert A \vert$.

### Complement

Given a set $P \subseteq X$, the complement of $P$ is the set of all
elements of $X$ not in $P$. This is expressed as $\overline{P} = \{
x \in X \mid x \notin P \}$. Basically, if $P \subseteq X$, $P \cup
\overline{P} = X$. Also note that $\overline{P} = X \setminus P$. As an
example, if $X = \{ 1, 2, 3 \}$ and $P = \{ 1, 3 \}$, then
$\overline{P} = \{ 2 \}$.

Empty Set
---------

- No element is member of the empty set: $\forall x \bullet x \notin \emptyset
  $
- The empty set is a subset of every set: $\forall A \bullet \emptyset
  \subseteq A$
- Any universal quantification over the empty set is true: given proposition
  $P$, $\forall x \in \emptyset \bullet P$ is true

Power Set
---------

A power set is the set of all possible subsets of a set. Its defined like this:
$\wp (A) = \{ x \mid x \subseteq A \}$. Also denoted as $\mathbb{P}A$. Note
that the empty set is a member of all power sets: $\forall A \bullet \emptyset
\in \wp (A)$. Thus, the power set of the empty set is the set of the empty
set: $\wp (\emptyset) = \{ \emptyset \}$.

If a set $A$ has $n$ elements, then $\wp(A)$ has $2^{n}$
elements.

### Properties

- The power set operation is distributive over $\cap$ but not over
  $\cup$. $\wp (A \cap B) = \wp (A) \cap \wp (B)$ but $\wp (A \cup B)
  \neq \wp (A) \cup \wp (B)$

### Finite Power Set

A set containing all the finite subsets of a set $X$ is denoted as
$\mathbb{F} X$. If $X$ is a finite set, then $\mathbb{F}X =
\mathbb{P}X$.

Multi Set
---------

The multi-set (or bag) is the generalization of the concept of a set, where
multiple ocurrences of an element are permitted. For example, $[ A, A, B ]$
and $[ A, B ]$ (notice the square brackets) are equal sets, but are
considered different multi-sets.

The multiplicity of an element is the number of times an element occurs in a
multi-set. In the case of $[ A, A, B ]$, $A$ has a multiplicity of 2,
while $B$ has a multiplicity of 1.

The multi-set cardinality consists of the number of elements in the multi-set,
including duplicate ocurrences.

Notice that a set is considered a multi-set, and for any non-empty set there
are infinite multi-sets with different number of ocurrences for each of its
elements.

A multi-set can be defined as a relation that maps the elements in the bag to
positive integers denoting multiplicity.

For example, a multi-set of elements $A$, $B$, and $C$, where
multiplicity is 3, 1, and 2, respectively, can be denoted as $\{ (A, 3), (B,
1), (C, 2) \}$. Elements that are not in the multi-set are left out, rather
than mapped to a multiplicity of zero.

Augmented Set
-------------

Given set $X$, the augment set of $X$ is $X^{\perp}$, which is the union
of the given set and the *undefined* element: $X \cup \perp$.

Set Families
------------

Set families are sets of other sets. They may be indexed, such that $F = \{
A_{i} \mid i \in I \}$, where each $A_{i}$ is a set.

### Operations

- The expression $\cap F$ represents the intersection of all the sets in
  the family $F$:

It can be defined as follows: $\cap F = \{ x \mid \forall A \in F \bullet x
\in A \} = \cap_{i \in I} A_{i}$. Note that this operation is undefined if $F
= \emptyset$.

- The expression $\cup F$ represents the union of all the sets in the
  family $F$:

It can be defined as follows: $\cup F = \{ x \mid \exists A \in F \bullet x
\in A \} = \cup_{i \in I} A_{i}$.

### Properties

- **Pairwise disjoint**: A set family is pairwise disjoint if all its elements
  are disjoint: $\forall X, Y \in F \bullet X \neq Y \implies X \cap Y =
  \emptyset$

### Partitions

$F$ is a *partition* of $A$ if:

- $\cup F = A$
- $F$ is pairwise disjoint
- $\forall X \in F \bullet X \neq \emptyset$

Uniqueness Operator
-------------------

This operation allows us to refer to a single unique element of a set that
matches the given constraints. Notice that the result is undefined if the given
constraints don't result in one and only one element.

Given a finite set of different natural numbers $X$, we can obtain the
largest one as: $\mu x \in X \mid \forall y \in X \bullet x \neq y \implies x
> y$. Similarly, given the set $Person$, there is only one element that
wrote The Lord of the Rings. Such element is: $\mu p \in Person \mid \text{The Lord
of the Rings} \in books(p)$.

We might also add a term part to map the resulting element. For example:
$John = \mu p \in Person \mid \text{The Lord of the Rings} \in books(p) \bullet
firstname(p)$.

Comprehensions
--------------

A set comprehension is a handy mathematical notation to build sets based on
arbitrarily complex expressions. The general form is $\{ x \in X \mid P(x)
\}$, which defines the set of all elements of $X$ where $P$ holds.

We can add a term part to map the elements in the set. For example, given
$address(p)$ returns the address of person $p$, $\{ p \in People \mid
male(p) \bullet address(p) \}$ is the set of addresses of all the male people.

If a set comprehension has no term part, like $\{ x \in X, y \in Y \mid P(x,
y) \}$, then the type the elements in the result depends on the
comprehension's *characteristic tuple*. In this case, the set comprehension
begins with $x \in X, y \in Y$, so the characteristic tuple is $(x,
y)$, which is of type $X \times Y$.

Notice that the variables used in the characteristic tuple depend on the
variables used inside the scope of the comprehension. If we have $\{ p \in
X, q \in Y \mid P(p, q) \}$, then the characteristic tuple would be the pair
$(p, q)$.

Binary Relations
----------------

Sets of tuples where the elements in the tuple have a logical relationship.
Tuples may be expressed as $(x, y)$, or as $x \mapsto y$, known as *maplet*
notation. Given $R \subseteq A \times B$, we say $A$ and $B$ are the
*source* and *target* sets of $R$. If $A$ and $B$ are of the same type,
then the relation is homogeneous; if they are different, the relation is
heterogeneous.

The powerset of a binary relation can be expressed with a double-headed arrow:
$A \leftrightarrow B = \wp (A \times B)$.

### Cartesian Product

This operation can create binary relations from two sets consisting of all the
possible tuple combinations: $A \times B = \{ (a, b) \mid a \in A \land b
\in B \}$.

The cartesian product is distributive over $\cap$ and $\cup$: $A
\times (B \cap C) = (A \times B) \cap (A \times C)$ and $A \times (B \cup
C) = (A \times B) \cup (A \times C)$.

Also note the following equations with regards to $\cap$ and $\cup$:
$(A \times B) \cap (C \times D) = (A \cap C) \times (B \cap D)$ and $(A
\times B) \cup (C \times D) \subseteq (A \cup C) \times (B \cup D)$.

With regards to the empty set, a cartesian product of the empty set and any set
is equal to the empty set: $\forall A \bullet A \times \emptyset =
\emptyset$.

### Lifted Form

Given a relation $P \subseteq X \times Y$, the *lifted form* of $P$ is
denoted $\mathring{P} = P \cup \{ \perp \} \times Y^{\perp}$. This is
simply the original relation plus the association of the undefined element with
all the elements of the augmented target.

### Operations

Given $R \subseteq (A \times B)$, a relation from $A$ to $B$:

- **Domain**: The domain represents the set of all the elements from the left
  side of the ordered pairs: $Dom(R) = \{ a \in A \mid \exists b \in B \bullet
  (a, b) \in R\}$

- **Range**: The range represents the set of all the elements from the right
  side of the ordered pairs: $Ran(R) = \{ b \in B \mid \exists a \in A \bullet
  (a, b) \in R\}$

- **Inverse**: The relation with the ordered pairs reversed: $R^{-1} = \{
  (b, a) \in B \times A \mid (a, b) \in R \}$. This may also be expressed as
  $R^{\tilde{}}$

- **Composition**: Represents the combination of two relations where a certain
  elements from the ordered pairs are included in both relations. Given $R
  \subseteq A \times B$ and $S \subseteq B \times C$, $S \circ R = \{ (a,
  c) \in A \times C \mid \exists b \in B \bullet (a, b) \in R \land (b, c) \in
  S \}$. Basically, $(S \circ R)(x) = R(S(x))$

Note the following equation about inversing a composition: $(S \circ R)^{-1}
= R^{-1} \circ S^{-1}$.

If a certain binary relation is homogeneous, then $R^{n}$ represents the
result of composing $R$ with itself $n$ number of times. For example,
$R^{3} = R \circ R \circ R$.

Homogeneous (Binary) Relations
------------------------------

A binary relation $R$ over $A$ and $B$ where $A = B$ is called
an homogenous relation, or an *endorelation* over $A$.

The identity binary relation on $A$ is denoted as $i_{A} = \{ (a, a)
\mid a \in A \}$.

### Properties

Homogenous relations may have one or more of the following properties:

- **Reflexive**: $R$ is reflexive on $A$ if $\forall x \in A \bullet (x,
  x) \in R$. Or in terms of the identity relation: $i_{A} \subseteq R$

- **Irreflexive**: $R$ is irreflexive on $A$ if $\forall x \in A \bullet
  (x, x) \notin R$

- **Symmetric**: $R$ is symmetric on $A$ if $\forall x, y \in A \bullet
  xRy \implies yRx$. Or in terms of inverses, if $R = R^{-1}$

- **Antisymmetric**: $R$ is antisymmetric on $A$ if $\forall x, y \in A
  \bullet (xRy \land yRx) \implies x = y$

- **Asymmetric**: $R$ is asymmetric on $A$ if $\forall x, y \in A \bullet
  (x, y) \in R \implies (y, x) \notin R$

Note that if $R$ is asymmetric, then its also antisymmetric.

- **Transitive**: $R$ is transitive on $A$ if $\forall x, y, z \in A
  \bullet (xRy \land yRz) \implies xRz$. Or in terms of composition, if $R
  \circ R \subseteq R$

### Equivalence Relations

Equivalence relations are binary relations that are also *reflexive*,
*symmetric*, and *transitive*. They can be used to partition a set into
equivalence classes. In this context, an ordered pair means that the pair of
elements should be considered "equivalent."

Consider $R = \{ (a, a), (b, b), (b, c), (c, b), (c, c) \}$. This
equivalence relation tells us that $a = a$, $b = b$, $c = c$, and
$b = c$. Therefore we have the following equivalence classes:

- $[a] = \{ a \}$, given that only $a$ is equivalent to $a$
- $[b] = \{ b, c \}$, given that $b$ is equivalent to $c$ and to
  itself
- $[c] = \{ b, c \}$, given that $c$ is equivalent to $b$ and to
  itself

Given $R \subseteq A \times A$, we can obtain the equivalent class of $x
\in A$ as $[x]_{R} = \{ y \in A \mid (y, x) \in R \}$.

Notice an element is always in the set of its equivalent classes, since an
element is always equal to itself: $\forall x \in A \bullet x \in [x]_{R}$.

The set of all equivalence classes of all the elements of $A$ is called
"$A$ module $R$", denoted $A \mathbin{/} R = \{ [x]_R \mid x \in A
\}$. The resulting set family is always a partition of $A$.

### Restrictions

A binary relation can be restricted on the domain, or on the range.

A restriction on the domain means that we only consider pairs where the
left-side element is a member of a certain set. Given $R = X \times Y$ and
$Z \subseteq X$, the domain restriction of $R$ by $Z$ equals $\{
(x, y) \in R \mid x \in Z \}$. This can be noted as $Z \triangleleft R$.

Similarly, a restriction on the range means that we only consider pairs where
the right-side element is a member of a certain set. Given $R = X \times Y$
and $P \subseteq Y$, the range restriction of $R$ by $P$ equals
$\{ (x, y) \in R \mid y \in P \}$. This can be noted as $R
\triangleright P$.

We can use restrictions to exclude a list of pairs from a binary relation,
which is called domain or range substraction (or anti-restriction).  Following
the above examples, we can exclude all pairs whose left-side element is in
$Z$ by doing $(X \setminus Z) \triangleleft R$, or we can exclude all
pairs whose right-side element is in $P$ by doing $R \triangleright (Y
\setminus P)$. These restrictions can also be expressed as $Z ⩤ R$ and
$R ⩥ P$, respectively.

### Relational Image

The relation image of a binary relation $R \subseteq A \times B$ by a set
$P \subseteq A$ is the range of the domain restriction of $R$ by
$P$: $R(\vert P \vert) = range(P \triangleleft R)$. In other words, the
relation image would be the set of all the results of function $R$ where
the argument is a subset of $P$.

### Closures

The closure of a relation $R$ is the smallest relation containing $R$
that satisfies a certain propery. For example, if $R$ is an homogeneous
relation, then $R^{r} = R \cup i_{R}$ represents the reflexive closure of
$R$. If $R = R^{r}$, then we say $R$ is its own reflexive closure.
Similarly, we can represent the symmetric closure of $R$ as $R^{s} = R
\cup R^{-1}$

The transitive closure of an homogeneous relation is determined by composing
the relation with itself enough times until the final relation stops growing.
The union of all finite iterations of $R$ is formally defined as $R^{+} =
\cup\{ n \in \mathbb{N} \mid n \geq 0 \bullet R^{n} \}$, which is the
transitive closure of $R$, the smallest transitive relation containing $R$.

For example, consider $R = \{ (a, b), (b, c), (c, d) \}$. $R^{1} =
R$, $R^{2} = \{ (a, b), (b, c), (b, d), (a, c), (c, d) \}$, and
$R^{3} = \{ (a, b), (b, c), (a, d), (b, d), (a, c), (c, d) \}$. But at
this point, $R^{4} = R^{3}$, $R^{5} = R^{3}$, and so on. Therefore,
$R^{+} = R^{3}$, which is the transitive closure of $R$.

Finally, the reflexive transitive closure of an homogeneous relation $R$ is
defined as $R^{*} = R^{+} \cup i_{R}$.

Given a set, such as $\mathbb{Z}$, and an operation, such as
multiplication, we say that a set is *closed under an operation* if for all
elements $x$ and $y$ from the set, the result of the operation (such as
$x * y$), is already a member of the set.
