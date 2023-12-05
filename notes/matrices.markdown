---
title: Matrices
description: A matrix is a bi-dimensional rectangular array of expressions arranged in rows and columns
---

An $m \times n$ matrix has $m$ rows and $n$ columns. Given a matrix
$A$, the notation $a_{i,j} \in A$ refers to the element of $A$ in the
$i$th row and the $j$th column, counting from the top and from the left,
respectively.

Binary Operations
-----------------

### Addition

$$\begin{bmatrix}
x_1 & x_3 \\
x_2 & x_4
\end{bmatrix} + \begin{bmatrix}
y_1 & y_3 \\
y_2 & y_4
\end{bmatrix} = \begin{bmatrix}
x_1 + y_1 & x_3 + y_3 \\
x_2 + y_2 & x_4 + y_4
\end{bmatrix}$$

### Substraction

$$\begin{bmatrix}
x_1 & x_3 \\
x_2 & x_4
\end{bmatrix} - \begin{bmatrix}
y_1 & y_3 \\
y_2 & y_4
\end{bmatrix} = \begin{bmatrix}
x_1 - y_1 & x_3 - y_3 \\
x_2 - y_2 & x_4 - y_4
\end{bmatrix}$$

### Scaling (Scalar Multiplication)

Given constant $\alpha$:

$$\alpha \begin{bmatrix}
x_1 & x_3 \\
x_2 & x_4
\end{bmatrix} = \begin{bmatrix}
\alpha x_1 & \alpha x_3 \\
\alpha x_2 & \alpha x_4
\end{bmatrix}$$

### Vector Dot Product (or Inner Product)

Denoted $A . B$ or $\langle A, B \rangle$ given two vectors
$A$ and $B$.

$$\begin{bmatrix}
x_1 \\
y_1 \\
z_1
\end{bmatrix} . \begin{bmatrix}
x_2 \\
y_2 \\
z_2
\end{bmatrix} = x_1 x_2 + y_1 y_2 + z_1 z_2$$

Note that the vectors must have the same number of rows, and that the result of
a dot product is a scalar.

Two vectors $v_1$ and $v_2$ are *orthogonal* if $v_1 . v_2 =
0$.

Vector dot product of $u$ and $v$ is equivalent to the matrix product of
$u^{T}$ and $v$:

$$\begin{bmatrix}
x_1 \\
y_1 \\
z_1
\end{bmatrix} . \begin{bmatrix}
x_2 \\
y_2 \\
z_2
\end{bmatrix} =
\begin{bmatrix}
x_1 \\
y_1 \\
z_1
\end{bmatrix}^{T} \begin{bmatrix}
x_2 \\
y_2 \\
z_2
\end{bmatrix} =
\begin{bmatrix}
x_1 & y_1 & z_1
\end{bmatrix}^{T} \begin{bmatrix}
x_2 \\
y_2 \\
z_2
\end{bmatrix} = x_1 x_2 + y_1 y_2 + z_1 z_2$$

### Vector Outer Product

Given two vectors $u$ and $v$ with the same number of elements, the outer
product between them is $u \oplus v = u v^{T}$, where the result is always a
square matrix:

$$
\begin{bmatrix}
x_1 \\
y_1 \\
z_1
\end{bmatrix} \oplus \begin{bmatrix}
x_2 \\
y_2 \\
z_2
\end{bmatrix} = \begin{bmatrix}
x_1 \\
y_1 \\
z_1
\end{bmatrix} \begin{bmatrix}
x_2 & y_2 & z_2
\end{bmatrix} =
\begin{bmatrix}
x_1 x_2 & x_1 y_2 & x_1 z_2 \\
y_1 x_2 & y_1 y_2 & y_1 z_2 \\
z_1 x_2 & z_1 y_2 & z_1 z_2
\end{bmatrix}
$$

### Vector Product (or Cross Product)

$$\begin{bmatrix}
x_1 \\
y_1 \\
z_1
\end{bmatrix} \times \begin{bmatrix}
x_2 \\
y_2 \\
z_2
\end{bmatrix} = \begin{bmatrix}
y_1 z_2 - z_1 y_2 \\
z_1 x_2 - x_1 z_2 \\
x_1 y_2 - y_1 x_2
\end{bmatrix}$$

