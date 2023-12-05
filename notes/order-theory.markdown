---
title: Order Theory
description: Order theory the concept of order when using binary relations
---

Pre Orders
----------

A relation $R$ on $A$ is called a preorder of $A$ if its
*reflexive* and *transitive*.

Partial Orders
--------------

A partial order describes the order of *some* of the ordered pairs in a
relation. $R$ is a partial order on $A$ if its *reflexive*,
*transitive*, and *antisymmetric*. A partial order is also a preorder.

Notice that $\exists x, y \in A \bullet (x, y) \notin R$, and that's
the reason why a partial order doesn't provide a way to determine the order of
any elements of $A$.

### Totalising a Partial Order

A partial order is totalized by calculating its *augment set*, and associating
every element that is not in the partial order's domain with every element of
the augmented target.

The totalized version of $P \subseteq X \times Y$ is denoted as $\dot{P}
= P \cup (\overline{dom P}^{\perp} \times Y^{\perp})$. The augmented
complement $\overline{dom P}^{\perp}$ is the set of all elements of $X$
not in $P$ plus the $\perp$ element (the augmented symbol is applied to
the result of the complement operation). Each element is then associated with
every element of the augmented target, $Y^{\perp}$.

So given $X = \{ a, b, c \}$ and $Y = \{ 1, 2 \}$, and a partial
order $P = \{ (a, 1), (b, 2) \}$, $\overline{dom P}^{\perp} = \{
c, \perp \}$, and $\{ c, \perp \} \times Y^{\perp} = \{ (c, 1), (c,
2), (c, \perp), (\perp, 1), (\perp, 2), (\perp, \perp) \}$.
Therefore $\dot{P} = \{ (a, 1), (b, 2), (c, 1), (c, 2), (c,
\perp), (\perp, 1), (\perp, 2), (\perp, \perp) \}$.

Notice that the totalized version behaves as specified when used within the
partial order domain. Anything outside that is considered undefined. The role
of $\perp$ is to ensure that undefinedness is propagated through relational
composition.

If the order $P$ is total, i.e. $dom P = X$, then $\dot{P} = P \cup
\{ \perp \} \times Y^{\perp} $.

Total Orders
------------

A total order describes the order of *all* of the ordered pairs in a relation.
$R$ is a total order on $A$ if its already a partial order, and if
$\forall x, y \in A \bullet xRy \lor yRx$.

Strict Partial Orders
---------------------

A strict partial order describes the order of *some* of the ordered pairs in a
relation, but making sure that pairs consisting of the same element, and
mirrored pairs are omitted. $R$ is a strict partial order on $A$ if its
*irreflexive*, *transitive*, and *asymmetric* (which assumes the relation is
antisymmetric as well). Keep in mind a strict partial order *is not* a partial
order.

Strict Total Orders
-------------------

A strict total order extends a strict partial order to describe the order of
*all* of the ordered pairs in a relation. $R$ is a strict total order on
$A$ if its already a strict partial order, and if $ \forall x, y \in A
\bullet xRy \lor yRx \lor x = y $.

Special Elements
----------------

Given a binary relation $R \subseteq A \times A$ an arbitrary element $x
\in A$:

- **Minimal**: $x$ is a minimal element of $R$ if $\lnot \exists a
  \in A \bullet (a, x) \in R \land a \neq x$

- **Maximal**: $x$ is a maximal element of $R$ if $\lnot \exists a
  \in A \bullet (x, a) \in R \land a \neq x$

- **Smallest**: $x$ is **the** smallest element of $R$ if $\forall a
  \in A \bullet (x, a) \in R$

Note that the smallest element is also a minimal element. Since a total order
describes the ordering of all possible elements, then if $R$ is a total
order and $x$ is a minimal element, then its also the smallest one.

- **Largest**: $x$ is **the** largest element of $R$ if $\forall a
  \in A \bullet (a, x) \in R$

Note that the largest element is also a maximal element. Since a total order
describes the ordering of all possible elements, then if $R$ is a total
order and $x$ is a maximal element, then its also the largest one.

Given a partian order $R$ on $A$, $B \subseteq A$, and $x \in
A$:

- **Lower bound**: $x$ is a lower bound for $B$ if $\forall b \in B
  \bullet (x, b) \in R$

Note that the smallest element of $B$ is a lower bound that is also an
element of $B$.

- **Upper bound**: $x$ is a lower bound for $B$ if $\forall b \in B
  \bullet (b, x) \in R$

- **Least upper bound**: The smallest element of the upper bounds
- **Greatest lower bound**: The largest element of the lower bounds
