---
title: Linear Algebra
description: Notes on linear algebra
---

Bases
-----

A basis for a vector space $V$ is a set of linearly independent vectors $\{
\vec{v_1}, \vec{v_2}, ..., \vec{v_n} \}$ such that $span(\{ \vec{v_1},
\vec{v_2}, ..., \vec{v_n} \}) = V$. A vector space may have more than one
basis, but all bases for a vector space have the same number of elements. Any
vector of a vector space can be expressed as a linear combination of a basis of
such vector space.

The basis of a vector can be explicitly denoted using subscript notation. For
example if $\vec{v}$ is expressed in terms of basis $B$, then we can say
$[\vec{v}]_{B}$.

More formally, given vector space $V$, the set $B$ is a basis for $V$ if
$span(B) = V$ and if removing any element from $B$ stops making $B$ a
basis for $V$: $\forall b \in \wp(B) \setminus \{ \emptyset \} \bullet
span(B \setminus b) \neq V$. A basis $B$ for $V$ is *maximal*, which means
that adding any element to $B$ makes it a linearly dependent vector set.

### Orthogonal and Orthonormal Bases

Two vectors $\vec{u}$ and $\vec{v}$ are *orthogonal* if $\langle \vec{u},
\vec{v} \rangle = 0$. Given a vector space $V$, a set of vectors $\{ e_1,
e_2, ..., e_n \}$ is an *orthogonal* basis for $V$ if each $e_i$ is
orthogonal to all the other vectors in the basis: $\forall e_i, e_j \in \{
e_1, e_2, ..., e_n \} \mid e_i \neq e_j \bullet \langle e_i, e_j \rangle = 0$.

The unit vector of vector $v$ is $\hat{v} = \frac{v}{\parallel v
\parallel}$. The set $\{ \hat{e}_1, \hat{e}_2, ..., \hat{e}_n \}$ is an
*orthonormal* basis for $V$ if every $\hat{e}_i$ is the unit vector of a
vector $e_i$ in an orthogonal basis for $V$. A vecto $\vec{v}$ can be
expressed in terms of an orthonormal basis $\{ \hat{e}_1, \hat{e}_2, ...,
\hat{e}_n \}$ as $\vec{v} = \langle \vec{v}, \hat{e}_1 \rangle \hat{e}_1 +
\langle \vec{v}, \hat{e}_2 \rangle \hat{e}_2 + ... + \langle \vec{v}, \hat{e}_n
\rangle \hat{e}_n$.

The *Gram–Schmidt process* allows us to obtain an orthogonal basis $\{ e_1,
e_2, ..., e_n \}$ given any basis $\{ v_1, v_2, ..., v_n \}$. If we have an
orthogonal basis, its trivial to obtain an orthonormal basis by calculating the
unit vector of each vector in the orthogonal basis. The process is defined as
$e_n = v_n - \sum_{i=1}^{n - 1} (\langle \hat{e_i}, v_n \rangle \hat{e_i})$
so basically:

- $e_1 = v_1$
- $e_2 = v_2 - (\langle \hat{e_1}, v_2 \rangle \hat{e_1})$
- $e_3 = v_3 - (\langle \hat{e_1}, v_3 \rangle \hat{e_1}) - (\langle
  \hat{e_2}, v_3 \rangle \hat{e_2})$
- etc

### Matrix Bases

Given matrix $A$:

- **Row Space**: The non-zero rows of $rref(A)$ are a basis for
  $\mathscr{R}(A)$

- **Column Space**: The non-zero rows of $rref(A^{T})$ are a basis for
  $\mathcal{C}(A)$. Alternatively, find the columns in $rref(A)$ that
  contain a pivot. The corresponding columns *from the original matrix* $A$
  are a basis for $\mathcal{C}(A)$

- **Null Space**: If $rref(A)$ contains pivots in all columns (i.e. the
  matrix vectors are linearly independent), then the basis for the null space
  of $A$ is just $\{ \vec{0} \}$. Otherwise, the process is more
  elaborated:

We can setup the system of equations $rref(A) \cdot \vec{x} = \vec{0}$. If
$A$ is an $n \times m$ matrix, then $\vec{x}$ contains $m$ elements.

For example, given $\begin{bmatrix}1 & 2 & 0 & 0 \\ 0 & 0 & 1 & -3 \\ 0 & 0 &
0 & 0\end{bmatrix}$, then the equation is $\begin{bmatrix}1 & 2 & 0 & 0 \\ 0
& 0 & 1 & -3 \\ 0 & 0 & 0 & 0\end{bmatrix} \begin{bmatrix} x_1 \\ x_2 \\ x_3 \\
x_4 \end{bmatrix} = \begin{bmatrix}0 \\ 0 \\ 0 \end{bmatrix}$.

