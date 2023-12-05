---
title: Sequences
description: A sequence is a mathematical collection of objects in a particular order
---

For example: $A = \langle 1, 3, 2 \rangle$, in that order. A sequence
$\langle a, b, c \rangle$ can be seen as the total bijective function
$\{ (1, a), (2, b), (3, c) \}$. Following this definition, we can access
the $n$ element of a sequence using function application notation. Given
$A = \langle a, c, b \rangle$, $A(2) = c$.

The empty sequence is defined as $\langle \rangle$. Sequences are
homogeneous. They must contain elements of the same type.

If $X$ is a set, then $seq(X)$ represents all the finite sequences of
elements of $X$, and its defined as: $ \{ s \in \mathbb{N} \mapsto X
\mid \exists n \in \mathbb{N} \bullet dom(s) = \{ 1 .. n \} \} $.

Basic Operations
----------------

### Concatenation

Given sequences $s$ and $t$, their concatenation is denoted as $s
\frown t$. Notice that $s \frown t \neq t \frown s$. Of course, $s
\frown \langle \rangle = s$, and concatenation is an associative operation.
It also follows that if $s \frown t = \langle \rangle$, then $s = \langle
\rangle$ and $t = \langle \rangle$.

### Filtering (or Restriction)

Given a sequence $s$, the sequence $s \restriction x$ represents all
the elements of $s$ that are included in $x$, preserving the ordering.
For example, $s = \langle a, b, b, a, c, b, a \rangle \restriction \{ a, c
\} = \langle a, a, c, a \rangle$. Notice that given set $A$, $(s
\frown t) \restriction A = (s \restriction A) \frown (t \restriction A)$.

Filtering the empty sequence always yields back the empty sequence: $\forall
X \bullet \langle \rangle \restriction X = \langle \rangle$, and
filtering any sequence by the empty set also yields the empty sequence:
$\forall s \in seq \bullet s \restriction \emptyset = \langle \rangle$.

Applying multiple restrictions over the same sequence is the same as
restricting by the intersection of those sets. Given sequence $s$ and sets
$A$ and $B$, then $(s \restriction A) \restriction B = s \restriction
(A \cap B)$.

### Head

The first element of a sequence is called its head. For example, given $S =
\langle a, b, c \rangle$, $S_{0} = a$, or alternatively $head(S) =
a$. The head of the empty sequence is the empty sequence. Notice that
$head(\langle x \rangle \frown s) = x$, and that given a non empty sequence
$s$, then $\exists t \bullet head(s) \frown t = s$.

### Tail

The tail of a sequence is a sequence containing all the original elements
except for the first one. For example, given $S = \langle a, b, c \rangle$,
then $S' = \langle b, c \rangle\$, or alternatively $tail(S) = \langle b,
c \rangle$. Notice that for any sequence $S$, $S = S_{0} \frown S'$,
and $(\langle x \rangle \frown S)' = S$.

### Indexing

Sequences are indexed from 0 using square bracket notation. For example
$\langle a, b, c \rangle[1] = b$.

### Prefix

A sequence $S$ is a *prefix* of sequence $T$ if the elements if there
is a sequence $Q in T$ such that $T = S \frown
Q$. For example: $\langle a, b \rangle \leq \langle a, b, c, d \rangle$
but $\langle b, c \rangle \lneq \langle a, b, c, d \rangle$. Notice that
given any set $A$, $s \leq t \implies (s \restriction A) \leq (t
\restriction A)$. Also, given a sequence $s$, $t \leq u \implies (s
\frown t) \leq (s \frown u)$.

If follows that given any sequence $S$, $\langle \rangle \leq S$, and
that $S \leq S$. This operation is asymmetric: $s \leq t \land t \leq s
\implies s = t$, and transitive: $s \leq t \land t \leq u \implies s \leq
u$. Of course, if $s \leq t$, then $\exists u \bullet (s
\frown u) = t$.

An easy way to check if a prefix expression $s \leq t$ holds is by checking
that $(t \neq \langle \rangle) \land (s_{0} = t_{0}) \land (s' \leq t')$.

Notice that if two sequences are prefixes of the same sequence, then one is the
prefix of the other or viceversa: $(s \leq u) \land (t \leq u) \implies (s
\leq t) \lor (t \leq s)$.