Note that the vectors must have the same number of rows, and that the result of
a cross product is another vector of the same number of rows.

Cross product is not commutative: $A \times B \neq B \times A$.

### Matrix-Vector Multiplication

Given matrix $A$ and vector $B$, the number of columns in $A$ must equal
the number of rows in $B$:

$$\begin{bmatrix}
x_1 & x_4 \\
x_2 & x_5 \\
x_3 & x_6
\end{bmatrix} \begin{bmatrix}
p \\
q
\end{bmatrix} = p \begin{bmatrix}
x_1 \\
x_2 \\
x_3
\end{bmatrix} + q \begin{bmatrix}
x_4 \\
x_5 \\
x_6
\end{bmatrix} = \begin{bmatrix}
p x_1 \\
p x_2 \\
p x_3
\end{bmatrix} + \begin{bmatrix}
q x_4 \\
q x_5 \\
q x_6
\end{bmatrix} = \begin{bmatrix}
p x_1 + q x_4 \\
p x_2 + q x_5 \\
p x_3 + q x_6
\end{bmatrix}$$

The resulting matrix has the same number of rows as $A$, but only 1 column.

Note that the following addition is a linear combination: $p \begin{bmatrix}
x_1 \\
x_2 \\
x_3
\end{bmatrix} + q \begin{bmatrix}
x_4 \\
x_5 \\
x_6
\end{bmatrix}$

Notice that given matrices $A$ and vectors $x$ and $y$, $A^{T} x = y$
is equivalent to $x^{T} A = y^{T}$.

### Matrix Multiplication

Given matrices $A$ and $B$, the number of columns in $A$ must match the
number of rows in $B$.

$$\begin{bmatrix}
x_1 & x_4 \\
x_2 & x_5 \\
x_3 & x_6
\end{bmatrix} \begin{bmatrix}
y_1 & y_3 \\
y_2 & y_4
\end{bmatrix} = \begin{bmatrix}
x_1 y_1 + x_4 y_2 & x_1 y_3 + x_4 y_4 \\
x_2 y_1 + x_5 y_2 & x_2 y_3 + x_5 y_4 \\
x_3 y_1 + x_6 y_2 & x_3 y_3 + x_6 y_4
\end{bmatrix}$$

Note that matrix multiplication is associative: $(AB)C = A(BC) = ABC$ but its
*not* commutative: $AB \neq BA$.

Multiplying a $1 \times m$ matrix with a $m \times m$ matrix looks like
this:

$$\begin{bmatrix}
a & b
\end{bmatrix} \begin{bmatrix}
x_1 & x_3 \\
x_2 & x_4
\end{bmatrix} = \begin{bmatrix}
a x_1 + b x_3 & a x_2 + b x_4
\end{bmatrix}$$

### Scalar Division

Given constant $\alpha$:

$$\begin{bmatrix}
x_1 & x_3 \\
x_2 & x_4
\end{bmatrix} \div \alpha = \begin{bmatrix}
\frac{x_1}{\alpha} & \frac{x_3}{\alpha} \\
\frac{x_2}{\alpha} & \frac{x_4}{\alpha}
\end{bmatrix}$$

### Matrix Division

Dividing $A / B$ is the same as multiplying $A$ by the inverse of $B$:
$A / B = A(B^{-1})$.

Unary Operations
----------------

### Trace

The trace of a square matrix its the sum of its diagonal, and its defined as
$Tr(A) = \sum_{i = 1}^{n} A_{i,i}$. For example:

$$Tr(\begin{bmatrix}
5 & 9 & -2 \\
8 & 3 & 1 \\
-1 & 0 & 6
\end{bmatrix}) = 5 + 3 + 6$$

Given constant $\alpha$, then $Tr(\alpha A + \alpha B) = \alpha Tr(A) +
\alpha Tr(B)$. The trace function is commutative and associative: $Tr(AB) =
Tr(BA)$, and $Tr(ABC) = Tr(CAB) = Tr(BCA)$. Also $Tr(A^{T}) = Tr(A)$.

### Vector Norm (length)

