---
title: Understanding Objective-C by transpiling it to C++
date: December 1, 2023
image: machoview-nsstring.png
description: This article describes how to transpile Objective-C to C++, and use that approach to gain understanding of the Objective-C runtime
---

Apple heavily pushes for Swift as the programming language for its platforms.
However, Objective-C is not going anywhere yet. A 2023 study reveals that
[*"Objective-C is still at the core of iOS and is used directly or indirectly
by most
apps"*](https://blog.timac.org/2023/1019-state-of-swift-and-swiftui-ios17/).
Also, most frameworks shipped on macOS ([as we saw on a previous
post](https://www.jviotti.com/2023/11/20/exploring-macos-private-frameworks.html))
are still written in Objective-C.

As you probably know, Objective-C is a superset of C. In fact, the [Objective-C
runtime](https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc)
is a plain C library. An awesome trick that [Wojciech
Reguła](https://wojciechregula.blog) recently introduced me to is to transpile
Objective-C to C++. This is a great way to learn more about the Objective-C
runtime, and how Objective-C works under the hood.

In this article, we will transpile an example Objective-C program to C++,
highlight some interesting parts of the generated code, and explore some of the
history and current status of this work on the [LLVM](https://llvm.org)
project.

Example: Transpiling "Hello World"
----------------------------------

Let's look at an example, based on the following sample Objective-C program:

```objective-c
// main.m
#import <Foundation/Foundation.h>

int main() {
  @autoreleasepool {
    NSLog(@"Hello World");
  }

  return EXIT_SUCCESS;
}
```

To transpile this Objective-C program to C++, we can use Clang's
[`-rewrite-objc`](https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-rewrite-objc)
option, along with the `-Wno-everything` option to quiet warnings that are
irrelevant for the sake of this post, and the `-fno-ms-extensions` to disable
Microsoft-specific extensions (more on this later):

```sh
$ xcrun clang main.m -o main.cc -rewrite-objc -Wno-everything -fno-ms-extensions
```

The `main.cc` output will be a pretty big C++ file (over 60k lines on my
system) that looks something like this:

```c++
#ifndef __OBJC2__
#define __OBJC2__
#endif
struct objc_selector; struct objc_class;
struct __rw_objc_super {
	struct objc_object *object;
	struct objc_object *superClass;
	__rw_objc_super(struct objc_object *o, struct objc_object *s) : object(o), superClass(s) {}
};

// ...

int main() {
  /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_sy_wb_f149x2v9_j6xdhfrtr9c00000gn_T_main_fca8a5_mi_0);
  }
  return 0;
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
```

Let's explore some interesting parts of the resulting code, starting with a
simple one.

> While we won't showcase it in this article, `-rewrite-objc` can also be used
> to transpile Objective-C++ to C++.

### Inspecting `NSString` static strings

Here is our initial simple
[`NSLog`](https://developer.apple.com/documentation/foundation/1395275-nslog)
invocation:

```objective-c
NSLog(@"Hello World");
```

Which the re-writer translated to:

```c++
NSLog((NSString *)&__NSConstantStringImpl__var_folders_sy_wb_f149x2v9_j6xdhfrtr9c00000gn_T_main_6b2f4b_mii_0);
```

Our "Hello World" constant string is statically allocated as a `__NSConstantStringImpl`,

```c++
static __NSConstantStringImpl __NSConstantStringImpl__var_folders_sy_wb_f149x2v9_j6xdhfrtr9c00000gn_T_main_6b2f4b_mii_0 __attribute__ ((section ("__DATA, __cfstring"))) = {__CFConstantStringClassReference,0x000007c8,"Hello World",11};
```

The `__NSConstantStringImpl` structure looks like this:

```c++
struct __NSConstantStringImpl {
  int *isa;
  int flags;
  char *str;
#if _WIN64
  long long length;
#else
  long length;
#endif
};
```

Cross-referencing this with the brace initialization of our
`__NSConstantStringImpl` instance, we can determine that the object *is a*
`__CFConstantStringClassReference`, that it has the flags `0x000007c8`, that
the actual string is `Hello World`, and that its length is 11. If you are
curious about the flags integer, the `CFString`
[implementation](https://opensource.apple.com/source/CF/CF-550.42/CFString.c),
part of the [Core
Foundation](https://developer.apple.com/documentation/corefoundation?language=objc)
framework, tells us that it is an immutable, UTF-8 string that uses the default
allocator, and whose contents are not freed up.

The `(section ("__DATA, __cfstring"))` attribute specifies that the string must
be stored in the `__cfstring` section of the `__DATA` (read/write) segment of
the resulting
[Mach-O](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/CodeFootprint/Articles/MachOOverview.html)
executable. To better understand this, let's compile the "Hello World"
Objective-C program (in the usual way) and inspect it using the open-source
[MachOView](https://github.com/horsicq/XMachOViewer) desktop application.

![Inspecting `__DATA_CONST.__cfstring` and `__TEXT.__cstring` with MachOView](../../../images/machoview-nsstring.png)

In this example, C string literals are stored at specific offsets of the
`__cstring` section of the `__TEXT` (read-only) segment, and the `CFString`
objects are stored in the `__cstring` section of the `__DATA_CONST` segment,
pointing back at the offset of the C strings.

> Note that the Clang Objective-C to C++ re-writer does not add a `const`
> qualifier to the `__NSConstantStringImpl` instance, resulting in the object
> being stored in the `__DATA` segment, instead of the `__DATA_CONST` segment
> as the normal Objective-C compilation process seems to do. We will touch on
> why these differences exist later in the post.

Even more interestingly, we can see the members of the `__NSConstantStringImpl`
structure being laid out in the executable. The first entry corresponds to the
`isa` offset, the second entry corresponds to the `flags` integer, the third
entry corresponds to the `str` C string offset (as we saw before), and the
fourth entry corresponds to the `length` of the string.

![Mach-O example of `__NSConstantStringImpl`](../../../images/nsconstantstringimpl-macho-cfstring.png)

Coming back to the generated C++ code, before invoking `NSLog`, the
`__NSConstantStringImpl` instance is treated as a cast to `NSString`, which is
defined as follows:

```c++
// @class NSString;
#ifndef _REWRITER_typedef_NSString
#define _REWRITER_typedef_NSString
typedef struct objc_object NSString;
typedef struct {} _objc_exc_NSString;
#endif
```

According to the above definition, `NSString` is an alias (`typedef`) to
`objective-c_object`, which according to the [Objective-C
runtime](https://developer.apple.com/documentation/objectivec/id?language=objc),
corresponds to a pointer to an arbitrary Objective-C object. That is,
`objective-c_object` equals the well-known `id` Objective-C type. In fact, the
generated C++ code defines `id` like this:

```C++
typedef struct objc_class *Class;
struct objc_object {
    Class _Nonnull isa __attribute__((deprecated));
};
typedef struct objc_object *id;
```

### Inspecting `@autoreleasepool` blocks

Since the introduction of
[ARC](https://clang.llvm.org/docs/AutomaticReferenceCounting.html) (Automatic
Reference Counting), the
[`NSAutoReleasePool`](https://developer.apple.com/documentation/foundation/nsautoreleasepool)
cannot be directly used, and was replaced by `@autoreleasepool` blocks.

If we take a look at the generated C++ code, we can see that Clang re-wrote the
`@autoreleasepool` block as follows:

```c++
/* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
  NSLog((NSString *)&__NSConstantStringImpl__var_folders_sy_wb_f149x2v9_j6xdhfrtr9c00000gn_T_main_fca8a5_mi_0);
}
```

The key here is the `__AtAutoreleasePool` class, defined close to the beginning
of the generated file:

```c++
struct __AtAutoreleasePool {
  __AtAutoreleasePool() {atautoreleasepoolobj = objc_autoreleasePoolPush();}
  ~__AtAutoreleasePool() {objc_autoreleasePoolPop(atautoreleasepoolobj);}
  void * atautoreleasepoolobj;
};
```

This is a C++ [RAII](https://en.cppreference.com/w/cpp/language/raii) (Resource
Acquisition Is Initialization) wrapper over the `objective-c_autoreleasePoolPush` and
`objective-c_autoreleasePoolPop` private C functions of the runtime.

These functions are not covered by the Apple documentation, and are not
declared on the public headers of the Objective-C runtime, which you can
confirm with the following `grep(1)` command:

```sh
$ grep objc_autorelease $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/objc/*
```

In a [previous
article](https://www.jviotti.com/2023/11/20/exploring-macos-private-frameworks.html),
we explored how to extract the `dyld` shared cache of your system libraries.
Assuming your extracted cache is located at `$HOME/dyld-cache-arm64e`, you can
confirm `objective-c_autoreleasePoolPush` and `objective-c_autoreleasePoolPop` are globally
exposed symbols of `libobjc.A.dylib` using `nm(1)`:

```sh
$ nm -g $HOME/dyld-cache-arm64e/usr/lib/libobjc.A.dylib | grep objc_autorelease
00000001800a4afc T __objc_autoreleasePoolPop
00000001800a4b00 T __objc_autoreleasePoolPrint
00000001800a4af8 T __objc_autoreleasePoolPush
0000000180075850 T _objc_autorelease
00000001800739ec T _objc_autoreleasePoolPop
00000001800738ac T _objc_autoreleasePoolPush
0000000180076b8c T _objc_autoreleaseReturnValue
```

You can also find references to these functions in the TDB that declares
exported symbols for `libobjc.A.dylib`:

```sh
$ grep objc_autorelease < $(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib/libobjc.A.tbd
           __objc_atfork_parent, __objc_atfork_prepare, __objc_autoreleasePoolPop,
           __objc_autoreleasePoolPrint, __objc_autoreleasePoolPush, __objc_beginClassEnumeration,
           _objc_allocateProtocol, _objc_autorelease, _objc_autoreleasePoolPop,
           _objc_autoreleasePoolPush, _objc_autoreleaseReturnValue, _objc_begin_catch,
```

Coming back to our generated code, these private functions that are not
declared in the Objective-C runtime headers are consumed like this:

```c++
extern "C" __declspec(dllimport) void * objc_autoreleasePoolPush(void);
extern "C" __declspec(dllimport) void objc_autoreleasePoolPop(void *);
```

#### Microsoft Extensions

You might be puzzled by the seemingly Windows-specific `__declspec(dllimport)`
attribute.

Let's dig a bit into it. I'm running AppleClang 1500.0.40.1 (Xcode 15.0.1),
which [corresponds to LLVM 16](https://en.wikipedia.org/wiki/Xcode). In LLVM
16, the Objective-C re-writer we are using is implemented in
[`clang/lib/Frontend/Rewrite/RewriteModernObjC.cpp`](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/Rewrite/RewriteModernObjC.cpp).

> You might have noted
> [`clang/lib/Frontend/Rewrite/RewriteObjC.cpp`](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/Rewrite/RewriteObjC.cpp),
> which corresponds to the old
> [`-rewrite-legacy-objc`](https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-rewrite-legacy-objc)
> Clang option. That re-writer is deprecated and should not be used anymore.

Taking a look into `RewriteModernObjC.cpp`, we can see that the re-writer has
various conditionals around `LangOpts.MicrosoftExt` for performing
Microsoft-specific rewrites. For example, lines [5930 to
5935](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/Rewrite/RewriteModernObjC.cpp#L5930-L5935)
contain the following logic:

```c++
if (LangOpts.MicrosoftExt) {
  Preamble += "#define __OBJC_RW_DLLIMPORT extern \"C\" __declspec(dllimport)\n";
  Preamble += "#define __OBJC_RW_STATICIMPORT extern \"C\"\n";
}
else
  Preamble += "#define __OBJC_RW_DLLIMPORT extern\n";
```

As you might expect, this is the reason we initially passed the
`-fno-ms-extensions`. However, these Microsoft-specific conditionals are not
consistently handled at the moment. For example, you might find *FIXME*
comments like the one in lines [1012 to
1014](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/Rewrite/RewriteModernObjC.cpp#L1012-L1014):

```c+
// FIXME. Is this attribute correct in all cases?
Setr = "\nextern \"C\" __declspec(dllimport) "
"void objc_setProperty (id, SEL, long, id, bool, bool);\n";
```

More specific to our case, the re-writer (incorrectly?) hardcodes
`__declspec(dllimport)` for `objective-c_autoreleasePoolPush` and
`objective-c_autoreleasePoolPop` in lines [6045 to
6046](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/Frontend/Rewrite/RewriteModernObjC.cpp#L6045-L6046):

```
Preamble += "extern \"C\" __declspec(dllimport) void * objc_autoreleasePoolPush(void);\n";
Preamble += "extern \"C\" __declspec(dllimport) void objc_autoreleasePoolPop(void *);\n\n";
```

Is Objective-C just a transpiler?
---------------------------------

If you got this far, you might be wondering how LLVM makes use of this
Objective-C re-writer. When you compile Objective-C, this re-writer **is not**
used.

Instead, LLVM has an Objective-C frontend that *directly* compiles to LLVM
[IR](https://llvm.org/docs/LangRef.html) (Intermediate Representation), which
is transformed to machine code by the LLVM backend. You can peek into the
production-ready Objective-C frontend for LLVM 16 at
[`clang/lib/CodeGen/CGObjC.cpp`](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/lib/CodeGen/CGObjC.cpp).

Limitations of the re-writer
----------------------------

The fact that normal Objective-C compilation follows a different process
explains some inconsistencies we saw with the re-writer in this article, like
the fact that static strings are put in the `__DATA` segment instead of in the
`__DATA_CONST` segment and missing conditionals around Microsoft-specific
extensions and `dllimport`.

Apart from minor inconsistencies, the re-writer seems to have many other
issues. Unless you provide trivial examples that do not make use of the
[Foundation](https://developer.apple.com/documentation/foundation) framework,
the generated C++ code does not compile. For example, while experimenting with
the "Hello World" program presented at the beginning of this chapter, I found
references to wrong structure names, some Objective-C `@property` declarations
not being re-written, invalid `typedef` aliases, and more.

If we take a detour into LLVM again, Clang's
[README](https://github.com/llvm/llvm-project/blob/llvmorg-16.0.0/clang/README.txt)
states that *"Clang is useful for a number of things beyond just compiling
code: we intend for Clang to be host to a number of different source-level
tools."* Turns out that the Objective-C re-writer is just an side experiment
best-effort tool [started in
2007](https://github.com/llvm/llvm-project/commit/e99c8329af75d6b556b620a335802bbfa6a4b7b8)
by [Chris Lattner](https://nondot.org/sabre/), creator of LLVM and Swift.

Over the last 15 years, this re-writer experiment had consistent casual
contributions and a growing [end-to-end test
suite](https://github.com/llvm/llvm-project/tree/llvmorg-16.0.0/clang/test/Rewriter).
Even if it is still not perfect, you can already learn many things about
Objective-C with it!

**HN Discussion**:
[https://news.ycombinator.com/item?id=38498934](https://news.ycombinator.com/item?id=38498934).
