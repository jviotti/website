---
title: Boolean Algebra
description: Boolean algebra is the branch of algebra in which the values of the variables are the truth values true and false
---

Expressions
-----------

- **Consistent:** if it cannot be both true and false
- **Complete:** if every fully instantiated expression if true or false
- **Tautology:** if it evaluates to true for every combination of its
  propositional variables
- **Contradiction:** if it evaluates to false for every combination of its
  propositional variables

Operators
---------

### Exclusive Or

P or Q, but not both: $P + Q = (P \land \lnot Q) \lor (\lnot P \land Q)$.

| $P$ | $Q$ | $P + Q$ | $P \land \lnot Q$ | $\lnot P \land Q$ |
|---------|---------|-------------|-----------------------|-----------------------|
| F       | F       | F           | F                     | F                     |
| F       | T       | T           | F                     | T                     |
| T       | F       | T           | T                     | F                     |
| T       | T       | F           | F                     | F                     |

### Nor

Neither P nor Q: $P \downarrow Q = \lnot P \land \lnot Q$.

| $P$ | $Q$ | $P \downarrow Q$ | $\lnot P$ | $\lnot Q$ |
|---------|---------|----------------------|---------------|---------------|
| F       | F       | T                    | T             | T             |
| F       | T       | F                    | T             | F             |
| T       | F       | F                    | F             | T             |
| T       | T       | F                    | F             | F             |

### Negative And (NAND)

P and Q are not both true: $P \mid Q = \lnot P \lor \lnot Q$.

| $P$ | $Q$ | $P \mid Q$ | $\lnot P$ | $\lnot Q$ |
|---------|---------|----------------|---------------|---------------|
| F       | F       | T              | T             | T             |
| F       | T       | T              | T             | F             |
| T       | F       | T              | F             | T             |
| T       | T       | F              | F             | F             |

### Conditional

If P, then Q: $P \rightarrow Q = \lnot P \lor Q$. It is sometimes described
like this:

- P only if Q
- P is a sufficient condition of Q
- Q is a necessary condition for P

| $P$ | $Q$ | $P \rightarrow Q$ | $\lnot P$ |
|---------|---------|-----------------------|---------------|
| F       | F       | T                     | T             |
| F       | T       | T                     | T             |
| T       | F       | F                     | F             |
| T       | T       | T                     | F             |

A conditional can also be expressed in the following form, called
*contrapositive*: $P \rightarrow Q = \lnot Q \rightarrow \lnot P$.

| $P$ | $Q$ | $\lnot Q \rightarrow \lnot P$ | $\lnot Q$ | $\lnot P$ |
|---------|---------|-----------------------------------|---------------|---------------|
| F       | F       | T                                 | T             | T             |
| F       | T       | T                                 | F             | T             |
| T       | F       | F                                 | T             | F             |
| T       | T       | T                                 | F             | F             |

Proof:

$$\begin{align}
P \rightarrow Q &= \lnot Q \rightarrow \lnot P \
&= Q \lor \lnot P \
&= \lnot P \lor Q \
&= P \rightarrow Q
\end{align}$$

### Biconditional (iff)

P if and only Q: $P \iff Q = (P \rightarrow Q) \land (Q \rightarrow P)$.

| $P$ | $Q$ | $P \iff Q$ | $P \rightarrow Q$ | $Q \rightarrow P$ |
|---------|---------|----------------|-----------------------|-----------------------|
| F       | F       | T              | T                     | T                     |
| F       | T       | F              | T                     | F                     |
| T       | F       | F              | F                     | T                     |
| T       | T       | T              | T                     | T                     |

Laws
----

### DeMorgan's Laws

$$
\lnot (P \land Q) = \lnot P \lor \lnot Q \
\lnot (P \lor Q) = \lnot P \land \lnot Q
$$

### Commutative Laws

$$
P \land Q = Q \land P \
P \lor Q = Q \lor P
$$

### Associative Laws

$$
P \land (Q \land R) = (P \land Q) \land R \
P \lor (Q \lor R) = (P \lor Q) \lor R
$$

### Idempotence Laws

$$
P \land P \iff P \
P \lor P \iff P
$$

### Unit Element Laws

$$
P \land true \iff P \
P \lor true \iff true
$$

### Zero Element Laws

$$
P \land false \iff false \
P \lor false \iff P
$$

### Complement Laws

$$
P \land \lnot P \iff false \
P \lor \lnot P \iff true
$$

### Distributive Laws

$$
P \land (Q \lor R) = (P \land Q) \lor (P \land R) \
P \lor (Q \land R) = (P \lor Q) \land (P \lor R)
$$

### Absorption Laws

$$
P \lor (P \land Q) = P \
P \land (P \lor Q) = P
$$

### Double Negation Law

$$\lnot \lnot P = P$$

Truth Sets
----------

The truth set of a statement $P(x)$ is the set of all values of $x$
that make the statement $P(x)$ true.

- The truth set of $P(x)$: $\{ x \mid P(x) \}$
- The truth set of $\lnot P(x)$: $U \setminus \{ x \mid P(x) \}$