The $\leq$ operator may have an exponent, in which case $S$ is an
*n*-prefix of $T$ if $T$ starts with $S$ and it has up to $n$
elements removed. For example: $\langle a, b \rangle \leq^{2} \langle a, b,
c, d \rangle$, $\langle a, b \rangle \leq^{2} \langle a, b, c \rangle$,
but $\langle a, b \rangle \lneq^{2} \langle a, b, c, d, e \rangle$. This
operator is defined as $S \leq^{n} T = (S \leq T \land \# T \leq \# S +
n)$. It follows that $S \leq^{0} T \iff S = T$ and that $S \leq T \iff
\exists n \bullet S \leq^{n} T$. Also notice that $S \leq^{n} T \land T
\leq^{m} U \implies S \leq^{n + m} U$.

### Cardinality

Since a sequence is a relation from natural numbers to the sequence elements,
we can re-use the cardinality notation from sets. Thus, $\vert \langle a, b,
b, c \rangle \vert = 4$, or $\#\langle a, b, b, c \rangle = 4$.

### Flattening

A sequence containing other sequences might be flattened to a single sequence
by using a ditributed version of the concatenation operator. Given $s =
\langle (a, b), (c, d), (e, f) \rangle $, then $\frown/s = \langle a, b, c,
d, e, f \rangle $.

### Repetition

A sequence $S$ to the power of $n$ is equal to the sequence
concatenated to itself $n$ times. For example: $\langle a, b \rangle^{3}
= \langle a, b, a, b, a, b \rangle$.

### Reverse

Given a sequence $S = \langle a, b, c, d, e \rangle$, its inverse is the
same sequence from right to left: $\overline{S} = \langle e, d, c, b, a
\rangle$. Of course, $\overline{\langle \rangle} = \langle \rangle$, and
$\overline{\langle x \rangle} = \langle x \rangle$. Also,
$\overline{\overline{S}} = S$. The reverse of a concatenation is equal to
the reverse concatenation of the inverse: $\overline{s \frown t} =
\overline{t} \frown \overline{s}$.

### Star

The star sequence of a set $A$ is the infinite set of *finite* sequences
$s$ made of elements from $A$. More formally: $A^{*} = \{ s \mid s
\restriction A = s \}$. It follows that for any set $A$, $\langle
\rangle \in A^{*}$.

Membership on a set can be expressed in terms of membership to the star
sequence of the set: $\langle x \rangle \in A^{*} \iff x \in A$. Also,
$(s \frown t) \in A^{*}$ means that both $s$ and $t$ are members
of the star of $A$.

### Count

Given a sequence $S$, $S \downarrow x$ represents the amount of time
$x$ is inside the sequence $S$. For example: $\langle a, b, b, c
\rangle \downarrow b = 2$. Formally, $S \downarrow x$ is defined as
$\vert S \restriction \{ x \} \vert$.

### Includes

The $in$ operation represents whether a sequence $S$ is contained
within a sequence $T$. For example: $\langle b, c \rangle in
\langle a, b, c, d \rangle$. Notice that not $\langle b, d
\rangle in \langle a, b, c, d \rangle$.

### Interleaves

A sequence $s$ is an interleave of sequences $t$ and $u$ if $s$
can be constructed by arbitrarily extracting elements from $t$ and $u$
in order. For example $\langle 1, 2, 3, 4 \rangle interleaves
(\langle 1, 3 \rangle, \langle 2, 4 \rangle)$, and $\langle 1,
2, 3, 4 \rangle interleaves (\langle 1, 2 \rangle,
\langle 3, 4 \rangle)$. Of course, it holds that $s interleaves
(t, u) = s interleaves (u, t)$.

This operation is defined like this:

$\begin{align} \langle \rangle interleaves (t, u) &\iff
(t = \langle \rangle \land u = \langle \rangle) \\ \langle x \rangle \frown s
interleaves (t, u) &\iff \\&(t \neq \langle \rangle \land
head(t) = x \land s interleaves (tail(t), u))
\lor\\& (u \neq \langle \rangle \land head(u) = x \land s
interleaves (t, tail(u)) ) \end{align}$

Properties
----------

### Injection

An injective sequence is one where its elements don't appear more than once.
Remember that sequences are defined as functions whose range is the set of
natural numbers, and therefore the functional definition of injection
(one-to-one) holds: a sequence without duplicates is one where every natural
number from the domain points to a different element.