Given vector $X = \begin{bmatrix}x_1 \\ x_2 \\ x_3 \end{bmatrix}$, the norm
of $X$ is the absolute value: $\parallel X \parallel =
\sqrt{x_1^2 + x_2^2 + x_3^2}$, which is also equal to the square root of the
dot product of $X$ with itself: $\sqrt{\langle X, X \rangle}$.

### Unit Vector

The unit vector of vector $v$ is $v$ divided by its norm: $\hat{v} =
\frac{v}{\parallel v \parallel}$.

### Minor

The minor of an entry $a_{i,j}$ of a square matrix $A$ is the determinant
of the square submatrix of $A$ when the $i$ row and $j$ column (indexed
by 1) are removed, and is denoted $M_{i,j}$. For example, given:
$\begin{bmatrix} a & b & c \\ d & e & f \\ g & h & i \end{bmatrix}$, its
minor $M_{2,3}$ is $det(\begin{bmatrix} a & b \\ g & h \end{bmatrix})$.

### Cofactor

The cofactor of an entry $a_{i,j}$ of a square matrix $A$ is denoted
$C_{i,j}$ or $cofactor(a_{i,j})$, and is defined as the entry's minor with
alternating sign depending on the indexes: $C_{i,j} = (-1)^{i+j} M_{i,j}$.

### Adjugate

The adjugate matrix of $n \times m$ matrix $A$ is another $n \times m$
where every entry of $A$ is replaced by its cofactor.

For example, $adj(\begin{bmatrix}2 & 3 \\ 2 & 2\end{bmatrix}) =
\begin{bmatrix} C_{1,1} & C_{1,2} \\ C_{2,1} & C_{2,2} \end{bmatrix} =
\begin{bmatrix}2 & -3 \\ -2 & 2\end{bmatrix}$ as:

- $C_{1,1} = (-1)^{1+1} det(\begin{bmatrix} 2 \end{bmatrix}) = (-1)^2 \cdot 2
  = 1 \cdot 2 = 2$
- $C_{1,2} = (-1)^{1+2} det(\begin{bmatrix} 3 \end{bmatrix}) = (-1)^3 \cdot 3
  = -1 \cdot 3 = -3$
- $C_{2,1} = (-1)^{2+1} det(\begin{bmatrix} 2 \end{bmatrix}) = (-1)^3 \cdot 2
  = -1 \cdot 2 = -2$
- $C_{2,2} = (-1)^{2+2} det(\begin{bmatrix} 2 \end{bmatrix}) = (-1)^4 \cdot 2
  = 1 \cdot 2 = 2$

### Determinant

The determinant of a square matrix $A$ is a scalar denoted $det(A)$ or
$|A|$.

The determinant of a $1 \times 1$ matrix is the element itself:
$det(\begin{bmatrix}x\end{bmatrix}) = x$.  Given a $2 \times 2$ matrix:
$det(\begin{bmatrix} a & b \\ c & d \end{bmatrix}) = ad - bc$.  For $3
\times 3$ and larger matrices $A$, the determinant is defined recursively:
$det(A) = \sum_{j=1}^n A_{1,j} M_{1,j}$ where $n$ is the number of columns
in $A$.

The following laws hold given two square matrices $A$ and $B$:

- $det(AB) = det(A) det(B)$
- $det(AB) = det(BA)$
- $det(A^{T}) = det(A)$
- $det(A^{-1}) = \frac{1}{det(A)}$
- $det(\alpha A) = \alpha^{n} det(A)$ where $n$ is the number of rows in
  $A$

The rows of a matrix $A$ are linearly independent if $det(A) \neq 0$. We
can say $det(A) = 0$ if any of the rows of $A$ is all zeroes. Also, matrix
$A$ is *not* invertible if $det(A) \neq 0$. If $det(A) = 0$ then $A$ is
*deficient*, and *full* otherwise.

Given row operations:

- Adding a multiple of one row to another row doesn't change the determinant of
  the matrix
- Swapping rows changes the sign of the determinant
- Multiplying a row by a constant is equal to multiplying the determinant by
  the same constant

