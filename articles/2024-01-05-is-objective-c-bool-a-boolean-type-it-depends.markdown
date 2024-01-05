---
title: Is Objective-C `BOOL` a boolean type? It depends
date: January 5, 2024
image: objc-bool.png
description: This article describes how the Objective-C `BOOL` type is differently defined on Apple platforms, and how these differences are defined in LLVM
---

The Objective-C programming language introduces its own type to represent
boolean values:
[`BOOL`](https://developer.apple.com/documentation/objectivec/bool). The
instances of this type are the constants
[`YES`](https://developer.apple.com/documentation/objectivec/yes) and
[`NO`](https://developer.apple.com/documentation/objectivec/no).


This is a simple example of invoking a function that takes a `BOOL` value as an
argument:

```objective-c
void print_boolean(BOOL value) {
  NSLog(value ? @"True" : @"False");
}

print_boolean(YES);
print_boolean(NO);
```

While `BOOL` might look trivial, its definition is rather complex. It depends
on which Apple platform and architecture you are targeting, which can result in
unexpected behavior.

> This article is based on Xcode 15.1 (15C65) running on macOS Sonoma 14.2.1 on
> a 2020 M1 MacBook Pro.

An example of unexpected behavior
---------------------------------

I write a lot of Objective-C++. A useful feature of C++ is [function
overloading](https://learn.microsoft.com/en-us/cpp/cpp/function-overloading?view=msvc-170):
the ability to define multiple functions with the same name that differ only on
the type of arguments they accept. When you invoke such a function, the
compiler will automatically determine which overload to call.

Recently, I stumbled into a case where for the same code, macOS Intel and macOS
Apple Silicon invoked different overloads. Here is a minimal reproducible
Objective-C++ example of the issue:

```objective-c++
// To locally run this example:
// $ xcrun clang++ main.mm -o objc-bool-test
// $ ./objc-bool-test

#include <objc/runtime.h>
#include <iostream>
#include <cstdlib>

void print(bool value) { std::cout << "(bool) " << value << "\n"; }
void print(int value) { std::cout << "(int) " << value << "\n"; }

int main() {
  std::cout << "YES: ";
  print(YES);
  std::cout << "NO: ";
  print(NO);
  return EXIT_SUCCESS;
}
```

On my Apple Silicon Mac (running Xcode 15.1), the above program invokes the
`bool` overloads:

```
YES: (bool) 1
NO: (bool) 0
```

However, on my macOS Intel Mac (running Xcode 14.3.2), the above program
invokes the `int` overloads:

```
YES: (int) 1
NO: (int) 0
```

Exploring the Objective-C runtime
---------------------------------

This discrepancy between Apple Silicon and Intel is not clarified by the
documentation, which appears to contradict itself to a certain degree. The
[documentation](https://developer.apple.com/documentation/objectivec/bool)
states that the canonical definition for `BOOL` is a type alias to `bool`.
However, under *Special Considerations*, the documentation states that *the
type of `BOOL` is actually `char`.*

When documentation doesn't help, we can take a look under the hood. The `BOOL`
type is defined by the
[Objective-C](https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc)
runtime, whose public headers are distributed by Xcode at the following
directory:

```sh
$ ls $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/objc
List.h               Protocol.h           objc-api.h           objc-runtime.h
NSObjCRuntime.h      hashtable.h          objc-auto.h          objc-sync.h
NSObject.h           hashtable2.h         objc-class.h         objc.h
Object.h             message.h            objc-exception.h     runtime.h
ObjectiveC.apinotes  module.modulemap     objc-load.h
```

As we can confirm with a quick search, the header that is concerned with
booleans is `objc.h`, which is included by `runtime.h`, the entry point of the
Objective-C runtime.

### The `YES` and `NO` constants

These boolean constants are defined in two ways:

```objective-c
// $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/objc/objc.h
...
#if __has_feature(objc_bool)
#define YES __objc_yes
#define NO  __objc_no
#else
#define YES ((BOOL)1)
#define NO  ((BOOL)0)
#endif
...
```

The
[`__has_feature`](https://clang.llvm.org/docs/LanguageExtensions.html#has-feature-and-has-extension)
macro is defined by LLVM as a language extension for introspecting on compiler
features. While not standard, [GCC also supports
`__has_feature`](https://gcc.gnu.org/onlinedocs/cpp/_005f_005fhas_005ffeature.html).
However, the `objc_bool` feature that the Objective-C runtime header references
is never defined by LLVM. Therefore, the definition we are interested in is the
second one:

```objective-c
#define YES ((BOOL)1)
#define NO  ((BOOL)0)
```

If you are curious, the `__objc_yes` and `__objc_no` symbols in the first
clause of the definition are built-in types [recognized by the LLVM
parser](https://github.com/llvm/llvm-project/blob/llvmorg-17.0.6/clang/lib/Parse/ParseObjc.cpp#L2880-L2885)
and are available for use. For example, this program is valid:

```objective-c
void print_boolean(BOOL value) {
  NSLog(value ? @"True" : @"False");
}

print_boolean(__objc_yes);
print_boolean(__objc_no);
```

### The `BOOL` type alias

Now that we know that `YES` and `NO` are defined by casting the numeric
constants `1` and `0` to `BOOL`, let's turn our attention to the `BOOL` type.
This type alias is defined in the `objc.h` header as follows:

```objective-c
// $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/objc/objc.h
...
#if OBJC_BOOL_IS_BOOL
    typedef bool BOOL;
#else
#   define OBJC_BOOL_IS_CHAR 1
    typedef signed char BOOL;
    // BOOL is explicitly signed so @encode(BOOL) == "c" rather than "C"
    // even if -funsigned-char is used.
#endif
...
```

As we can see, the `BOOL` type is either an alias to `bool` or an alias to
`signed char` depending on the value of the `OBJC_BOOL_IS_BOOL` preprocessor
define. Additionally, the Objective-C runtime will define `OBJC_BOOL_IS_CHAR`
if `BOOL` is set to the latter. This definition is convenient for writing code
that must make assumptions over the underlying `BOOL` type. For example:

```objective-c
#import <Foundation/Foundation.h>

int main() {
#if OBJC_BOOL_IS_CHAR
  NSLog(@"My BOOL is a signed char");
#else
  NSLog(@"My BOOL is a bool");
#endif
  return EXIT_SUCCESS;
}
```





### The `OBJC_BOOL_IS_BOOL` definition

We learnt that whether `BOOL` is a type alias to `bool` or to `signed char`
depends on the value of the `OBJC_BOOL_IS_BOOL` preprocessor definition. Like
the other constants and aliases we explored so far, this definition is also
declared in the `objc.h` header:

```objective-c
// $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/objc/objc.h
...
#if defined(__OBJC_BOOL_IS_BOOL)
    // Honor __OBJC_BOOL_IS_BOOL when available.
#   if __OBJC_BOOL_IS_BOOL
#       define OBJC_BOOL_IS_BOOL 1
#   else
#       define OBJC_BOOL_IS_BOOL 0
#   endif
#else
    // __OBJC_BOOL_IS_BOOL not set.
#   if TARGET_OS_OSX || TARGET_OS_MACCATALYST || ((TARGET_OS_IOS || 0) && !__LP64__ && !__ARM_ARCH_7K)
#      define OBJC_BOOL_IS_BOOL 0
#   else
#      define OBJC_BOOL_IS_BOOL 1
#   endif
#endif
...
```

The first clause is straightforward: if the `__OBJC_BOOL_IS_BOOL` preprocessor
definition exists, set `OBJC_BOOL_IS_BOOL` to it.

However, the second clause is a lot more involved. The code says that the
Objective-C runtime aliases `BOOL` to `signed char` in one of the following
conditions:

- If you are writing a macOS application (`TARGET_OS_OSX`), independently of
  the target architecture
- If you are writing a [Mac
  Catalyst](https://developer.apple.com/mac-catalyst/) application
  (`TARGET_OS_MACCATALYST`)
- If you are writing an iOS application (`TARGET_OS_IOS`) that does not make
  use of the [LP64 data
  model](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models)
  (`__LP64__`) and is not an ARMv7 chip
  ([`__ARM_ARCH_7K`](https://opensource.apple.com/source/xnu/xnu-4570.1.46/osfmk/arm/arch.h.auto.html))

We can deduct that the second clause does not apply here, given we see a
discrepancy on how `BOOL` is defined in macOS Intel and macOS Apple Silicon.
Otherwise both architectures would alias `BOOL` to `signed char` given the
presence of `TARGET_OS_OSX`. Therefore, we can conclude that
`__OBJC_BOOL_IS_BOOL` is always set, which we can confirm with the following
simple program:

```objective-c
// main.m
#import <Foundation/Foundation.h>

int main() {
#if defined(__OBJC_BOOL_IS_BOOL)
  NSLog(@"__OBJC_BOOL_IS_BOOL is %i", __OBJC_BOOL_IS_BOOL);
#else
  NSLog(@"__OBJC_BOOL_IS_BOOL is not defined");
#endif
  return EXIT_SUCCESS;
}
```

As expected, `__OBJC_BOOL_IS_BOOL` is defined on both my Apple Silicon Mac and
my Intel Mac as 1 and 0, respectively. Additionally, [there is a
test](https://github.com/apple-oss-distributions/objc4/blob/objc4-906.2/test/bool.c#L23-L25)
in the [Objective-C runtime source
code](https://github.com/apple-oss-distributions/objc4) that asserts that
`__OBJC_BOOL_IS_BOOL` is always defined:

```objective-c
// https://github.com/apple-oss-distributions/objc4/blob/objc4-906.2/test/bool.c
...
#if __OBJC__ && !defined(__OBJC_BOOL_IS_BOOL)
#   error no __OBJC_BOOL_IS_BOOL
#endif
...
```

Fiddling with `__OBJC_BOOL_IS_BOOL`
-----------------------------------

Now that we know that `__OBJC_BOOL_IS_BOOL` is the preprocessor define that
ultimately controls the underlying type of the `BOOL` alias, we can try to
control it.

> I'm doing it here for experimentation purposes, but I highly discourage
> changing the `__OBJC_BOOL_IS_BOOL` definition (mainly on production code!),
> as we don't know how deep its implications can be to frameworks that depends
> on the Objective-C runtime. There are probably good reasons why Apple sets
> different aliases for different platforms and architectures.  Instead, if you
> need to introspect on `BOOL`, probably better to make use of the
> `OBJC_BOOL_IS_CHAR` definition we discussed before.

On my Apple Silicon Mac, I can successfully build and run the Objective-C++
[*unexpected behavior* example](#an-example-of-unexpected-behavior) from the
beginning of this article, forcing the Objective-C runtime to alias `BOOL` to
`signed char` by explicitly setting `__OBJC_BOOL_IS_BOOL` to `0`:

```sh
$ xcrun clang++ main.mm -o force-signed-char -D__OBJC_BOOL_IS_BOOL=0
In file included from <built-in>:444:
<command line>:1:9: warning: '__OBJC_BOOL_IS_BOOL' macro redefined [-Wmacro-redefined]
#define __OBJC_BOOL_IS_BOOL 0
        ^
<built-in>:34:9: note: previous definition is here
#define __OBJC_BOOL_IS_BOOL 1
        ^
1 warning generated.

$ ./force-signed-char
YES: (int) 1
NO: (int) 0
```

While it worked and we managed to affect the alias, let's take a close look at
the compilation warning. The compiler is warning us that we are overwriting
`__OBJC_BOOL_IS_BOOL`, which was (as we expected for Apple Silicon) previously
defined like this:

```objective-c
#define __OBJC_BOOL_IS_BOOL 1
```

However, this definition is not coming from the Objective-C runtime nor any
other header. Instead, its coming directly from LLVM, as signified by the
source location that the compiler is sharing with us:

```
<built-in>:34:9
```

Using `grep(1)`, we can confirm that the Objective-C runtime public headers
never declare (only consume) the `__OBJC_BOOL_IS_BOOL` definition:

```sh
$ cd $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
$ grep --recursive '__OBJC_BOOL_IS_BOOL' usr/include/objc
usr/include/objc/objc.h:#if defined(__OBJC_BOOL_IS_BOOL)
usr/include/objc/objc.h:    // Honor __OBJC_BOOL_IS_BOOL when available.
usr/include/objc/objc.h:#   if __OBJC_BOOL_IS_BOOL
usr/include/objc/objc.h:    // __OBJC_BOOL_IS_BOOL not set.
```

Digging deeper into LLVM
------------------------

To find the mysterious `__OBJC_BOOL_IS_BOOL` definition, let's dig into LLVM.
On my main machine, I'm running AppleClang 1500.1.0.2.5 (Xcode 15.1), which
[corresponds to LLVM 16](https://en.wikipedia.org/wiki/Xcode). By searching for
occurrences of `__OBJC_BOOL_IS_BOOL` in such LLVM version, we can find that
[`clang/lib/Frontend/InitPreprocessor.cpp`](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/InitPreprocessor.cpp)
sets `__OBJC_BOOL_IS_BOOL` based on a method called `useSignedCharForObjCBool`:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/InitPreprocessor.cpp#L859-L862
...
// Define a macro that describes the Objective-C boolean type even for C
// and C++ since BOOL can be used from non Objective-C code.
Builder.defineMacro("__OBJC_BOOL_IS_BOOL",
                    Twine(TI.useSignedCharForObjCBool() ? "0" : "1"));
...
```

In turn, the `useSignedCharForObjCBool` method of the `TargetInfo` class is
defined in
[`clang/include/clang/Basic/TargetInfo.h`](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/include/clang/Basic/TargetInfo.h)
to simply return the `UseSignedCharForObjCBool` boolean class member:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/include/clang/Basic/TargetInfo.h#L848-L855
...
/// Check if the Objective-C built-in boolean type should be signed
/// char.
///
/// Otherwise, if this returns false, the normal built-in boolean type
/// should also be used for Objective-C.
bool useSignedCharForObjCBool() const {
  return UseSignedCharForObjCBool;
}
...
```

By default, the `UseSignedCharForObjCBool` boolean class member is set to
`true`:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Basic/TargetInfo.cpp#L135
...
TargetInfo::TargetInfo(const llvm::Triple &T) : Triple(T) {
...
  UseSignedCharForObjCBool = true;
...
}
...
```

### The Objective-C to C++ re-writer

There is a single method in the `TargetInfo` class that directly affects the
value of the `UseSignedCharForObjCBool` boolean class member. This method is
called `noSignedCharForObjCBool`, and as its name implies, sets
`UseSignedCharForObjCBool` to `false`. Its definition looks like this:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/include/clang/Basic/TargetInfo.h#L856-L858
...
void noSignedCharForObjCBool() {
  UseSignedCharForObjCBool = false;
}
...
```

Interestingly enough, the only place where this method is invoked is in
[`clang/lib/Frontend/CompilerInstance.cpp`](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/CompilerInstance.cpp),
to unconditionally alias `BOOL` to `bool` on the Objective-C to C++ re-writer
that we extensively covered in a [previous
post](../../../2023/12/01/understanding-objective-c-by-transpiling-it-to-cpp.html):

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/CompilerInstance.cpp#L1023-L1025
...
// rewriter project will change target built-in bool type from its default.
if (getFrontendOpts().ProgramAction == frontend::RewriteObjC)
  getTarget().noSignedCharForObjCBool();
...
```

If you are curious, you can read [the LLVM
commit](https://github.com/llvm/llvm-project/commit/29898f45657314c7fa7f61e8157a36c832015fcc)
that initially introduced the `noSignedCharForObjCBool` method and opted for
the native `bool` type in the Objective-C to C++ re-writer.

### The Objective-C compiler

Leaving the Objective-C experimental C++ re-writer aside, the supported targets
of the production-ready Objective-C compiler set the `UseSignedCharForObjCBool`
boolean class member when subclassing from `TargetInfo`.

We can use `grep(1)` to find every target subclass that mentions
`UseSignedCharForObjCBool` as follows:

```sh
$ grep --recursive 'UseSignedCharForObjCBool' clang/lib/Basic/Targets | uniq
clang/lib/Basic/Targets/AArch64.cpp:  UseSignedCharForObjCBool = false;
clang/lib/Basic/Targets/X86.h:      UseSignedCharForObjCBool = false;
clang/lib/Basic/Targets/ARM.cpp:    UseSignedCharForObjCBool = false;
```

Let's take a closer look at each of these matches.

#### `AArch64`

The AArch64 target corresponds to 64-bit ARM chips, such as Apple Silicon. For
this target, `UseSignedCharForObjCBool` is unconditionally set to `false`, so
the `__OBJC_BOOL_IS_BOOL` preprocessor define is always `1`:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Basic/Targets/AArch64.cpp#L1432
...
DarwinAArch64TargetInfo::DarwinAArch64TargetInfo(const llvm::Triple &Triple,
                                                 const TargetOptions &Opts)
    : DarwinTargetInfo<AArch64leTargetInfo>(Triple, Opts) {
  ...
  UseSignedCharForObjCBool = false;
  ...
}
...
```

As expected, this matches the behavior we saw at the beginning of the article:
for Apple Silicon Macs, the Objective-C runtime aliases `BOOL` to `bool`.

#### `X86`

For 32-bit Intel chips, `BOOL` is always an alias to `signed char` except for
watchOS. For its first 8 versions (until 2022), watchOS shipped with [32-bit
support](https://en.wikipedia.org/wiki/WatchOS#watchOS_8), so this
configuration is for old watchOS simulators running on Intel Macs:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Basic/Targets/X86.h#L533-L536
...
DarwinI386TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts)
    : DarwinTargetInfo<X86_32TargetInfo>(Triple, Opts) {
  ...
  // The watchOS simulator uses the builtin bool type for Objective-C.
  llvm::Triple T = llvm::Triple(Triple);
  if (T.isWatchOS())
    UseSignedCharForObjCBool = false;
  ...
}
...
```

For 64-bit Intel chips, `BOOL` is always an alias to `signed char` except for
iOS. As the comment clarifies, this configuration is for iOS simulators running
on Intel Macs:

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Basic/Targets/X86.h#L915-L918
...
DarwinX86_64TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts)
    : DarwinTargetInfo<X86_64TargetInfo>(Triple, Opts) {
  ...
  // The 64-bit iOS simulator uses the builtin bool type for Objective-C.
  llvm::Triple T = llvm::Triple(Triple);
  if (T.isiOS())
    UseSignedCharForObjCBool = false;
  ...
}
...
```

As expected, this matches the behavior we saw at the beginning of the article:
for Intel Macs, the Objective-C runtime aliases `BOOL` to `signed char`.

#### `ARM`

Finally, for 32-bit ARM chips, `BOOL` is always an alias to `signed char`
except for watchOS. The watchOS product always targeted ARM, so this
configuration is likely for production watchOS deployments until version 8
(after which 32-bit support was removed):

```c++
// See https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Basic/Targets/ARM.cpp#L1412-L1417
...
DarwinARMTargetInfo::DarwinARMTargetInfo(const llvm::Triple &Triple,
                                         const TargetOptions &Opts)
    : DarwinTargetInfo<ARMleTargetInfo>(Triple, Opts) {
  ...
  if (Triple.isWatchABI()) {
    ...
    // BOOL should be a real boolean on the new ABI
    UseSignedCharForObjCBool = false;
  ...
}
...
```

If you are looking for a higher-level view, the test suite of the Objective-C
runtime has an [interesting
case](https://github.com/apple-oss-distributions/objc4/blob/objc4-906.2/test/bool.c#L7-L21)
for determining whether the "real" boolean type should apply or not on the
platform under test.

Summary
-------

If you made it this far, you might be wondering how `BOOL` grew so complicated.
While we cannot tell for sure without Apple insider's knowledge, I believe the
reasons are historical.

Back in 1984, Objective-C was designed to be a strict superset of the C
language. At the time, the C language didn't have built-in support for
booleans, and Objective-C's decision of re-purposing `signed char` to hold
boolean values was sensible. You can see an ancient definition of `BOOL` that
is unconditionally aliased to `signed char`
[here](https://opensource.apple.com/source/objc4/objc4-237/runtime/objc.h.auto.html).

More than a decade later, as part of the C99 specification, the C language
released support for boolean values through the
[`<stdbool.h>`](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/stdbool.h.html)
header. Then, later versions of the Objective-C runtime started conditionally
aliasing `BOOL` to the new `bool` type in modern Apple products. It is likely
that older platform and architecture combinations still use `signed char` for
legacy reasons.

> If you want to continue learning about the curiosities of the `BOOL` type,
> you might also enjoy [BOOL's sharp
> corners](https://bignerdranch.com/blog/bools-sharp-corners/) by the Big Nerd
> Ranch, and Google's [Objective-C
> Styleguide](https://google.github.io/styleguide/objcguide.html#bool-pitfalls).