The goal is to re-express $\vec{x}$ so that the elements corresponding to
columns in $A$ with pivots are expressed in terms of the elements
corresponding to columns *without* pivots.

In our example, the columns of $A$ with pivots are the first and the third
one, so we need to express $x_1$ and $x_3$ in terms of $x_2$ and $x_4$.
Expanding the equations gives us:

- $1x_1 + 2x_2 + 0x_3 + 0x_4 = 0$ so $x_1 + 2x_2 = 0$ and therefore $x_1 =
  -2x_2$
- $0x_1 + 0x_2 + 1x_3 -3x_4 = 0$ so $x_3 - 3x_4$ and therefore $x_3 =
  3x_4$
- $0x_1 + 0x_2 + 0x_3 + 0x_4 = 0$ which is not very useful in this case

So we now know that $\begin{bmatrix} x_1 \\ x_2 \\ x_3 \\ x_4 \end{bmatrix} =
\begin{bmatrix}-2x_2 \\ x_2 \\ 3x_4 \\ x_4\end{bmatrix}$.

Finally, we can express $\vec{x}$ as a linear combination over the terms
corresponding to columns without pivots. The coefficients of such linear
combination are a basis for $\mathcal{N}(A)$.

In our example, $\begin{bmatrix}-2x_2 \\ x_2 \\ 3x_4 \\ x_4\end{bmatrix} =
\begin{bmatrix}-2 \\ 1 \\ 0 \\ 0\end{bmatrix}x_2 + \begin{bmatrix}0 \\ 0 \\ 3
\\ 1\end{bmatrix}x_4$, so the basis is $\{ \begin{bmatrix}-2 \\ 1 \\ 0 \\
0\end{bmatrix}, \begin{bmatrix}0 \\ 0 \\ 3 \\ 1\end{bmatrix} \}$.

### Change of Basis

The identity transformation matrix changes the basis of a matrix to another
basis of the same vector space. The identity transformation matrix that changes
from basis $B_1$ to bases $B_2$ is ${}_{B_2}[\mathbb{1}]_{B_1}$.
Notice an identity transformation matrix is not equal to the identity matrix
$\mathbb{1}$, even though they re-use the same symbol.

Given $B_1 = \{ e_1, e_2, e_3 \}$ and $B_2 = \{ t_1, t_2, t_3 \}$, then
${}_{B_2}[\mathbb{1}]_{B_1}$ consists of all the dot products $e_i
\cdot t_j$:

$$
{}_{B_2}[\mathbb{1}]_{B_1} = \begin{bmatrix}
t_1 \cdot e_1 & t_1 \cdot e_2 & t_1 \cdot e_3 \\
t_2 \cdot e_1 & t_2 \cdot e_2 & t_2 \cdot e_3 \\
t_3 \cdot e_1 & t_3 \cdot e_2 & t_3 \cdot e_3
\end{bmatrix}
$$

Notice that $({}_{B_2}[\mathbb{1}]_{B_1})^{-1} =
{}_{B_1}[\mathbb{1}]_{B_2}$.

Linear Independence
-------------------

A set of vectors $\{ \vec{v_1}, ..., \vec{v_n} \}$ is linearly independent if
the *only* solution to the equation $\alpha_1 \vec{v_1} + ... + \alpha_n
\vec{v_n} = \vec{0}$ is $0$ for all $\alpha_n$.

We can also say a set $V = \{ \vec{v_1}, ..., \vec{v_n} \}$ where no $v_i$
is the zero vector is linearly independent if no vector from the set is in the
span of the other vectors: $\forall v \in V \bullet v \notin span(V \setminus
\{ v \})$.

Another way to express that the set of vectors in $V$ are linearly
independent is that every vector in $span(V)$ has a unique expression as a
linear combination of vectors in $V$.

The rows of a matrix $A$ are linearly independent if $det(A) \neq 0$

Linear Combinations
-------------------

A linear combination is an algebraic expression consisting on the sum of terms
and constants of the form: $a_1 x_1 + a_2 x_2 + ... + a_n x_n$ where the set
of $x_n$ are terms (with exponent 1) and the set $a_n$ are their
corresponding constants. Linear combinations are degree-1 polynomials.

