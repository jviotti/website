---
title: An overview of arrays in Ada 2012
date: November 18, 2017
image: generic.jpg
description: This article is an overview of array types in Ada 2012
---

Arrays are one of the foundational programming constructs. Ada has rich
mechanisms to declare arrays, but these might not be obvious for engineers
coming from other programming languages. This post will describe the possible
ways to declare array types in Ada 2012.

Introduction
------------

The basic form to declare arrays in Ada looks like this:

```ada
type My_New_Array_Type is array (0 .. 5) of My_Array_Element_Type;
```

Here we declare a new array type called `My_New_Array_Type`, which is an array
of 6 elements of the *definite* type `My_Array_Element_Type`. The indexes of
the array go from 0 to 5, inclusive.

The bounds of an array don't have to be constant; we can control them by using
other identifiers on the scope. For example:

```ada
Start: Integer := 0;
Stop: Integer := 5;
type My_New_Array_Type is array (Start .. Stop) of Integer;
```

Instantiation
-------------

Keep in mind that the `type` keyword introduces a new type of array, but to
make use of it, we need to instantiate it:

```ada
type My_Array is array (1 .. 5) of Integer;
X: My_Array;
```

At this point, we can access the elements of `X` by using statements such as
`X(1)` and `X(5)`. Note that when instantiating an array, its values are not
defined (unless we use the `Default_Component_Value` aspect), and referencing
such elements will result in at least a compiler warning.

We can set a default value during instantiation by using aggregates. For
example:

```ada
type My_Array is array (1 .. 3) of Integer;
```

We can manually declare values for each of the elements:

```ada
X: My_Array := (5, 6, 7);
```

We can also use named arguments:

```ada
X: My_Array := (1 => 5, 2 => 6, 3 => 7);
```

Including ranges:

```ada
X: My_Array := (1 .. 3 => 0);
```

We can use the `others` keyword:

```ada
X: My_Array := (1 => 5, others => 0);
```

And we can pass the same values to elements that are not necessarily within the
same range by using the `|` operator:

```ada
X: My_Array := (1 | 3 => 0, others => 1);
```

Finally, we can use `<>` to let elements take their default values.

```ada
X: My_Array := (1 => 5, others => <>);
```

Index Types
-----------

Ada allows the user to set a *discrete* index type without static nor dynamic
invariants when declaring arrays. For example, we can decide to use the
`Long_Integer` type to index our array, which we can declare as follows:

```ada
type Custom_Indexed_Array is array (Long_Integer range 0 .. 5) of Integer;
```

Note that we needed to prefix the bounds declaration with the intended index
type and the `range` keyword.

We can omit the range declaration if we're using a subtype of any *discrete*
type:

```ada
type My_Index is range 0 .. 20;
type My_Array is array (My_Index) of Integer;
```

Finally, we can use the same mechanism to index an array using an enumeration
type:

```ada
type My_Enum is (Foo, Bar, Baz);
type Enum_Array is array (My_Enum) of Integer;
```

And given a instance `X: Enum_Array`, we can access its elements as `X(Foo)`,
`X(Bar)`, and `X(Baz)`.

We can further constrain the enumeration type if we want to leave off, for
example, the `Baz` element.

```ada
type Enum_Array is array (My_Enum range Foo .. Bar) of Integer;
```

Note that if we omit the index type, then it defaults to `Integer`.

Definite vs Indefinite
----------------------

Array types can be either *definite* or *indefinite*. Definite array types are
the ones where their bounds are clearly defined in the declaration, like the
examples we've been seeing before.

Indefinite array types, on the other side, don't have defined bounds, so we
have to set them when instantiating or subtyping such types. Consider this
example:

```ada
type My_Array is array (Positive range <>) of Integer;
```

We read the compound symbol `<>` as "box." You can think of it as a wildcard.

Given the indefinite array type `My_Array`, we can pass the bounds at
instantiation like this:

```ada
X: My_Array(1 .. 5);
```

Or we can choose to subtype `My_Array`:

```ada
subtype My_Array_5 is My_Array(1 .. 5);
```

At which point `My_Array_5` is a definite array type that we can instantiate as
usual.

Finally, the bounds of an indefinite array type can be implicitly defined when
providing a default value:

```ada
X: My_Array := (1, 2, 3, 4, 5);
```

Here, Given the default value has 5 elements, then the range implicitly becomes
`1 .. 5`.

Anonymous Arrays
----------------

Ada supports anonymous arrays. The only difference is that we don't need to
write a separate `type` declaration, but we need to move such declaration to
the instantiation statement.

