---
title: Algebra
description: Basic notes on algebra
---

Quantifiers
-----------

### Summations

Given a finite set $S$ and a function $f : S \mapsto \mathbb{R}$,
$\sum\limits_{x \in S} f(x)$ represents the sum of all the elements of
$S$ applied to $f$. Basically, if $S = \{ s_1, s_2, s_3 \}$, then
$\sum\limits_{x \in S} f(x) = f(s_1) + f(s_2) + f(s_3)$.

Summing up over intervals of integers is so common that there is an special
notation for it. Something like $\sum\limits_{i \in \{ 1, ..., 100 \}}
i^2$ can be re-expressed as $\sum\limits_{i = 1}^{100} i^2$. The general
form is $\sum\limits_{i = a}^{b} f(i)$, assuming that $a \leq b$.

### Products

The product quantifier has the same syntax as the summation quantifier, but of
course we calculate the product of every function application. The product of
all numbers in a set $S = \{ s_1, s_2, s_3 \}$ by the power of two is:
$\prod\limits_{i \in S} i^2 = s_1^2 \times s_2^2 \times s_3^2$.
