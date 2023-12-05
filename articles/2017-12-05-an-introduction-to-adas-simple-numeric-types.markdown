---
title: An introduction to Ada's simple numeric types
date: December 5, 2017
image: generic.jpg
description: This article introduces the numeric types available in Ada 2012
---

Ada expects the programmer to not use the built-in number types directly, but
create new number types to match the application's specific needs. By giving
pointers to the compiler about the required numeric characteristics, Ada
implementations can pick the best hardware number type for the job, providing
efficiency without compromising portability.

The built-in number types (in the `Standard` package) consist of `Integer`,
`Positive` (an integer type that starts from 1), `Natural` (an integer type
that starts from 0), and `Float`. Ada implementations may provide other types,
but its usually recommended to avoid them for portability reasons.

All the number types support the typical arithmetic operations, plus other
operators such as `mod` (modulo), `rem` (remainder), `abs` (absolute), and more
advanced ones defined in the `Ada.Numerics` package. For the programmer's
convenience, Ada supports underscores as delimiters for the sole purpose of
making number literals easier to read. The programmer can also express number
literals in bases other than 10 by writing the base, and then the number
between `#` symbols. Thus, the number 3 is written as `2#011#`.

Ada allows the programmer to define custom integer and real number types.

Integer Types
-------------

Integers are discrete types, which means they have the property of unique
predecessors and successors. Ada allows the programmer to define both signed
and modular integer types.

### Signed Integers

Signed integers are the simplest number type. The `System.Min_Int` and
`System.Max_Int` constants define the minimum and maximum signed integer values
that the given system can represent.

The programmer can define a signed integer type like this:

```ada
type My_Integer_Type is range Start .. End;
```

Where `Start` and `End` are expressions that define the type's lower and upper
bounds.

The programmer can perform text IO on signed integer types by instantiating the
`Ada.Text_IO.Integer_IO` generic package:

```ada
package My_Integer_Type_IO is
  new package Ada.Text_IO.Integer_IO(My_Integer_Type);
```

### Modular Integers

Modular integers are unsigned integer types that use modular arithmetic. The
Ada programmer can define these types of integers like this:

```ada
type My_Modular_Type is mod N;
```

Where the modulus, `N` needs to be a static expression. Our `My_Modular_Type`
type can hold values from 0 (because it is an unsigned integer) to `N - 1`.

Modular types also implement the `and`, `or`, `xor`, and `not` operators, which
treat the number as a bit pattern.

The programmer can use the `Mod` attribute of a modular type to convert a
signed integer into such type. For example:

```ada
My_Modular_Type'Mod(15);
```

If the attribute argument is not within the modular type's bounds, then modular
arithmetic will make it fit.

Notice that modular arithmetic applies if an expression results in a value
greater than the modulus, but the programmer is not allowed to set an out of
bounds value directly. For example, given M is larger than the modulus, `X:
My_Modular_Type := M` will raise a constraint error.

The programmer can instantiate the generic text IO library for a modular type
by using the `Ada.Text_IO.Modular_IO` package:

```ada
package My_Modular_Type_IO is
  new Ada.Text_IO.Modular_IO(My_Modular_Type);
```

Real Types
----------

Ada supports floating-point and fixed-point number types. Floating-point values
have a relative error while fixed-point values have an absolute error.

Since there are infinite values between any two real numbers, computers have
precise representations only for a set of those values, which are called *model
numbers*. The computer approximates the remaining values using the closest
model number.

### Floating-Point Types

Floating-point types are internally represented as a kind of scientific
notation, usually [IEEE 754][ieee754]. In Ada, the programmer determines the
minimum amount of digits required for the significand and the implementation
will pick the hardware type that better suits that constraint.

The programmer can define a floating-point type like this:

```ada
type My_Floating_Point_Type is digits N range Start .. End;
```

The static value `N` represents the minimum amount of significant digits, which
should be no greater than `System.Max_Base_Digits`.

The programmer may provide an optional range. If a range is not provided, Ada
will create a floating-point type with the widest possible range. The number of
significant digits for floating-point types without a range is determined by
the `System.Max_Digits` constant.

The programmer can consult the real amount of digits provided by the hardware
for a floating-point type at runtime using the `Digits` attribute of the base
type:

```ada
My_Floating_Point_Type'Base'Digits;
```

Take the following floating-point type as an example:

```ada
type My_Floating_Point_Type is digits 4 range 0.0 .. 100.0;
```

