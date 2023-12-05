---
title: Spoofing Objective-C return values on Apple Silicon using LLDB
date: November 22, 2023
image: generic.jpg
description: This article describes how LLDB can be used to mutate return values of Objective-C methods and functions
---

In my [previous
article](https://www.jviotti.com/2023/11/20/exploring-macos-private-frameworks.html),
we covered various techniques for statically exploring the vast amount of
private frameworks that macOS ships with, most of them written in Objective-C.

After studying these private frameworks through their exported interfaces and
through a disassembler, an interesting technique to validate your assumptions
is to fire [LLDB](https://lldb.llvm.org) (the LLVM debugger that ships with
Xcode), fiddle with these private functions, and see how your changes affect
the program under test.

In this article, we will focus on how to mutate Objective-C function return
values using LLDB. Most Apple systems are on Apple Silicon at this point, so we
won't bother with Intel. Also, while we won't touch on it here, this technique
is also applicable to Swift.

Finally, keep in mind that if you want to attach LLDB to applications written
by Apple, you will need to disable
[SIP](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)
(System Integrity Protection). However, don't do this on your main machine! The
easiest secure alternative is to provision a macOS VM using
[Parallels](https://www.parallels.com).

> The credit from this post goes to [Wojciech
> Reguła](https://wojciechregula.blog), from whom I also learnt this trick.

A review of Apple Silicon procedure calls
-----------------------------------------

Before getting into it, we need to understand some basics about how functions
are executed on the Apple Silicon chips.

Apple Silicon is based on ARM. More specifically,
[A7](https://en.wikipedia.org/wiki/Apple_A7) and later chips are based on the
64-bit ARMv8 CPU
[ISA](https://en.wikipedia.org/wiki/Instruction_set_architecture) (Instruction
Set Architecture). The 64-bit ARM architecture is often referred to as
*AArch64* (Arm Architecture 64-bit).

Like most other 64-bit ARM chips, Apple Silicon follows the *ARM Architecture
Procedure Call Standard for AArch64* (AAPCS64). The specification for this
procedure call process is conveniently hosted on
[GitHub](https://github.com/ARM-software/abi-aa/blob/2023Q3/aapcs64/aapcs64.rst).
The specification (see [6.1.1 General-purpose
Registers](https://github.com/ARM-software/abi-aa/blob/2023Q3/aapcs64/aapcs64.rst#general-purpose-registers))
states that 64-bit ARM introduces 31 general-purpose registers of which `x0` to
`x7` *"are used to pass argument values into a subroutine and to return result
values from a function."* Note that the specification does not mandate which of
these registers must be used to hold result values. By convention, ARM
implementations (including Apple) typically use the `x0` register for this
purpose.

> Apple does make some [specific
> choices](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms#Respect-the-purpose-of-specific-CPU-registers)
> on their use of registers (`x18` and `x29`), however these choices are not
> relevant for the purpose of this article.

For 64-bit ARM, the `x0` general-purpose register is a 64-bit register. If the
result value of a function fits in the register, it may be directly written.
Otherwise, the `x0` register may be a pointer to a memory location where the
result is stored.

Example 1: Spoofing a scalar value in a method
----------------------------------------------

Consider the following example Objective-C program. It defines an `Operations`
class with a `multiply` method that, as its name implies, performs a
multiplication operation on two integers. The program instantiates the
`Operations` class and invokes `multiply` with arguments 5 and 3:

```objective-c
#import <Foundation/Foundation.h>

@interface Operations : NSObject
- (int)multiply:(int)value by:(int)multiplier;
@end

@implementation Operations
- (int)multiply:(int)value by:(int)multiplier {
  return value * multiplier;
}
@end

int main() {
  @autoreleasepool {
    Operations *operations = [[Operations alloc] init];
    NSLog(@"Result: %i", [operations multiply:5 by:3]);
  }

  return EXIT_SUCCESS;
}
```

The output of this program, as you would expect, is 15:

```sh
$ clang example-1.m -o example-1 -framework Foundation
$ ./example-1
2023-11-22 10:45:17.367 example-1[20563:100228] Result: 15
```

Let's attempt to change the result of the `multiply` method to an arbitrary
value, like 1. First, we will open the program using LLDB:

```sh
$ lldb ./example-1
Breakpoint 1: no locations (pending).
Breakpoint set in dummy target, will get copied into future targets.
(lldb) target create "./example-1"
Current executable set to '/Users/jviotti/Projects/playground/example-1' (arm64).
```

We will set a breakpoint on the `multiply` method of the `Operations` class:

```sh
(lldb) breakpoint set --name "-[Operations multiply:by:]"
Breakpoint 2: where = example-1`-[Operations multiply:by:], address = 0x0000000100003e6c
```

Then, let's execute the program so that it stops at our breakpoint:

```sh
(lldb) run
Process 21632 launched: '/Users/jviotti/Projects/playground/example-1' (arm64)
Process 21632 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.1
    frame #0: 0x0000000100003e6c example-1`-[Operations multiply:by:]
example-1`-[Operations multiply:by:]:
->  0x100003e6c <+0>:  sub    sp, sp, #0x20
    0x100003e70 <+4>:  str    x0, [sp, #0x18]
    0x100003e74 <+8>:  str    x1, [sp, #0x10]
    0x100003e78 <+12>: str    w2, [sp, #0xc]
Target 0: (example-1) stopped.
```

Once in the `multiply` method, we can instruct LLDB to finish executing the
current stack frame and stop after returning using the `finish` command. This
will put us at the right spot to change the `x0` register and affect the caller
of the method:

```sh
(lldb) finish
Process 21632 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step out
    frame #0: 0x0000000100003ed8 example-1`main + 68
example-1`main:
->  0x100003ed8 <+68>: mov    x9, sp
    0x100003edc <+72>: mov    x8, x0
    0x100003ee0 <+76>: str    x8, [x9]
    0x100003ee4 <+80>: adrp   x0, 1
Target 0: (example-1) stopped.
```

We can confirm that the `x0` register holds the expected return value, the
integer 15, using `register read`:

```sh
(lldb) register read --format decimal $x0
      x0 = 15
```

Let's now change the value of register `x0` to the integer 1:

```sh
(lldb) register write $x0 0x1
```

Finally, we can let the program continue its execution, and confirm that the
printed output is our spoofed value 1:

```sh
(lldb) continue
Process 21632 resuming
2023-11-22 10:58:46.288530-0400 example-1[21632:104596] Result: 1
Process 21632 exited with status = 0 (0x00000000)
```

Example 2: Spoofing an object value in a function
-------------------------------------------------

In the previous section, we explored spoofing scalar return values like
integers.  In practice, most interesting Objective-C methods and functions
return `NSObject` instances allocated in the heap. Luckily, spoofing object
return values is just as easy.

Consider this example Objective-C program that defines a `greet` function that
takes an `NSString` name as an argument and returns an `NSString` that we can
use to greet the person. The program will construct a greeting for `John Doe`
and print the corresponding string:

```objective-c
#import <Foundation/Foundation.h>

NSString * greet(NSString *name) {
  return [NSString stringWithFormat:@"Hello %@", name];
}

int main() {
  @autoreleasepool {
    NSLog(@"Greeting: %@", greet(@"John Doe"));
  }

  return EXIT_SUCCESS;
}
```

The output of this program, as you would expect, is `Hello John Doe`:

```sh
$ clang main.m -o example-2 -framework Foundation
$ ./example-2
2023-11-22 11:07:27.101 example-2[25313:120317] Greeting: Hello John Doe
```

We will attempt to spoof the `greet` function to return my name, `Juan Cruz
Viotti`. As before, let's run this program with LLDB:

```sh
$ lldb ./example-2
Breakpoint 1: no locations (pending).
Breakpoint set in dummy target, will get copied into future targets.
(lldb) target create "./example-2"
Current executable set to '/Users/jviotti/Projects/playground/example-2' (arm64).
```

Then, we will set a breakpoint on the `greet` function:

```sh
(lldb) breakpoint set --name greet
Breakpoint 2: where = example-2`greet, address = 0x0000000100003e9c
```

Just like before, we will execute the program (using `run`) and stop right
after the function was executed (using `finish`):

```sh
(lldb) run
Process 26239 launched: '/Users/jviotti/Projects/playground/example-2' (arm64)
Process 26239 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.1
    frame #0: 0x0000000100003e9c example-2`greet
example-2`greet:
->  0x100003e9c <+0>:  sub    sp, sp, #0x20
    0x100003ea0 <+4>:  stp    x29, x30, [sp, #0x10]
    0x100003ea4 <+8>:  add    x29, sp, #0x10
    0x100003ea8 <+12>: str    x0, [sp, #0x8]
Target 0: (example-2) stopped.

(lldb) finish
Process 26239 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step out
    frame #0: 0x0000000100003f04 example-2`main + 44
example-2`main:
->  0x100003f04 <+44>: mov    x8, sp
    0x100003f08 <+48>: str    x0, [x8]
    0x100003f0c <+52>: adrp   x0, 1
    0x100003f10 <+56>: add    x0, x0, #0x40             ; @"Greeting: %@"
Target 0: (example-2) stopped.
```

We can confirm that the `x0` register holds the expected return value as
follows:

```sh
(lldb) expression --object-description -- $x0
Hello John Doe
```

Now here comes the interesting part. We can use the `expression` command to
invoke arbitrary Objective-C code, which may result in heap allocations.
Therefore, we can use this command to instantiate an `NSString` of our choosing
and retrieve its address (in hexadecimal form):

```sh
(lldb) expression --format hex -- [NSString stringWithUTF8String:"Juan Cruz Viotti"]
(__NSCFString *) $2 = 0x000060000073c000 @"Juan Cruz Viotti"
```

In this case, I instantiated an `NSString` with the contents `Juan Cruz
Viotti`, and its address is `0x000060000073c000`. As you might expect, we can
set the `x0` register to this address:

```sh
(lldb) register write $x0 0x000060000073c000
```

Finally, we can let the program resume execution and confirm that it prints our
spoofed string:

```sh
(lldb) continue
Process 26239 resuming
2023-11-22 11:19:35.675241-0400 example-2[26239:124053] Greeting: Juan Cruz Viotti
Process 26239 exited with status = 0 (0x00000000)
```