In a linear combination $a_1 x_1 + a_2 x_2 + ... + a_n x_n$, the $x_n$
terms correspond to the basis in which we are expressing the linear
combination.

### Span

The span of a set of vectors is the set of all vectors that can be constructed
as linear combinations of those vectors.

Consider that given $\vec{v_1}$, $\vec{v_2}$, and $\vec{v_3} = \vec{v_1} +
\vec{v_2}$, then $span(\{ \vec{v_1}, \vec{v_2}, \vec{v_3} \}) = span(\{
\vec{v_1}, \vec{v_2} \})$, as $\vec{v_3}$ can be expressed as a linear
combination of the other two.

A set of vectors $V$ is *spanned* by $\{ \vec{v_1}, ..., \vec{v_n} \}$ if
any vector in $V$ can be expressed as a linear combination of the vectors in
$\{ \vec{v_1}, ..., \vec{v_n}\}$.

Vector Spaces
-------------

A vector space is a set that consists of a number of linearly independent
vectors and all linear combinations of those vectors. Vector spaces must be
*closed* under addition and scalar multiplication, which means that, given
vector space $V$:

- Any sum of two vectors in the vector space is part of the vector space:
  $\forall \vec{v_1}, \vec{v_2} \in V \bullet \vec{v_1} + \vec{v_2} \in V$

- Any vector in the vector space multiplied by any constant is part of the
  vector space: $\forall \alpha \bullet \forall \vec{v} \in V \bullet \alpha
  \vec{v} \in V$

An abstract vector space is defined as $(V, F, +, \cdot)$ where:

- $V$ is a set of vector-like objects, such as $\mathbb{R}^{n \times n}$
- $F$ is a set of scalars, such as $\mathbb{R}$
- $+$ is a $V \times V \mapsto V$ addition function
- $\cdot$ is a $F \times V \mapsto V$ scalar multiplication function

The addition function $+$ and the set $V$ must have the following
properties:

- Associativity: $\forall \vec{u}, \vec{v}, \vec{w} \in V \bullet \vec{u} +
  (\vec{v} + \vec{w}) = (\vec{u} + \vec{v}) + \vec{w}$
- Commutativity: $\forall \vec{u}, \vec{v} \in V \bullet \vec{u} + \vec{v} =
  \vec{v} + \vec{u}$
- Zero vector: $\exists \vec{0} \in V \bullet \forall \vec{v} \in V \bullet
  \vec{v} + \vec{0} = \vec{0} + \vec{v} = \vec{0}$
- Inverse: $\forall \vec{v} \in V \bullet \exists \vec{-v} \in V \bullet
  \vec{v} + (\vec{-v}) = \vec{v} - \vec{v} = \vec{0}$

The scalar function $\cdot$ and the set $F$ must have the following
properties:

- Distributivity: $\forall \alpha \in F \bullet \forall \vec{u}, \vec{v} \in V
  \bullet \alpha(\vec{u} + \vec{v}) = \alpha\vec{u} = \alpha\vec{v}$ and
  $\forall \alpha, \beta \in F \bullet \forall \vec{v} \in V \bullet (\alpha +
  \beta)\vec{v} = \alpha\vec{v} + \beta\vec{v}$
- Associativity: $\forall \alpha, \beta \in F \bullet \forall \vec{v} \in V
  \bullet \alpha(\beta \vec{v}) = (\alpha \beta)\vec{v}$
- Unit vector: $\exists 1 \in F \bullet \forall \vec{v} \in V \bullet 1\vec{v}
  = \vec{v}$

Vector spaces define an inner product $\langle \cdot, \cdot \rangle : V
\times V \mapsto \mathbb{R}$ function that is:

- Symmetric: $\forall \vec{v}, \vec{u} \in V \bullet \langle \vec{v}, \vec{u}
  \rangle = \langle \vec{u}, \vec{v} \rangle$
- Linear: $\forall \alpha, \beta \in F \bullet \forall \vec{u}, \vec{v_1},
  \vec{v_2} \in V \bullet \langle \vec{u}, \alpha \vec{v_1} + \beta \vec{v_2}
  \rangle = \alpha \langle \vec{u}, \vec{v_1} \rangle + \beta \langle \vec{u},
  \vec{v_2} \rangle $
- Positive semidefinite: $\forall \vec{v} \in V \bullet \langle \vec{v},
  \vec{v} \rangle \geq 0$ where $\langle \vec{v}, \vec{v} \rangle = 0 \iff
  \vec{v} = \vec{0}$

