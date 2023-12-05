---
title: Debugging the C++ standard library on macOS
date: May 5, 2022
image: appleclang-llvm.png
description: This article describes how to use LLDB on C++ standard library code on macOS
---

C++ is far from being an easy programming language to master. I found that a
great way to learn advanced C++, albeit an intimidating one sometimes, is to
take peeks at undoubtedly one of the most complex pieces of C++: the *C++
Standard Template Library* implementation from [LLVM](https://llvm.org).

This article describes how to build [*libc++*](https://libcxx.llvm.org) (LLVM's
standard library implementation) from source, how to build your own C++
programs against it and more importantly, exemplify how to explore *libc++*
through [LLDB](https://lldb.llvm.org). This article focuses on macOS, but
covered the concepts should easily translate to other LLVM-supported platforms.

AppleClang vs LLVM
------------------

If you are running macOS, you are most likely making use of `clang` out of an
[Xcode](https://developer.apple.com/xcode/) installation. Xcode does not bundle
LLVM directly. Instead, Xcode maintains a custom distribution of LLVM which
confusingly enough, follows a different versioning strategy compared to
upstream LLVM. Therefore, if we want to explore the version of the C++ standard
library that our Xcode installation is based on, we first need to determine
which LLVM version it corresponds to.

We can determine which version of Xcode we are running by using
`PlistBuddy(8)`.  Assuming your Xcode installation lives at
`/Applications/Xcode.app`, you can obtain its version as follows:

```sh
$ /usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" /Applications/Xcode.app/Contents/Info.plist
13.3.1
```

We can also determine the AppleClang version we are running by printing its
version information:

```sh
$ clang --version
Apple clang version 13.1.6 (clang-1316.0.21.2.3)
Target: arm64-apple-darwin21.4.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

[Wikipedia](https://en.wikipedia.org/wiki/Xcode#Version_comparison_table)
maintains a version comparison table associating Xcode and AppleClang versions
to their corresponding upstream LLVM versions. My system is running Xcode
13.3.1 with AppleClang version 13.1.6, which according to Wikipedia, maps to
LLVM 13.0.0:

![Xcode to LLVM comparison table](../../../images/appleclang-llvm.png)

Building libc++
---------------

Let's clone LLVM and checkout
[13.0.0](https://github.com/llvm/llvm-project/releases/tag/llvmorg-13.0.0), the
version corresponding to my Xcode installation:

```sh
$ git clone https://github.com/llvm/llvm-project
$ cd llvm-project
$ git checkout llvmorg-13.0.0
```

LLVM adopts the [CMake](https://cmake.org) build system. Instead of building
the entirety of LLVM, we can use `cmake` to only build the *libc++* shared
library component and its dependencies as follows:

```sh
$ mkdir build
$ cmake -G Ninja -S runtimes -B build \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_INCLUDE_TESTS=OFF \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"
$ ninja -C build cxx cxxabi
```

We can find our own *libc++* shared library inside `build/lib`:

```sh
$ file build/lib/libc++.dylib
build/lib/libc++.dylib: Mach-O 64-bit dynamically linked shared library arm64
```

This shared library includes support for all the C++ standards supported by its
corresponding LLVM version.

Linking Against libc++
----------------------

Let's write a basic C++17 program that uses a standard library feature only
available on C++17, such as
[`std::unordered_map`](https://en.cppreference.com/w/cpp/container/unordered_map)'s
[`insert_or_assign`](https://en.cppreference.com/w/cpp/container/unordered_map/insert_or_assign)
method:

```c++
// test.cc
#include <unordered_map>
#include <string>
#include <iostream>

int main() {
  std::unordered_map<std::string, std::string> test;
  test.insert({"foo", "bar"});
  test.insert_or_assign("foo", "baz");
  std::cout << test.at("foo") << "\n";
  return 0;
}
```

We can compile this C++17 program against our custom *libc++* build as follows:

```sh
$ clang++ -g -nostdinc++ -nostdlib++ \
  -isystem <path/to/llvm-project>/build/include/c++/v1 \
  -L <path/to/llvm-project>/lib -l c++ \
  -Wl,-rpath,<path/to/llvm-project>/lib \
  -std=c++17 \
  test.cc -o test
```

The `-nostdinc++` and `-nostdlib++` flags tell `clang` to not include the
default standard library. The `-isystem` flag tells `clang` to add the given
path to the system include search path. The next two flags link the program
against our *libc++* build. The `-Wl,-rpath` directive adds our custom build
library folder as an `@rpath` directive on the resulting Mach-O binary.
Finally, `-std` sets the C++ standard to compile against.

We can confirm the program has been linked against our custom *libc++*:

```sh
$ otool -L test
test:
        @rpath/libc++.1.dylib (compatibility version 1.0.0, current version 1.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.100.3)
```

Where `@rpath` has been set to the `build/lib` directory within our LLVM
checkout:

```sh
$ otool -l test
...
Load command 15
          cmd LC_RPATH
      cmdsize 72
         path <path/to/llvm-project>/build/lib (offset 12)
```

Running the program works as expected:

```sh
$ ./test
baz
```

Attaching LLDB on libc++
------------------------

As confirmed by the presence of the `LC_SYMTAB` and `LC_DYSYMTAB` Mach-O load
commands on `libcxx.1.dylib`, our *libc++* build includes debugging symbols
that allow us to explore the C++ standard library through the use of LLDB:

```sh
$ otool -l build/lib/libc++.dylib
...
Load command 7
     cmd LC_SYMTAB
 cmdsize 24
  symoff 849184
   nsyms 7070
  stroff 963712
 strsize 430360
Load command 8
            cmd LC_DYSYMTAB
        cmdsize 80
      ilocalsym 0
      nlocalsym 4385
     iextdefsym 4385
     nextdefsym 2221
      iundefsym 6606
      nundefsym 464
         tocoff 0
           ntoc 0
      modtaboff 0
        nmodtab 0
   extrefsymoff 0
    nextrefsyms 0
 indirectsymoff 962304
  nindirectsyms 352
      extreloff 0
        nextrel 0
      locreloff 0
        nlocrel 0
...
```

After loading the `test` program on LLDB, we can confirm the program loads our
custom *libc++* build by using the `image list` command:

```sh
$ lldb test
(lldb) target create "test"
Current executable set to '/Users/jviotti/Projects/test' (arm64).
(lldb) image list
[  0] BC3564E3-5ECE-3E4B-8F1F-B33E55F5A0DE 0x0000000100000000 /Users/jviotti/Projects/test
      /Users/jviotti/Projects/test.dSYM/Contents/Resources/DWARF/test
...
[  3] C2087C40-CE4A-38D9-93E8-17FC27009982 0x0000000000000000 /Users/jviotti/Projects/llvm-project/build/lib/libc++.1.dylib
...
[ 40] 9DD254EE-ED97-3989-B46A-AF29B25E425A 0x0000000000000000 /Users/jviotti/Projects/llvm-project/build/lib/libc++abi.1.dylib
...
```

We can find symbols from the standard library to break on using the `image
lookup` command as usual. For example, we can find the `insert_or_assign`
method of `std::unordered_map` that we have used in the test program:

```sh
(lldb) image lookup --regex --symbol insert_or_assign
2 symbols match the regular expression 'insert_or_assign' in /Users/jviotti/Projects/test:
        Address: test[0x0000000100001d90] (test.__TEXT.__text + 652)
        Summary: test`std::__1::pair<std::__1::__hash_map_iterator<std::__1::__hash_iterator<std::__1::__hash_node<std::__1::__hash_value_type<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, void*>*> >, bool> std::__1::unordered_map<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::pair<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > > >::insert_or_assign<char const (&) [4]>(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >&&, char const (&) [4]) at unordered_map:1241        Address: test[0x00000001000077f4] (test.__TEXT.__stubs + 312)
        Summary: test`symbol stub for: std::__1::pair<std::__1::__hash_map_iterator<std::__1::__hash_iterator<std::__1::__hash_node<std::__1::__hash_value_type<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, void*>*> >, bool> std::__1::unordered_map<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::pair<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > > >::insert_or_assign<char const (&) [4]>(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >&&, char const (&) [4])
```

Finally, we can break on `insert_or_assign` as expected and start
exploring areas of interest within the standard library:

```sh
(lldb) breakpoint set --func-regex insert_or_assign
Breakpoint 1: where = test`std::__1::pair<std::__1::__hash_map_iterator<std::__1::__hash_iterator<std::__1::__hash_node<std::__1::__hash_value_type<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, void*>*> >, bool> std::__1::unordered_map<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::pair<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > > >::insert_or_assign<char const (&) [4]>(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >&&, char const (&) [4]) at unordered_map:1241, address = 0x0000000100001d90
(lldb) run
Process 60223 launched: '/Users/jviotti/Projects/test' (arm64)
Process 60223 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1 2.1
    frame #0: 0x0000000100001d90 test`std::__1::pair<std::__1::__hash_map_iterator<std::__1::__hash_iterator<std::__1::__hash_node<std::__1::__hash_value_type<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, void*>*> >, bool> std::__1::unordered_map<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::pair<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > > >::insert_or_assign<char const (this=0x0000000000036b74 size=0, __k="", __v=<no value available>) [4]>(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >&&, char const (&) [4]) at unordered_map:1241
   1238     template <class _Vp>
   1239         _LIBCPP_INLINE_VISIBILITY
   1240         pair<iterator, bool> insert_or_assign(key_type&& __k, _Vp&& __v)
-> 1241     {
   1242         pair<iterator, bool> __res = __table_.__emplace_unique_key_args(__k,
   1243             _VSTD::move(__k), _VSTD::forward<_Vp>(__v));
   1244         if (!__res.second) {
Target 0: (test) stopped.
```