Considering RREF, given square matrix $A$, then $det(A) \neq 0$ implies
that $rref(A) = \mathbb{1}$. Also, if $det(A) \neq 0$, then
$det(rref(A)) \neq 0$, and conversely, if $det(A) = 0$, then $det(rref(A))
= 0$.

### Inverse

A matrix $A^{-1}$ is the inverse of matrix $A$ if either $A (A^{-1}) =
\mathbb{1}$ or $(A^{-1}) A = \mathbb{1}$.

The [Invertible Matrix
Theorem](https://en.wikipedia.org/wiki/Invertible_matrix#The_invertible_matrix_theorem)
states that for any *square* matrix $n \times n$, the following statements
are either all true or all false:

- $A$ is invertible
- $A^{T}$ is invertible
- $Ax = b$ has exactly one solution for any $n$ dimensional vector $b$
- The null space of $A$ only contains the zero vector: $\mathcal{N}(A) = \{
  0 \}$
- $Ax = 0$ only has solution $x = 0$
- The rank of $A$ is $n$
- The determinant of $A$ is non zero: $det(A) \neq 0$
- The RREF of $A$ is the $n$ dimensional identity matrix
- The columns of $A$ are linearly independent
- The rows of $A$ are linearly independent

The following laws hold, given two invertible matrices $A$ and $B$:

- $(A + B)^{-1} = A^{-1} + B^{-1}$
- $(AB)^{-1} = B^{-1} A^{-1}$
- $(ABC)^{-1} = C^{-1} B^{-1} A^{-1}$
- $(A^{T})^{-1} = (A^{-1})^{T}$

#### Using Adjugates

We can calculate the inverse of an $n \times n$ square matrix $A$ using its
adjugate and determinant as follows:

$$
A^{-1} = \frac{1}{det(A)} \cdot adj(A)
$$

For example, given $\begin{bmatrix}2 & 3 \\ 2 & 2\end{bmatrix}$, we know its
adjugate is $\begin{bmatrix}2 & -3 \\ -2 & 2\end{bmatrix}$ and its
determinant is $2 \cdot 2 - 3 \cdot 2 = 4 - 6 = -2$, so $A^{-1} =
\begin{bmatrix}2 & -3 \\ -2 & 2\end{bmatrix} \div -2 =
\begin{bmatrix}\frac{2}{-2} & \frac{-3}{-2} \\ \frac{-2}{-2} &
\frac{2}{-2}\end{bmatrix} = \begin{bmatrix}-1 & \frac{3}{2} \\ 1 &
-1\end{bmatrix}$.

Which we can check as:

$$
\begin{bmatrix}
-1 & \frac{3}{2} \\
1 & -1
\end{bmatrix} \begin{bmatrix}
2 & 3 \\
2 & 2
\end{bmatrix} = \begin{bmatrix}
-1 \cdot 2 + \frac{3}{2} \cdot 2 & -1 \cdot 3 + \frac{3}{2} \cdot 2 \\
1 \cdot 2 + -1 \cdot 2 & 1 \cdot 3 + -1 \cdot 2
\end{bmatrix} = \begin{bmatrix}
1 & 0 \\
0 & 1
\end{bmatrix}
$$

#### Using Gauss-Jordan Elimination

We can calculate the inverse of an $n \times n$ square matrix $A$ by
creating an $n \times 2n$ matrix that contains $A$ at the left and
$\mathbb{1}$ at the right:

Given $\begin{bmatrix}2 & 3 \\ 2 & 2\end{bmatrix}$, the matrix is then
$\begin{bmatrix} 2 & 3 & 1 & 0 \\ 2 & 2 & 0 & 1 \end{bmatrix}$.

Calculate the RREF of the matrix:

$rref(\begin{bmatrix} 2 & 3 & 1 & 0 \\ 2 & 2 & 0 & 1 \end{bmatrix}) =
\begin{bmatrix} 1 & 0 & -1 & \frac{3}{2} \\ 0 & 1 & 1 & -1 \end{bmatrix}$

The left side of the RREF should be the identity matrix (otherwise the matrix
is not invertible) and the right side contains the inverse:

$$
\begin{bmatrix}
2 & 3 \\ 2 & 2
\end{bmatrix}^{-1} = \begin{bmatrix}
-1 & \frac{3}{2} \\
1 & -1
\end{bmatrix}
$$

Which we can check as:

$$
\begin{bmatrix}
-1 & \frac{3}{2} \\
1 & -1
\end{bmatrix} \begin{bmatrix}
2 & 3 \\
2 & 2
\end{bmatrix} = \begin{bmatrix}
-1 \cdot 2 + \frac{3}{2} \cdot 2 & -1 \cdot 3 + \frac{3}{2} \cdot 2 \\
1 \cdot 2 + -1 \cdot 2 & 1 \cdot 3 + -1 \cdot 2
\end{bmatrix} = \begin{bmatrix}
1 & 0 \\
0 & 1
\end{bmatrix}
$$

### Transpose

Matrix transpose flips a matrix by its diagonal, and its denoted $A^{T}$ for
a matrix $A$.

- Given a $1 \times 1$ matrix: $\begin{bmatrix}1\end{bmatrix}^{T} =
  \begin{bmatrix}1\end{bmatrix}$
- Given a $1 \times 2$ matrix: $\begin{bmatrix}1 & 2\end{bmatrix}^{T} =
  \begin{bmatrix}1 \\ 2\end{bmatrix}$
- Given a $2 \times 1$ matrix: $\begin{bmatrix}1 \\ 2\end{bmatrix}^{T} =
  \begin{bmatrix}1 & 2\end{bmatrix}$
- Given a square matrix: $\begin{bmatrix}1 & 2 \\ 3 & 4\end{bmatrix}^{T} =
  \begin{bmatrix}1 & 3 \\ 2 & 4\end{bmatrix}$
- Given a $3 \times 2$ matrix: $\begin{bmatrix} 1 & 2 \\ 3 & 4 \\ 5 & 6
  \end{bmatrix}^{T} = \begin{bmatrix} 1 & 3 & 5 \\ 2 & 4 & 6 \end{bmatrix}$

The following laws hold, given $A$ and $B$:

- $(A + B)^{T} = A^{T} + B^{T}$
- $(AB)^{T} = B^{T} A^{T}$
- $(ABC)^{T} = C^{T} B^{T} A^{T}$
- $(A^{T})^{-1} = (A^{-1})^{T}$
- $(A^{T})^{T} = A$

### Rank

The rank of a matrix $A$, denoted $rank(A)$ is a scalar that equals the
number of pivots in the RREF of $A$. More formally, is the dimension of
either the row or column spaces of $A$: $rank(A) = dim(\mathcal{R}(A)) =
dim(\mathcal{C}(A))$. Basically, the rank describes the number of linearly
independent rows or columns in a matrix.

### Nullity

The nullity of a matrix $A$, denoted $nullity(A)$, is the number of
linearly independent vectors in the null space of $A$: $nullity(A) =
dim(\mathcal{N}(A))$.

Row Echelon Form
----------------

The first non-zero element of a matrix row is the *leading coefficient* or
*pivot* of the row. A matrix is in row echelon form (REF) if:

- The leading coefficients of all rows are at the right of the leading
  coefficients of the rows above
- All rows containing all zeroes are below the rows with leading coefficients

For example: $\begin{bmatrix} 3 & 1 & 0 & 1 \\ 0 & 2 & 2 & 0 \\ 0 & 0 & 0 & 7
\\ 0 & 0 & 0 & 0 \end{bmatrix}$.

The process of bringing a matrix to row echelon form is called *Gaussian
Elimination*. Starting with the first row:

- Obtain a leading coefficient 1 in the row by either:
  - Swapping the current row with any of the rows below
  - Dividing or multiplying the row vector by a constant
- Subtract or add the row one or more times to the rows below to zero out the
  leading coefficient column in all the rows below
- Repeat the process with the row below

For example, given $\begin{bmatrix} 1 & 2 & 3 \\ 4 & 5 & 6 \\ 7 & 8 & 9
\end{bmatrix}$, the leading coefficient of the first row is already 1, so we
can move on. The value below the first leading coefficient is 4, so we can
multiply the first vector by 4 and substract it from the second row: $(4, 5,
6) - 4 (1, 2, 3) = (0, -3, -6)$ so the matrix is now $\begin{bmatrix} 1 & 2 &
3 \\ 0 & -3 & -6 \\ 7 & 8 & 9 \end{bmatrix}$. The leading coefficient of the
third row is 7, so we can multiply the first row by 7 and substract it from the
third row: $(7, 8, 9) - 7 (1, 2, 3) = (0, -6, -12)$ so the matrix is now:
$\begin{bmatrix} 1 & 2 & 3 \\ 0 & -3 & -6 \\ 0 & -6 & -12 \end{bmatrix}$. The
entries below the first row's leading coefficient are zero, so we can move on
to the second row, which we can divide by -3 to make its leading coefficient 1:
$(0, -3, -6) \div -3 = (0, 1, 2)$, so the matrix is now: $\begin{bmatrix} 1
& 2 & 3 \\ 0 & 1 & 2 \\ 0 & -6 & -12 \end{bmatrix}$. The coefficient below the
second row's leading coefficient is -6, so we can add the second row multiplied
by 6 to it: $(0, -6, -12) + 6 (0, 1, 2) = (0, 0, 0)$ so the matrix is now:
$\begin{bmatrix} 1 & 2 & 3 \\ 0 & 1 & 2 \\ 0 & 0 & 0 \end{bmatrix}$ and is in
row echelon form as the third row is all zeroes.

### Reduced Row Echelon Form

A matrix is in reduced row echelon form (RREF) if:

- It is in row echelon form (REF)
- The leading coefficients of all non-zero rows are 1
- All the entries above and below a pivot are zero for that column

The process of bringing a matrix to row echelon form is called *Gaussian-Jordan
Elimination*. Starting with the last row with a pivot:

- Add or subtract the row one or more times to the rows above it to zero out
  the entries above the pivot in that column
- Repeat the process with the row above

For example, given $\begin{bmatrix} 1 & 2 & 3 \\ 0 & 1 & 2 \\ 0 & 0 & 0
\end{bmatrix}$, the last row with a pivot is the second row. The entry above
the leading coefficient is 2, so we can multiply the second row by 2 and
substract it from the first row: $(1, 2, 3) - 2 (0, 1, 2) = (1, 0, -1)$, so
the matrix is now: $\begin{bmatrix} 1 & 0 & -1 \\ 0 & 1 & 2 \\ 0 & 0 & 0
\end{bmatrix}$ and is in reduced row echelon form. There is no pivot in the
third column, so the last elements of the first and second rows don't need to
be zeroed out.

Vector Spaces
-------------

The following vector spaces are the *fundamental vector spaces* of a matrix.
Assume an $m \times n$ matrix $M$.

### Left Space

The set of all vectors $v$ that can multiply $M$ from the left. Basically
the vectors $v$ where $v M$ is a valid operation. Given an $m \times n$
matrix $M$, its left space is $m$ dimensional.

Any element $v$ from the left space can be written as the sum of a vector
from the column space and a vector from the left null space:

$$\forall v \bullet (\exists w \bullet w = v M) \implies (\exists c \in
\mathcal{C}(M), n \in \mathcal{N}(M^{T}) \bullet v = c + n)$$

### Right Space

The set of all vectors $v$ that can multiply $M$ from the right. Basically
the vectors $v$ where $M v$ is a valid operation. Given an $m \times n$
matrix $M$, its right space is $n$ dimensional.

Any element $v$ from the right space can be written as the sum of a vector
from the row space and a vector from the null space:

$$\forall v \bullet (\exists w \bullet w = M v) \implies (\exists r \in
\mathcal{R}(M), n \in \mathcal{N}(M) \bullet v = r + n)$$

### Row Space

The span of the rows of matrix $M$: $\mathcal{R}(M)$. Note that
$\mathcal{R}(M) = \mathcal{R}(rref(M))$. Defined as $\mathcal{R}(M) = \{ v
\mid \exists w \bullet v = w^{T} M \}$.

### Column Space

The span of the columns of matrix $M$: $\mathcal{C}(M)$. Defined as
$\mathcal{C}(M) = \{ w \mid \exists v \bullet w = Mv \}$.

### (Right) Null Space

The set of vectors $v$ where $M . v$ is the zero vector: $\mathcal{N}(M) =
\{ v \mid Mv = 0 \}$. It always contains the zero vector. Sometimes called the
*kernel* of the matrix.

Given matrix $M$ with a null space containing more than the zero vector, then
the equation $Mx = y$ has infinite solutions, as the rows in $M$ would not
be linearly independent, and given a solution $x$, we can add any member of
the null space and it would still be a valid solution.

For example, consider $M = \begin{bmatrix}1 & -2 \\ -2 & 4\end{bmatrix}$. Its
null space consists of $\begin{bmatrix}2 \\ 1\end{bmatrix}$ and any linear
combination of such vector, including the zero vector. Then consider the
equation $M \begin{bmatrix}x \\ y\end{bmatrix} = \begin{bmatrix}-1 \\
2\end{bmatrix}$. A valid solution is $\begin{bmatrix}5 \\ 3\end{bmatrix}$ as
$5 \cdot 1 + 3 \cdot (-2) = -1$ and $5 \cdot (-2) + 3 \cdot 4 = 2$. But
then another valid solution is $\begin{bmatrix}5 \\ 3\end{bmatrix} +
\begin{bmatrix}2 \\ 1\end{bmatrix} = \begin{bmatrix}7 \\ 4\end{bmatrix}$ as
$7 \cdot 1 + 4 \cdot (-2) = -1$ and $7 \cdot (-2) + 4 \cdot 4 = 2$. Same
for any $\begin{bmatrix}5 \\ 3\end{bmatrix} + \alpha \begin{bmatrix}2 \\
1\end{bmatrix}$ given any constant $\alpha$.

If the null space of $M$ only contains the zero vector, then $Mx = y$ has
exactly one solution, as that solution is $x$ plus any member of the vector
space, which is only the zero vector, and $x$ plus the zero vector is just
$x$.

### Left Null Space

The set of vectors $v$ where $M^{T} . v$ is the zero vector. It is denoted
as the (right) null space of the transpose of the input vector:
$\mathcal{N}(M^{T}) = \{ v \mid M^{T}v = 0 \}$, or similarly:
$\mathcal{N}(M^{T}) = \{ v \mid v^{T}M = 0 \}$.

Similarity Transformations
--------------------------

We say that matrices $M$ and $N$ are related by a *similarity
transformation* if there exists an invertible matrix $P$ such that: $M =
(P)(N)(P^{-1})$.

If the above holds, then the following statements hold as well:

- $Tr(M) = Tr(N)$
- $det(M) = det(N)$
- $rank(M) = rank(N)$
- $eig(M) = eig(N)$

Special Matrices
----------------

### Identity Matrix

The identity matrix $\mathbb{1}$ is a square matrix with 1's in the
diagonal and 0's elsewhere. The $3 \times 3$ identity matrix is:

$$\begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix}$$.