```ada
X: array (Positive range 1 .. 5) of Integer;
```

Access Element Types
--------------------

An array can hold `aliased` (elements that can be pointed to) and `access`
elements (elements that point to other elements). We can do this by prefixing
the element type with the `aliased` or `access` keywords. For example:

```ada
type My_Aliased_Array is array (Positive range 1 .. 5) of aliased Integer;
type My_Access_Array is array (Positive range 1 .. 5) of access Integer;
```

Multi-dimensional Arrays
------------------------

Ada supports multi-dimensional arrays of a single element type. We can declare
a simple *definite* two-dimensional array of integers as:

```ada
type My_Multi_Dimensional_Array is
  array (Positive range 1 .. 5, Positive range 1 .. 5) of Integer;
```

Given `X: My_Multi_Dimensional_Array`, we can access an element by doing
something like `X(0, 5)`.

Note that each of the range definitions may use different bounds and even
different index element types:

```ada
type My_Enum is (Foo, Bar, Baz);
type My_Multi_Dimensional_Array is
  array (My_Enum range Foo .. Bar, Positive range 1 ..5) of Integer;
```

We can create *indefinite* multi-dimensional arrays, but keep in mind that all
bounds must be indefinite and that we have to set them all at instantiation:

```ada
type My_Multi_Dimensional_Array is
  array (Positive range <>, Positive range <>) of Integer;
X: My_Multi_Dimensional_Array(1 .. 5, 1 .. 3)
```

Finally, we can use aggregates to assign a set of values to a multi-dimensional
array. For example, given:

```ada
type My_Enum is (Foo, Bar, Baz);
type My_Multi_Dimensional_Array is
  array (My_Enum, Positive range 1 .. 3) of Integer;
```

We can do:

```ada
X: My_Multi_Dimensional_Array := (Foo => (1, 2, 3),
                                  Bar => (2, 3, 4),
                                  Baz => (3, 4, 5));
```

Attributes
----------

### `Length`

We can use the `Length` attribute to get the size of an array. This attribute
accepts an optional numeric argument to get the size of a dimension of a
multi-dimensional array. For example `Multi_Array'Length(1)`.

### `First` & `Last`

We can use the `First` and `Last` attributes to get the lower and upper bounds
of an array, respectively. Like `Length`, these attributes take an optional
numeric argument to fetch the bounds of multi-dimensional arrays.

### `Range`

Given array `X`, `X'Range` is a shortcut for `X'First .. X'Last`. We can pass
an optional numeric argument, so something like `X'Range(1)` translates to
`X'First(1) .. X'Last(1)`.

Looping
-------

Ada supports two variations of the well-known `for` construct available in
other programming languages: `for in` and `for of`.

The `for in` construct allows you to loop over the indexes of an array and
requires a range, such as the one returned by the `Range` attribute, or a
hardcoded one. For example, given an array called `My_Array`, we can loop
through all its elements like this:

```ada
for Index in My_Array'Range loop
  -- Do something with My_Array(Index)
end loop;
```

Ada supports reverse looping out of the box, so we can also loop through
`My_Array` in reverse by adding the `reverse` keyword before the range:

```ada
for Index in reverse My_Array'Range loop
  -- Do something with My_Array(Index)
end loop;
```

Finally, Ada 2012 provides the `for of` loop, which is a neat variation that
hides indexes from the user point of view:

```ada
for Element of My_Array loop
  -- Do something with Element
end loop;
```

Aspects
-------

Ada supports various aspects to further refine array declarations.

### `Default_Component_Value`

We can use this aspect to set an initial value to all the elements of an array
type. For example:

```ada
type My_Array is array (Positive range <>) of Integer
  with Default_Component_Value => 0;
```

### `Component_Size`

We can use this aspect to define the component size, in bits, for the elements
of an array. Let's say that for hardware optimization reasons, we want to
declare an array of booleans that stores each boolean using 4 bits:

```ada
type Boolean_Array is array (1 .. 3) of Boolean
  with Component_Size => 4;
```

### `Pack`

This aspect has no arguments, and its simply a broad hint to the compiler to
squeeze things up as most as possible.

```ada
type My_Array is array (1 .. 4) of Integer
  with Pack;
```

### `Atomic_Components`

The presence of this aspect signifies that the program treats array elements
atomically.

```ada
type My_Array is array (1 .. 4) of Boolean
  with Atomic_Components;
```

References
----------

- [Programming in Ada 2012](https://www.amazon.com/Programming-Ada-2012-John-Barnes/dp/110742481X)
- [Ada 2012 Reference Manual](http://www.ada-auth.org/standards/ada12.html)
