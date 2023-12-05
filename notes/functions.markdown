---
title: Functions
description: A function is a relation between a set of inputs and a set of outputs
---

A binary relation $F$ from $A$ to $B$ is a considered a function from
$A$ to $B$ if $\forall a \in A \exists ! b \in B \bullet (x, y) \in F$.  This is denoted $F : A \mapsto B$. In fact, $A \mapsto B$ is an
alternate notation for $(A, B)$, which makes the relationship between
relations and functions even clearer.

Note that a relation from $A$ to $B$ is not considered a function if it
doesn't contain one single pair for every element of $A$.

Lambda Notation
---------------

This notation allows to easily express functions $f : A \mapsto B$ whose
domain is the subset of $A$ that satisfies a certain constraint.

For example, we may express division as $(\lambda x \in \mathbb{N}; y \in
\mathbb{N} \mid y \neq 0 \circ \frac{x}{y})$. Notice the function takes two
arguments, where the divisor can't equal 0. Without lambda notation, we might
have expressed this using the following set comprehension: $\{ x \in
\mathbb{N}, y \in \mathbb{N} \mid y \neq 0 \circ (x, y) \mapsto
\frac{x}{y}\}$.

The contraint part is optional. We can define $double = (\lambda x \in
\mathbb{N} \circ x + x)$.

Special Functions
-----------------

### Identity Function

The identity function of $A$ is defined as: $i_{A} = \{ (a, a) \mid a
\in A \}$.

The identity function is the only relation on $A$ that is both an
*equivalence relation* on $A$ and also a function from $A$ to $A$.

Assuming a function $f$ from $A$ to $B$ that is a one-to-one
correspondence, $f^{-1} \circ f = i_{A}$ and $f \circ f^{-1} = i_{B}$.

Also, given $g : B \mapsto A$, if $g \circ f = i_{A}$ and $f \circ g
= i_{B}$, then $g = f^{-1}$.

### Constant Function

A constant function is a function that returns the same value given any input.
$f : A \mapsto B$ is a constant function if $\exists b \in B
\forall a \in A \bullet f(a) = b$.

Special Elements
----------------

Given a function $f : (A \times A) \mapsto A$, and elements $a \in A$
and $x \in A$:

- **Identity**: The element $a$ is an identity element of $f$ if
  $f(\{ a, x \}) = x$

- **Absorbing**: The element $a$ is an absorbing element of $f$ if
  $f(\{ a, x \}) = a$

- **Inverse**: The element $a$ is an absorbing element of $f$ if
  $f(\{ a, x \})$ equals the identity element

- **Idempotent**: The element $a$ is an idempotent element of $f$ if
  $f(\{ a, a \}) = a$

In the case of multiplication, 1 is the identity and idempotent element, 0 is
the absorbing element, and $x^{-1}$ is the inverse element of $x$. In
the case of addition, 0 is the identity and idempotent element, and $-x$ is
the inverse element of $x$. There is no absorbing element in this case.

Finiteness
----------

- If the domain of a function is a finite set, then the function itself is
  finite

Properties
----------

### One-to-one (injection)

A function is *one-to-one* if no two arguments point to the same result. Given
$f : A \mapsto B$, $f$ is one-to-one if $\forall a_{1} \in A
\forall a_{2} \in A \bullet f(a_{1}) = f(a_{2}) \implies a_{1} = a_{2}$.

If two functions are one-to-one, the composition of those two functions is also
one-to-one.

Given a function $f : A \mapsto B$, if there is a function $g : B \mapsto
A$ such that $g \circ f = i_{A}$, then $f$ is one-to-one.

### Onto (surjection)

A function $f : A \mapsto B$ is *onto* if every element of $B$ is
returned by the function, which basically means that $Range(f) = B$ or more
generally, that $\forall b \in B \exists a \in A \bullet f(a) = b$.

If two functions are onto, the composition of those two functions is also onto.