Given a square and invertible matrix $M$, then $(M^{-1})(M) =
\mathbb{1} = (M)(M^{-1})$. The identity matrix is *symmetric* and
*positive semidefinite*.

Multiplying the $n \times n$ identity matrix with a $n$ dimensional vector
is equal to the same vector. Basically $\mathbb{1} v = v$ for any
vector $v$.

$$\mathbb{1}_3 \begin{bmatrix}
x_1 \\ x_2 \\ x_3
\end{bmatrix} = \begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix} \begin{bmatrix}
x_1 \\ x_2 \\ x_3
\end{bmatrix} = \begin{bmatrix}
1 x_1 + 0 x_2 + 0 x_3 \\
0 x_1 + 1 x_2 + 0 x_3 \\
0 x_1 + 0 x_2 + 1 x_3
\end{bmatrix} = \begin{bmatrix}
x_1 \\ x_2 \\ x_3
\end{bmatrix}$$

### Elementary Matrices

Every row or column operation that can be performed on a matrix, such as a row
swap, can be expressed as left multiplication by special matrices called
*elementary matrices*.

For example, given a $2 \times 2$ matrix $\begin{bmatrix}1 & 2 \\ 3 &
4\end{bmatrix}$, the elementary matrix to swap the first and second rows is
$\begin{bmatrix}0 & 1 \\ 1 & 0\end{bmatrix}$ as:

