---
title: Polynomials
description: Notes on polynomials
---

A single variable polynomial is an expression of the form $f(x) = a_0 x^0 +
a_1 x^1 + a_2 x^2 + ... a_n x^n$ where $a_i$ are coefficients and $n$ is
the degree of the polynomial. Polynomials encapsulate the full expression of
addition and multiplication.

We can calculate the *unique minimum* $n$ degree polynomial that goes through
a set of $n + 1$ points $\{ (x_0, y_0), (x_1, y_1), ..., (x_{n + 1}, y_{n +
1}) \}$ as $f(x) = \sum_{i=0}^n y_i (\prod_{j \neq i} \frac{x - x_j}{x_i -
x_j})$.

Roots
-----

Given a single variable polynomial $f(x)$, the roots of $f$ are the values
$y$ such that $f(y) = 0$. Notice that its impossible for a polynomial to
have more roots than its degree.

Given polynomials with real coefficients, we say that a number $x$ is
*algebraic* (otherwise *trascendental*) if it is the root of a polynomial whose
coefficients are rational numbers. Consider $\sqrt{2}$ and polynomial $f(x)
= 1 - \frac{1}{2} x^2$. Then $f(\sqrt{2}) = 0$, so $\sqrt{2}$ is
algebraic.

Special Polynomials
-------------------

### Zero Polynomial

The zero polynomial is defined as $f(x) = 0$ for any $x$, and it has a
degree $-1$ by convention, as otherwise it would have every degree: $f(x) =
0x^0$, or $f(x) = 0x^0 + 0x^1$, or $f(x) = 0x^0 + 0x^1 + 0x^2$, etc.

Given polynomials $f$ and $g$, if $f - g$ is the zero polynomial, then it
means that $f = g$.

Operations
----------

### Multiplication

Given an $n$ degree polynomial $f$ and an $m$ degree polynomial $g$,
the polynomial $f \cdot g$ has a degree $n + m$. A polynomial multiplied by
the zero polynomial is the zero polynomial.

Properties
----------

### Monic

A polynomial is *monic* if the non-zero coefficient of highest degree (leading
coefficient) is 1. For example, this polynomial is monic: $f(x) = 2 + 5x +
x^2$, as the highest degree part of the expression is $x^2$, and it has a
coefficient 1, as $x^2 = 1x^2$.