Defining an inner product automatically defines the length/norm operator
$\parallel \vec{v} \parallel = \sqrt{\langle \vec{v}, \vec{v}
\rangle}$ and the distance operator $d(\vec{u}, \vec{v}) = \parallel
\vec{u} - \vec{v} \parallel = \sqrt{\langle (\vec{u} - \vec{v}),
(\vec{u} - \vec{v}) \rangle}$. Both operations have the following
characteristics given a valid inner product definition:

- $\forall \vec{v} \in V \bullet \parallel \vec{v} \parallel
  \geq 0$ where $\parallel \vec{v} \parallel = 0 \iff \vec{v} = \vec{0}$
- $\forall \alpha \in F; \vec{v} \in V \bullet \parallel \alpha
  \vec{v} \parallel = \alpha \parallel \vec{v} \parallel$
- Triangle equality: $\forall \vec{u}, \vec{v} \in V \bullet \parallel \vec{u}
  + \vec{v} \parallel \leq \parallel \vec{u} \parallel +
    \parallel \vec{v} \parallel$
- Cauchy–Schwarz inequality: $\forall \vec{u}, \vec{v} \in V \bullet
  det(\langle \vec{u}, \vec{v} \rangle) \leq \parallel \vec{u}
  \parallel \parallel \vec{v} \parallel$ where $det(\langle
  \vec{u}, \vec{v} \rangle) = \parallel \vec{u} \parallel \parallel
  \vec{v} \parallel$ if and only if $\vec{u}$ and $\vec{v}$ are
  linearly dependent

- $\forall \vec{u}, \vec{v} \in V \bullet d(\vec{u}, \vec{v}) = d(\vec{v},
  \vec{u})$
- $\forall \vec{u}, \vec{v} \in V \bullet d(\vec{u}, \vec{v}) \geq 0$ where
  $d(\vec{u}, \vec{v}) = 0 \iff \vec{u} = \vec{v}$

### Subspaces

A vector space $W \subseteq V$ is a vector subspace of $V$ if:

- $W$ is contained in $V$: $\forall \vec{w} \in W \bullet \vec{w} \in V$
- $W$ is a vector space (closed under addition and scalar multiplication)

Notice vector subspaces always contain the zero vector, as in order for a
vector space to be closed under scalar multiplication, it must hold that
$\forall \vec{w} \in W \bullet 0\vec{w} \in W$ for the scalar zero, and
multiplication with the scalar zero always yields the zero vector.

One way to define a vector subspace is to constrain a larger vector space.
Given $\mathbb{R}^3$, we can define a bi-dimensional vector subspace as $\{
(x, y, z) \in \mathbb{R}^3 \mid (0, 0, 1) \cdot (x, y, z) = 0 \}$.  Another
way is to define vector subspaces using $span$. The bi-dimensional vector
subspace of $\mathbb{R}^3$ is also defined as $span(\{ (1, 0, 0), (0, 1,
0)\})$.

### Orthogonal Complement

Given vector space $Q$ and a vector subspace $P \subseteq Q$, $P^{\perp}$
is the orthogonal complement of $P$ in vector space $Q$, defined as:
$P^{\perp} = \{ \vec{q} \in Q \mid \forall \vec{p} \in P \bullet \vec{q} \cdot
\vec{p} = 0 \}$.

### Dimension

The dimension of vector space $S$, denoted $dim(S)$, is the cardinality
(number of elements) in a basis of $S$. Every possible basis of a vector
space has the same dimension.

The following laws hold given an $n \times m$ dimensional matrix $M$:

- $dim(\mathscr{R}(M)) + dim(\mathcal{N}(M)) = n$
- $dim(\mathcal{C}(M)) + dim(\mathcal{N}(M^{T})) = m$
- $rank(M) + dim(\mathcal{N}(M)) = n$ where $dim(\mathcal{N}(M)) =
  nullity(M)$

### Zero Vector

The zero vector $\vec{0}$ of a vector space $V$ is a vector such that
$\forall \vec{x} \in V \bullet \vec{x} + \vec{0} = \vec{0} + \vec{x} =
\vec{x}$.

Linear Transformations (or Map)
-------------------------------

A linear transformation (also called linear map or linear function), is a
function that maps vectors to vectors, and that preserves the following
property, assuming function $f$ and linear combination $\alpha \vec{x_1} +
\beta \vec{x_2}$:

$$f(\alpha \vec{x_1} + \beta \vec{x_2}) = \alpha f(\vec{x_1}) + \beta
f(\vec{x_2})$$