$$
\begin{bmatrix}
0 & 1 \\
1 & 0
\end{bmatrix} \begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix} = \begin{bmatrix}
0 \cdot 1 + 1 \cdot 3 & 0 \cdot 2 + 1 \cdot 4 \\
1 \cdot 1 + 0 \cdot 3 & 1 \cdot 2 + 0 \cdot 4
\end{bmatrix} = \begin{bmatrix}
1 \cdot 3 & 1 \cdot 4 \\
1 \cdot 1 & 1 \cdot 2
\end{bmatrix} = \begin{bmatrix}
3 & 4 \\
1 & 2
\end{bmatrix}
$$

In order to find elementary matrices, we can perform the desired operation on
the identity matrix. In the above case, we can build a $2 \times 2$ identity
matrix $\begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}$ and then swap the rows:
$\begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}$.

Some more $2 \times 2$ elementary matrices examples:

- Add $m$ times the second row to the first row: $\begin{bmatrix} 1 & m \\ 0
  & 1 \end{bmatrix}$
- Multiply the first row $m$ times: $\begin{bmatrix}m & 0 \\ 0 &
  1\end{bmatrix}$

### Diagonal Matrices

A diagonal matrix is a *square* matrix with values on the diagonal and zeroes
everywhere else, such as: $A = \begin{bmatrix} x_1 & 0 & 0 & 0 \\ 0 & x_2 & 0
& 0 \\ 0 & 0 & x_3 & 0 \\ 0 & 0 & 0 & x_4 \end{bmatrix}$. The values on the
diagonal are the *eigenvalues* of $A$: $eig(A) = \{ x_1, x_2, x_3, x_4 \}$.

