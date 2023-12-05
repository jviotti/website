---
title: Logic
description: Notes in propositional logic, predicate logic, and proof strategies
---

Quantification
--------------

### Universal Quantifier

The universal quantification $\forall x \in X \bullet P(x)$ expresses that a
predicate $P$ must hold for every element of type $X$.

The quantifier may include a constraint on the type: $\forall x \in X \mid X
\subseteq Y \bullet P(x)$, which can be translated to an implication on the
predicate: $\forall x \in X \bullet X \subseteq Y \implies P(x)$.

Negating a universal quantification is equivalent to an existential
quantification with a negated predicate: $\lnot \forall x \in X \bullet P(x)
\iff \exists x \in X \bullet \lnot P(x)$.

### Existential Quantifier

The existential quantification $\exists x \in X \bullet P(x)$ expresses that
a predicate $P$ holds for at least one element of type $X$.

The quantifier may include a constraint on the type: $\exists x \in X \mid X
\subseteq Y \bullet P(x)$, which can be translated to a conjunction on the
predicate: $\exists x \in X \bullet X \subseteq Y \land P(x)$.

Negating an existential quantification is equivalent to a universal
quantification with a negated predicate: $\lnot \exists x \in X \bullet P(x)
\iff \forall x \in X \bullet \lnot P(x)$.

### Uniqueness Quantifier

The uniqueness quantifier $\exists_{1} x \in X \bullet P(x)$ expresses that a
predicate $P$ must hold for exactly one element of type $X$. This
quantifier might be expressed in terms of the existential and universal
quantifiers as follows: $\exists_{1} x \in X \bullet P(x) \iff \exists x \in X
\bullet P(x) \land \forall y \in X \bullet P(y) \implies y = x$, therefore the
result of negating a uniqueness quantifier looks like this:

$$\begin{align}
\lnot \exists_{1} x \in X \bullet P(x) &\iff \lnot \exists x \in X \bullet P(x) \land \forall y \in X \bullet P(y) \implies y = x \\
&\iff \forall x \in X \bullet \lnot (P(x) \land \forall y \in X \bullet P(y) \implies y = x) \\
&\iff \forall x \in X \bullet \lnot P(x) \lor \exists y \in X \bullet \lnot (P(y) \implies y = x) \\
&\iff \forall x \in X \bullet \lnot P(x) \lor \exists y \in X \bullet P(y) \land y \neq x \\
&\iff \forall x \in X \bullet P(x) \implies \exists y \in X \bullet P(y) \land y \neq x
\end{align}$$

Similarly to the existential quantifier, A constraint in a uniqueness
quantifier becomes a conjunction in the predicate: $\exists_{1} x \in X \mid
X \subseteq Y \bullet P(x) \iff \exists_{1} x \in X \bullet X \subseteq Y \land
P(x)$.

Proof Strategies
----------------

### Negation

- As a given: re-express it in a non-negated form
- As a goal: try proof by contradiction

### Disjunction

- As a given: use proof by cases
- As a given: if you know one of the disjuncts is false, then you can conclude
  the other one is true
- As a goal: break the proof into cases. In each case, prove any of the
  disjuncts

### Implication

- As a given (modus ponens): given $P \implies Q$, if $P$, then you can
  conclude $Q$
- As a given (modus tollens): given $P \implies Q$, if $\lnot Q$, then
  you can conclude $\lnot P$
- As a goal: given $P \implies Q$, assume $P$ and prove $Q$
- As a goal: given $P \implies Q$, assume $\lnot Q$ and prove $\lnot
  P$

### Equivalence

- As a given: re-write as a conjunction between two implications
- As a goal: re-write as a conjunction between two implications and prove both
  directions

### Universal Quantifier

- As a given (universal instantiation): given $\forall x \in X \bullet P(x)$
  and an element $q \in X$, you may conclude $P(q)$
- As a goal: declare an arbitrary element of the quantified object and prove
  the predicate

### Existential Quantifier

- As a given (existential instantiation): introduce an arbitrary value for
  which the predicate is true
- As a goal: find a value that makes the predicate true

### Proof by Contradiction

Given a goal $X$, assume $\lnot X$ and derive a logical contradiction.