Which in turn implies that:

- $f(\alpha \vec{x_1}) = \alpha f(\vec{x_1})$
- $f(\vec{x_1} + \vec{x_2}) = f(\vec{x_1}) + f(\vec{x_2})$
- $f(\vec{0}) = \vec{0}$, which means that linear transformations preserve
  zero vectors

Given a linear transformation $f$ that maps an $n$ dimensional vector space
to an $m$ dimensional vector space, if $f$ is a bijective function, then
$n = m$, and it means that $f$ is a one to one mapping between vector
spaces.

Consider a linear transformation $f : V \mapsto W$ and $\vec{v_1}, \vec{v_2}
\in V$. If we know that $f(\vec{v_1}) = \vec{w_1}$ and that $f(\vec{v_2}) =
\vec{w_2}$, then $f(\alpha \vec{v_1} + \beta \vec{v_2}) = \alpha \vec{w_1} +
\beta \vec{w_2}$, which means we know how $f$ will behave for *any* linear
combination of $\vec{v_1}$ and $\vec{v_2}$. This is important as if we know
how a linear transformation behaves for a basis of a vector space, then we know
how it behaves for the whole vector space.

### Kernel

The kernel of a linear transformation $t : V \mapsto W$ is the set of vectors
from $V$ that map to the zero vector: $Ker(t) = \{ \vec{v} \in V \mid
t(\vec{v}) = \vec{0} \}$. Notice that if $Ker(t) = \{ \vec{0} \}$, then
$t$ is an injective function.

### Image Space

The image space of a linear transformation $t : V \mapsto W$, denoted
$Im(t)$ is the range of $t$, which is the set of vectors from $W$ that
the function can produce. Notice that if $Im(t) = W$, then $t$ is a
surjective function.

### Matrix Representation

If we have a linear transformation $f : V \mapsto W$ and a basis $B_v$ for
$V$ and a basis $B_w$ for $W$, then we can express $f$ as a matrix
$M_{f}$ such that applying the transformation to a vector is equivalent to
multiplying the matrix with the vector: given $\vec{v} \in V$ and $\vec{w}
\in W$, then $f(\vec{v}) = \vec{w} \iff M_{f} \vec{v} = \vec{w}$. Notice the
matrix is *not* the linear transformation, but a representation of the linear
transformation with respect to certain bases.

Any linear transformation that maps an $n$ dimensional vector space to a
$m$ dimensional vector space can be represented as an $m \times n$ matrix.

Matrix $M_f$ "takes" a vector in basis $B_v$ and outputs a vector in basis
$B_w$, so its sometimes more explicitly denoted as ${}_{B_w}[M_f]_{B_v}$,
writing the input basis at the right, and the output basis at the left.

Correspondences between linear transformations and their matrix representations,
given $\vec{v}$, $f$, $s$, $M_f$, and $M_s$:

- $Im(f) = \mathcal{C}(M_f)$
- $Ker(f) = \mathcal{N}(M_f)$
- $(s \circ t)(\vec{v}) = s(t(\vec{v})) = M_s M_t \vec{v}$

In order to find the matrix representation with respect to a basis of a linear
transformation, apply the linear transformation to all the vectors in the
chosen basis and use the results as columns of the matrix representation.

For example, consider $\mathbb{R}^3$, basis $\{ (0, 0, 1), (0, 1, 0), (1, 0,
0) \}$, and a linear transformation $f((x, y, z)) = (x, y, 0)$. Then $M_f =
\begin{bmatrix}0 & 0 & 1 \\ 0 & 1 & 0 \\ 0 & 0 & 0\end{bmatrix}$ as $f((0, 0,
1)) = (0, 0, 0)$, $f((0, 1, 0)) = (0, 1, 0)$, and $f((1, 0, 0)) = (1, 0,
0)$.

We can express a matrix transformation in terms of different bases by
*surrounding* it with the corresponding identity transformation matrices. For
example, given ${}_{B_v}[M_f]_{B_v}$, then ${}_{B_w}[M_f]_{B_w} =
{}_{B_w}[\mathbb{1}]_{B_v} {}_{B_v}[M_f]_{B_v}
{}_{B_v}[\mathbb{1}]_{B_w}$, which basically means that we transform the
input matrix to the original's transformation basis, apply the linear
transformation, and then change to the new basis again.

### Inverse