Given a function $f : A \mapsto B$, if there is a function $g : B \mapsto
A$ such that $f \circ g = i_{B}$, then $f$ is onto.

### One-to-one Correspondence (bijection)

A function is a one-to-one correspondence if its both one-to-one and onto. If a
function $f : A \mapsto B$ is a one-to-one correspondence, then $f^{-1} :
B \mapsto A$.

Giving a bijection between two sets is often a good way to show they have the
same size.

### Permutation

A function $f : A \mapsto B$ is a permutation if $A = B$, and $f$
is a bijection.

Types
-----

### Total

A function $f : A \mapsto B$ is a total function if its defined for every
value of $A$. A function is assumed to be total unless explicitly told
otherwise.

### Partial

A function $f : A \mapsto B$ is a partial function if its only defined for
a subset of $A$. This is denoted as $f : A \mapsto_{p} B$ or as $f :
A ⇸ B$. Notice that counter-intuitively, a partial function not necessarily a
function.

We can think of a partial function from $A$ to $B$ as a total function
from $A$ to $B \cup \{ \perp \}$, and instead of saying a function
$f$ is undefined for some $a \in A$, we say that $f(a) = { \perp
}$.

The set of partial functions is a proper superset of the set of total
functions, since a partial function is allowed to be defined on all its input
elements.

Relationships
-------------

### Equality

Two functions $f$ and $g$ from $A$ to $B$ are considered equal
if $\forall a \in A \bullet f(a) = g(a)$.

### Composition

Since functions are binary relations, they can be composed. Given $f : A
\mapsto B$ and $g : B \mapsto C$, $(g \circ f)(a) = g(f(a)) $.

- The composition of two one-to-one functions is one-to-one
- If $f : A \mapsto B$ is one-to-one, then there exists an onto function
  $g : B \mapsto A$ such that $\forall a \in A \bullet (g \circ f)(a) =
  a$, and conversely
- If $g : B \mapsto A$ is onto, then there exists a one-to-one function
  $f : A \mapsto B$ such that $\forall a \in A \bullet (g \circ f)(a) =
  a$

### Compatibility

Given $f : A \mapsto B$ and an equivalence relation $R$ on $A$, *$f$ is
compatible with $R$* if $\forall x, y \in A \bullet (x, y) \in R \implies
f(x) = f(y)$.

Operations
----------

- **Range**: given $f : A \mapsto B$, the range of $f$ is the set of
  all the results of the application of such function. $Range(f) = \{ f(a)
  \mid a \in A \}$

- **Restriction**: given $f : A \mapsto B$ and $C \subseteq A$, the set
  $f \cap (C \times B)$ is called *the restriction of $f$ to $C$*,
  since it limits the pairs included in the relation. This is usually denoted
  $f \restriction C$

- **Relational Override**: given functions $f$ and $g$, we can override
  certain pairs in $f$ with their $g$ corresponding pairs as $f
  \oplus g$. Notice we can't simply do $f \cup g$ since it can result in
  pairs that map the same value to more than one result, violating the
  definition of a function. Formally, $f \oplus g = (dom(g) ⩤ f) \cup g$

Note that if $dom(f) \cap dom(g) = \emptyset$, then $f \oplus g = f \cup
g$, and $f \oplus g = g \oplus f$.

Images
------

Given $f : A \mapsto B$ and $X \subseteq A$, then $f(X)$ is called
the *image of $X$ under $f$*, which is the set of values returned by
$f$ for every element in $X$, which can be expressed as $f(X) = \{
f(x) \mid x \in X \} = \{ b \in B \mid \exists x \in X \bullet f(x) = b \}$.

Then, given $Y \subseteq B$, the *inverse image of $Y$ under $f$*
is the set $ f^{-1}(Y) = \{ a \in A \mid f(a) \in Y\} $.

Note that $f^{-1}(Y)$ is defined as a set, and thus its not necessary for
$f^{-1}$ to be a function, which would imply that $f$ is a one-to-one
correspondence.