Since the number of significant digits is 4, we can use this type to represent
numbers such as 99.86, or 5.456. If a particular number has more digits than
what the significand supports, like 99.456, then Ada will *round* the number to
the closest representable number, which in the case of 99.456 would be 99.46.

The programmer can instantiate the text IO package for a floating-point type by
instantiating the `Ada.Text_IO.Float_IO` generic package:

```ada
package My_Floating_Point_Type_IO is
  new Ada.Text_IO.Float_IO(My_Floating_Point_Type);
```

Keep in mind that the representational error for a floating-point number type
gets larger as the number gets larger. The reason for this is that as the
number gets larger, the integral part occupies more significant digits, leaving
fewer digits to the fractional part.

### Ordinary Fixed-Point Types

Floating-point number types allow the radix to "float" through the significant
digits. Thus, the amount of digits available for the integral and fractional
parts is variable. Fixed-point types, on the other hand, have a fixed amount of
digits for both parts.

This type of number representation has certain advantages:

- Arithmetic is performed with standard integer machine instructions, which are
  typically faster than floating-point instructions. Also, some low cost
  embedded microprocessors and microcontrollers don't have an FPU (floating
  point unit), so they can't work with floating-point arithmetic

- The maximum representational error is constant because the number of digits
  allocated at each part of the radix is constant

The programmer can define these real number types like this:

```ada
type My_Fixed_Point_Type is delta N range Start .. End;
```

Where the delta static expression defines the maximum distance between model
numbers that the programmer is willing to tolerate. The maximum
representational error is half of this distance.

Notice that ordinary fixed-point types make use of a scaling factor that is a
power of two, and therefore the actual delta will be the largest power of two
that is less or equal to the given value. If the defined delta is `1/3`, then
Ada will use `1/4` (which equals `2^-2`, since `1/3` is not a power of 2.

The programmer can perform text IO on decimal fixed-point types by
instantiating the `Ada.Text_IO.Fixed_IO` generic package:

```ada
package My_Fixed_Point_Type_IO is
  new Ada.Text_IO.Fixed_IO(My_Fixed_Point_Type);
```

### Decimal Fixed-Point Types

This type is a fixed-point type with a scaling factor that is a power of ten.

The Ada programmer can define a decimal fixed-point type as an ordinary fixed
point type that includes a minimum number of significant digits, just like
with floating-point types:

```ada
type My_Decimal_Fixed_Point_Type is delta 0.01 digits 10;
```

Where the delta expression must be a static power of ten (otherwise the compiler
raises an error).

The defined minimum number of significant digits covers the number of
fractional digits required by the delta expression, so in the above example we
can represent numbers using 8 digits for the integral part, and 2 digits for
the fractional part.

Notice that assigning a number literal with more integral or fractional digits
than specified will result in an error, instead of resulting in a rounded
number like in the case of floating-point types.

The programmer can perform text IO on decimal fixed-point types by
instantiating the `Ada.Text_IO.Decimal_IO` generic package:

```ada
package My_Decimal_Fixed_Point_Type_IO is
  new Ada.Text_IO.Decimal_IO(My_Decimal_Fixed_Point_Type);
```

The Base Type
-------------

Ada's approach to number types is to let the programmer describe the required
constraints, and then let the implementation choose the best hardware-specific
type for the job.

This distinction introduces what we call the "base" type. The base type of a
number type refers to the underlying hardware type that represents it and is
accessible through the `Base` attribute of any number type.

Notice that base number operations are defined in terms of the base type, so
numbers may be out of bounds during intermediate computations. This means that
even if carefully define our number types using ranges, the program might still
not be fully portable due to intermediate computations that might overflow on
certain hardware.

References
----------

- [Programming in Ada 2012](https://www.amazon.com/Programming-Ada-2012-John-Barnes/dp/110742481X)
- [Building High Integrity Applications with SPARK](https://www.amazon.com/Building-High-Integrity-Applications-SPARK/dp/1107656842)
- [Ada 2012 Reference Manual](http://www.ada-auth.org/standards/ada12.html)
- [Floating-point Arithmetic, from Wikipedia](https://en.wikipedia.org/wiki/Floating-point_arithmetic)
- [Fixed-point Arithmetic, from Wikipedia](https://en.wikipedia.org/wiki/Fixed-point_arithmetic)

[ieee754]: http://grouper.ieee.org/groups/754/