A linear transformation $f : V \mapsto W$ is invertible if its *either*
injective, which implies $Ker(f) = \{ \vec{0} \}$, or surjective, which
implies $Im(t) = W$. It is also invertible if $\exists f^{-1} \bullet
\forall \vec{v} \bullet f^{-1}(f(\vec{v})) = \vec{v}$. If such linear
transformation is invertible, then its matrix representation $M_f$ is
invertible as well, and viceversa.

Given linear transformation $f$ and its matrix representation $M_f$ in
terms of a certain basis, then $M_f^{-1}$ corresponds to $f^{-1}$. Notice
that given vector $\vec{v}$, if $M_f^{-1}$ is invertible, then $M_f^{-1}
M_f \vec{v} = \vec{v}$.

### Affine Transformations

An affine transformation is a function $q : V \mapsto W$ that maps vector
spaces, which is a combination of a linear transformation $t$ and a
*translation* by a fixed vector $\vec{b}$: $q(\vec{x}) = t(\vec{x}) +
\vec{b}$, or given the matrix representation $M_t$, $q(\vec{x}) = M_t
\vec{x} + \vec{b}$.

Systems of Linear Equations
---------------------------

### Using RREFs

We can solve a system of $n$ linear equations given $m$ terms by
constructing an $n \times m + 1$ matrix where the last column correspond to
the constants at the right of the equal sign and computing its RREF. The last
column of the RREF contains the solutions for each corresponding pivot term.

The system of equations has no solutions if the contructed matrix is not
linearly independent, in which case its RREF contains zero coefficients with a
potentially non-zero constant at the end.

For example, consider $1x + 2y = 5$ and $3x + 9y = 21$. The resulting
matrix is $\begin{bmatrix}1 & 2 & 5 \\ 3 & 9 & 21\end{bmatrix}$. Then,
$rref(\begin{bmatrix}1 & 2 & 5 \\ 3 & 9 & 21\end{bmatrix}) = \begin{bmatrix}1
& 0 & 1 \\ 0 & 1 & 2\end{bmatrix}$, so the solution set is $x = 1$ and $y =
2$.

### Using Inverses

We can solve a system of $n$ linear equations given $m$ terms by expressing
it as a matrix equation $A\vec{x} = \vec{b}$ of an $n$ square (otherwise
there is no inverse) matrix $A$ containing the coefficients multiplied by an
$n$ vector $\vec{x}$ containing the terms, all equal to an $n$ vector
$\vec{b}$ containing the right-hand side constants. Using the inverse of
$A$, we can re-express $A\vec{x} = \vec{b}$ as $A^{-1} A \vec{x} = A^{-1}
\vec{b}$, which in turn equals $\vec{x} = A^{-1} \vec{b}$ as $A^{-1} A =
\mathbb{1}$, and then compute $A^{-1} \vec{b}$ to get the solution
set.

Notice we multiply $A\vec{x} = \vec{b}$ as $A^{-1} A \vec{x} = A^{-1}
\vec{b}$ and not as $A\vec{x} A^{-1} = \vec{b} A^{-1}$ as matrix
multiplication is not commutative and $A\vec{x} A^{-1} \neq A^{-1} A
\vec{x}$.

For example, consider $1x + 2y = 5$ and $3x + 9y = 21$. The initial matrix
equation is $\begin{bmatrix}1 & 2 \\ 3 & 9\end{bmatrix} \begin{bmatrix}x \\ y
\end{bmatrix} = \begin{bmatrix}5 \\ 21\end{bmatrix}$. The inverse of the
coefficient matrix is $\begin{bmatrix}3 & -\frac{2}{3} \\ -1 &
\frac{1}{3}\end{bmatrix}$ so we can re-write our equation as
$\begin{bmatrix}x \\ y\end{bmatrix} = \begin{bmatrix}3 & -\frac{2}{3} \\ -1 &
\frac{1}{3}\end{bmatrix} \begin{bmatrix}5 \\ 21\end{bmatrix}$, so then:

- $x = 5 \cdot 3 + 21 (-\frac{2}{3}) = 15 - 14 = 1$
- $y = -1 \cdot 5 + \frac{1}{3}21 = -5 + 7 = 2$

### Using Determinants (Cramer's Rule)

Given a system of $n$ linear equations with $m$ terms, consider an $n
\times m$ coefficient matrix $C$ and an $\vec{v}$ term vector. The matrix
$C_m$ is the matrix $C$ with the column corresponding to the term $m$
replaced by the term vector. If the coefficient matrix $C$ is
$\begin{bmatrix}c_1 & c_2 \\ c_3 & c_4\end{bmatrix}$ and the term $x$
corresponds to the first column, then $C_x = \begin{bmatrix}v_x & c_2 \\ v_y &
c_4\end{bmatrix}$. The value of $m$ is then $\frac{det(C_m)}{det(C)}$.