An $n \times n$ matrix is only diagonalizable if it has $n$ eigenvalues.
All normal matrices are diagonalizable.

Properties
----------

### Normal

A matrix $A$ is *normal* if $A^{T} A = A A^{T}$

### Orthogonal

A matrix $A$ is *orthogonal* if $A^{T} A = A A^{T} = \mathbb{1}$,
which means that $A^{-1} = A^{T}$. All orthogonal matrices are normal. The
determinant of an orthogonal matrix is always -1 or 1.

### Symmetric

A matrix $A$ is *symmetric* if $A^{T} = A$. All symmetric matrices are
normal. Notice that given any $n \times m$ matrix $A$, the matrix $A^{T}
A$ is always symmetric.

### Upper Triangular

A matrix $A$ is *upper triangular* if it contains zeroes below the diagonal,
such as $\begin{bmatrix} a & b & c & d \\ 0 & e & f & g \\ 0 & 0 & h & i \\ 0
& 0 & 0 & j \end{bmatrix}$.

### Square

An $n \times m$ matrix $A$ is a *square* matrix if $n = m$. A trick to
convert a non-square matrix into a square matrix is multiply it by its
transpose:

- $A A^{T}$ has the same column space as $A$: $\mathcal{C}(A A^{T}) =
  \mathcal{C}(A)$
- $A^{T} A$ has the same row space as $A$: $\mathcal{R}(A^{T} A) =
  \mathcal{R}(A)$

### Positive Semidefinite

A matrix $A$ is *positive semidefinite* if $\forall \vec{v} \bullet
(\vec{v}^{T} A \vec{v}) \geq 0$.

For example, conside $A = \begin{bmatrix}1 & 0 \\ 0 & 1\end{bmatrix}$ and let
$\vec{v} = \begin{bmatrix} x \\ y \end{bmatrix}$, then:

$$\begin{bmatrix}x & y\end{bmatrix} \begin{bmatrix}1 & 0 \\ 0 & 1\end{bmatrix}
\begin{bmatrix} x \\ y \end{bmatrix} = \begin{bmatrix}x + 0y & 0x +
y\end{bmatrix} \begin{bmatrix} x \\ y \end{bmatrix} = x^2 + y^2$$

Both $x^2 \geq 0$ and $y^2 \geq 0$, so $A$ is positive semidefinite.

### Positive Definite

A matrix $A$ is *positive definite* if $\forall \vec{v} \bullet
(\vec{v}^{T} A \vec{v}) \gt 0$.