For example, consider $1x + 2y = 5$ and $3x + 9y = 21$. The coefficient
matrix is $\begin{bmatrix}1 & 2 \\ 3 & 9 \end{bmatrix}$ and the terms vector
is $\begin{bmatrix}5 \\ 21\end{bmatrix}$. $det(\begin{bmatrix}1 & 2 \\ 3 & 9
\end{bmatrix}) = 3$, so $x = det(\begin{bmatrix} 5 & 2 \\ 21 &
9\end{bmatrix}) \div 3 = 1$ and $y = det(\begin{bmatrix}1 & 5 \\ 3 &
21\end{bmatrix}) \div 3 = 2$.

Eigenvalues and Eigenvectors
----------------------------

The value $\lambda$ is an eigenvalue of $A$ if there exists a vector
$\vec{e}_{\lambda}$ (the corresponding eigenvector of $\lambda$) such that
multiplying $A$ by the vector is equal to scaling the vector by the
eigenvalue: $A \vec{e}_{\lambda} = \lambda \cdot \vec{e}_{\lambda}$.

The list of eigenvalues of $A$ is denoted $eig(A)$ and consists of the list
of $\lambda_i$ such that $\mathcal{N}(A - \lambda_i \mathbb{1}) \neq
\{ \vec{0} \}$. The list of eigenvalues may contain duplicates. A repeated
eigenvalue is *degenerate* and its *algebraic* multiplicity corresponds to the
number of times it appears on the list.

In order to find the eigenvectors of a matrix, calculate the eigenspace
corresponding to each of the eigenvalues of the matrix.

### Eigenspaces

Given matrix $A$ and eigenvalue $\lambda_i$, then $E_{\lambda_i} =
\mathcal{N}(A - \lambda_i \mathbb{1})$ is the eigenspace that
corresponds to the eigenvalue $\lambda_i$. Eigenvectors that come from
different eigenspaces are guaranteed to be linearly independent.

Every eigenspace contains at least one non-zero eigenvector that corresponds to
the eigenvalue, and may contain more than one for degenerate eigenvalues. The
amount of eigenvectors for a single eigenvalue is the *geometric* multiplicity.
A matrix with a degenerate eigenvalue of algebraic multiplicity $n$ but $m
\lt n$ eigenvectors for it has *deficient* geometric multiplicity.

The null space of a matrix $A$ is called the *zero eigenspace* as applying
any vector from the null space to the matrix is equivalent to multiplication by
zero: $\forall \vec{v} \in \mathcal{N}(A) \bullet A \vec{v} = 0 \vec{v} =
\vec{0}$. Notice that the $A \vec{v} = 0 \vec{v}$ part of the expression
corresponds to the eigenvalue equation $A \vec{e}_{\lambda} = \lambda \cdot
\vec{e}_{\lambda}$ where the eigenvalue is 0 and the vectors in the null space
are the eigenvectors.

### Characteristic Polynomial

The characteristic polynomial of a matrix $A$ is a single variable polynomial
whose roots are the eigenvalues of $A$ and it is defined as $p(\lambda) =
det(A - \lambda \mathbb{1})$. Therefore $\lambda$ is an eigenvalue of
$A$ if $det(A - \lambda \mathbb{1}) = 0$. If $A$ is an $n \times
n$ matrix, then its characteristic polynomial has degree $n$.

### Matrices

- Any vector $\vec{v}$ is an eigenvector of the *identity matrix*
  corresponding to its eigenvalue $\lambda = 1$
- All the eigenvalues of a *positive semidefinite* matrix are greater or equal
  than zero
- All the eigenvalues of a *positive definite* matrix are greater than zero
- A matrix $A$ is invertible if there is a $\lambda$ such that $det(A -
  \lambda \mathbb{1}) = 0$
- An $n \times n$ matrix is diagonalizable if it has $n$ eigenvalues (which
  means it has at least $n$ eigenvectors)
- Given a *normal* matrix $A$, $\vec{v}$ is an eigenvector of $A$ iff
  $\vec{v}$ is an eigenvector of $A^T$

Notice that matrix determinants and traces are operations strictly defined on
the eigenvalues of a matrix, as $det(A) = \prod_i \lambda_i$ and $Tr(A) =
\sum_i \lambda_i$:

$$
\begin{align}
det(A) &= det(Q \Lambda Q^{-1}) \\
&= det(Q) det(\Lambda) det(Q^{-1}) \\
&= det(Q) det(Q^{-1}) det(\Lambda) \\
&= \frac{det(Q)}{det(Q)} det(\Lambda) \\
&= 1 \cdot det(\Lambda) \\
&= det(\Lambda) \\
&= \prod_i \lambda_i
\end{align}
$$

$$
\begin{align}
Tr(A) &= Tr(Q \Lambda Q^{-1}) \\
&= Tr(\Lambda Q^{-1} Q) \\
&= Tr(\Lambda \mathbb{1}) \\
&= Tr(\Lambda) \\
&= \sum_i \lambda_i
\end{align}
$$

The statements $det(A) \neq 0$ and $\mathcal{N}(A) = \{ \vec{0} \}$ are
equivalent. We know that $det(A) = \prod_i \lambda_i$, so $det(A) \neq 0$
implies that none of the eigenvalues are zero, otherwise the product would be
cancelled out. Because none of the eigenvalues are zero, then the only solution
to $A\vec{x} = \vec{0}$ is $\vec{0}$, so $\mathcal{N}(A) = \{ \vec{0}
\}$.

Eigenbases
----------

The diagonalizable version of a matrix $A$, which consists of the eigenvalues
of $A$ in the diagonal, corresponds to $A$ expressed in its eigenbasis (the
natural basis).

A matrix $Q$ from whose columns are the eigenvectors of $A$ is a
change-of-basis operation *from* the eigenbasis of $A$. Therefore $Q^{-1}$
is a change-of-basis operation *to* the eigenbasis of $A$. Notice that $Q$
may contain the eigenvectors in any order and with any scaling factor.

Eigendecomposition
------------------

Given a linear transformation matrix representation $A$, the
eigendecomposition of $A$ expresses the transformation $A$ in the
eigenbasis of $A$ using change-of-basis operations.

We can express any transformation $A$ as $Q \Lambda Q^{-1}$ where $Q$ is
a change-of-basis matrix containing the eigenvectors of $A$ as columns and
$\Lambda$ is $A$ expressed on its eigenbasis (containing the eigenvalues in
the diagonal).

Every *normal* matrix $N$ has a corresponding *orthogonal* matrix $O$ such
that its eigendecomposition is $N = O \Lambda O^{T}$, as for orthogonal
matrices $O^{T} = O^{-1}$.

Applying the transformation on $\vec{v}$ is equivalent to saying $Q \Lambda
Q^{-1} \vec{v}$ which first changes the basis of $\vec{v}$ to the eigenbasis
of $A$, applies the transformation, and changes the basis back again.

For example, consider $A = \begin{bmatrix}9 & -2 \\ -2 & 6\end{bmatrix}$. Its
eigenvalues are $eig(A) = \{ 5, 10 \}$ and we can find out the corresponding
eigenvectors as follows:

$\mathcal{N}(\begin{bmatrix}9 & -2 \\ -2 & 6\end{bmatrix} - 5 \begin{bmatrix}1
& 0 \\ 0 & 1\end{bmatrix}) = \mathcal{N}(\begin{bmatrix}4 & -2 \\ -2 &
1\end{bmatrix}) = \{ \vec{0}, \begin{bmatrix}\frac{1}{2} \\ 1\end{bmatrix} \}$

So we know that the eigenvector for 5 is $\begin{bmatrix}\frac{1}{2} \\
1\end{bmatrix}$ and

$\mathcal{N}(\begin{bmatrix}9 & -2 \\ -2 & 6\end{bmatrix} - 10 \begin{bmatrix}1
& 0 \\ 0 & 1\end{bmatrix}) = \mathcal{N}(\begin{bmatrix}-1 & -2 \\ -2 &
-4\end{bmatrix}) = \{ \vec{0}, \begin{bmatrix}-2 \\ 1\end{bmatrix} \}$

So the eigenvector for 10 is $\begin{bmatrix}-2 \\ 1\end{bmatrix}$. Therefore
we can say that $\begin{bmatrix}9 & -2 \\ -2 & 6\end{bmatrix} =
\begin{bmatrix}\frac{1}{2} & -2 \\ 1 & 1\end{bmatrix} \begin{bmatrix}5 & 0 \\ 0
& 10\end{bmatrix} \begin{bmatrix}\frac{2}{5} & \frac{4}{5} \\ -\frac{2}{5} &
\frac{1}{5}\end{bmatrix}$.
