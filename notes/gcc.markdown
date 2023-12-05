---
title: GNU Compiler Collection
description: A set of notes and recipes about the GNU Compiler Collection, mainly related to the C frontend
---

Basics
------

- **Enable verbose output**: run `gcc` with the `-v` option. This can be useful
  to check all the steps and options gcc used to generate the result
- **Save temporary files**: set `--save-temps` to force gcc to save all
  generated files in the current directory, such as the preprocessor result
  (`.i`), the assembly code (`.s`), and more
- **Create object files**: set the `-c` option
- **Generate assembly code**: set the `-S` option
- **Link object files**: pass the `.o` files to gcc: `gcc file1.o file2.o
  fileN.o -o a.out`

Compilation is a multi-stage process involving the compiler itself, the
assembler, and the linker. This complete set of tools is referred to as a
toolchain. We may manually go through this multi-stage process like this:

1. Use `cpp` to expand each source's preprocessor directives

    ```sh
    cpp file.c > file.i
    ```

2. Convert each resulting source file into assembly code

    ```sh
    gcc -Wall -S file.i -o file.s
    ```
3. Convert assembly code into machine code

    ```sh
    as file.s -o file.o
    ```

4. Create a final executable using the linker. This command usually very
   complex and system-specific. We can check the command that gcc uses in a
   specific system by running gcc in its verbose mode. On my particular system,
   this is:

```sh
/usr/bin/ld \
  -dynamic \
  -arch x86_64 \
  -macosx_version_min 10.13.5 \
  -weak_reference_mismatches non-weak \
  -o main \
  -L/usr/local/Cellar/gcc/7.3.0_1/lib/gcc/7/gcc/x86_64-apple-darwin17.3.0/7.3.0 \
  -L/usr/local/Cellar/gcc/7.3.0_1/lib/gcc/7/gcc/x86_64-apple-darwin17.3.0/7.3.0/../../.. \
  main.o \
  -no_compact_unwind \
  -lSystem \
  -lgcc_ext.10.5 \
  -lgcc \
  -lSystem
```

### Common Options

GCC exposes many frontend-independent options that are sometimes
platform-dependent. These can be accessed using the `-m` option. Here are some
common ones:

- `-m32` and `-m64`: Generate 32-bit or 64-bit code, respectively
- `-march=CPU`: Target a particular processor for optimal performance. The
  resulting binary will not run in any other processor
- `-mcpu=CPU`: Tune the code for a particular processor, but still allow the
  program to run in other processors that share the same architecture. This
  option can't achieve the same performance optimisations as `-march=CPU`, but
  its a good compromise between speed and portability

Search Paths
------------

The various default search paths may include system-dependent or
installation-specific directories.

### Include Path

The include path determines where the preprocessor will look for header files.
We can preppend a directory to the include path by using the `-I` option, which
may be used multiple times. Alternatively, we can use the `C_INCLUDE_PATH` (or
`CPLUS_INCLUDE_PATH` for C++), where we may put multiple paths separated by
colons. Note that `-I` takes precedence over the environment variables, which
in turn take precedence over the system include directories.

We can inspect the default include path by running:

```sh
echo | gcc -E -Wp,-v -
```

From https://unix.stackexchange.com/a/77781/43448.

### Library Search Path

Also called link path, determines where the linker will look for static and
shared libraries. We may use the `-L` option, or the `LIBRARY_PATH` environment
variable, to preppend directories to this search path. The same precedence
rules as with the include path apply.

### Load Library Path

The load library path determines the places the linker will check when
resolving shared libraries at runtime. We may tweak this directory list using
the `LD_LIBRARY_PATH` environment variable. GNU systems may have a
`/etc/ld.so.conf` configuration file as well.

We can inspect the default library path by running:

```sh
ld -v 2
```

Compiler Warnings
-----------------

GCC will not output any warnings by default. Its recommended to *always* enable
`-Wall`, which can check most common issues. The `-Werror` option can be used
to turn all warnings into errors. Data-flow analysis is not performed unless
you compile with optimizations, so the optimization level `-O2` is recommended
to get the best warnings.

Here are some of the most important options enabled by `-Wall`:

- `-Wcomment`: Warn about nested comments
- `-Wformat`: Warn about the incorrect use of format strings in functions such
  as `printf` and `scanf`
- `-Wunused`: Warn about unused variables
- `-Wimplicit`: Warn about any functions that are used without being declared
- `-Wreturn-type`: Warn about functions that are defined without a return type
  but not declared void. It also catches empty return statements in functions
  that are not declared void
- `-Wuninitialized`: Warn about variables that are read without being
  initialized. It only works when the program is subjected to data-flow
  analysis

The `-W` option is another general option such as `-Wall`, which warns about a
selection of common programming errors. In practice, the options `-W` and
`-Wall` are used together.

Other additional warnings include:

- `-Wconversion`: Warn about implicit type conversions that could cause
  unexpected results
- `-Wshadow`: Warn about the redeclaration of a variable name in a scope where
  it has already been declared
- `-Wcast-qual`: Warn about pointers that are cast to remove a type qualifier
  such as `const`
- `-Wwrite-strings`: This option implicitly give a `const` qualifier to all
  string constants defined in the program, causing a compile-time warning if
  there is an attempt to overwrite them
- `-Wtraditional`: Warn about parts of the code which would be interpreted
  differently by an ANSI/ISO compiler and a "traditional" pre-ANSI compiler

Optimizations
-------------

The compiler can optimise for speed or binary size, usually at the expense of
the other. GCC provides various optimization levels, as well as some individual
options for specific types of optimizations.

- `-O0` (or no `-O`): This is default behaviour. The compiler will not perform
  any optimizations and will compile the code in the most straightforward way.
  This is the best option for debugging purposes

- `-O1` (or just `-O`): Turn on the most common type of optimizations that do
  not require any speed-space tradeoffs

- `-O2`: Turn on even more optimizations, still without any speed-space
  tradeoffs. This is generally the best choice when releasing a program

- `-O3`: This mode *may* increase speed, but may also increase the program's
  size. These optimizations are not favorable under some circumstances, and may
  make the program slower

- `-Os`: Optimize for size. The aim is to produce the smallest possible
  executable. This may also make the program faster due to better cache usage

- `-funroll-loops`: Turn on loop unrolling, which will increase executable
  size, but may increase speed

- `-fpack-struct`: Pack structs to save space

Optimizing a program makes debugging more complex, and increases resource usage
during compilation. In most case, we can use `-O0` debugging, and `-O2` for
development and releases. Optimizations may have a negative impact in certain
programs, so the rule of thumb is to always measure before commiting to any
optimization options.

Enabling any optimization level triggers data flow analysis, which may result
in further warnings.

Preprocessor
------------

We may set an preprocessor macro during compilation with the `-D` option. For
example: `gcc -Wall -DFOO main.c`, or `gcc -Wall -DBAR=BAZ main.c`.

When including headers, the only difference between `#include "file.h"` and
`#include <file.h>` is that the former looks at the current working directory
before looking at the system include directories.

The compiler usually defines some macros on the reserved namespace (prefixed
with double undercores) by default, and some small number of system-specific
macros. We can check these by running:

```sh
$ cpp -dM /dev/null
#define OBJC_NEW_PROPERTIES 1
#define _LP64 1
#define __APPLE_CC__ 6000
#define __APPLE__ 1
#define __ATOMIC_ACQUIRE 2
#define __ATOMIC_ACQ_REL 4
#define __ATOMIC_CONSUME 1
#define __ATOMIC_RELAXED 0
#define __ATOMIC_RELEASE 3
#define __ATOMIC_SEQ_CST 5
#define __BIGGEST_ALIGNMENT__ 16
#define __BLOCKS__ 1
...
#define __x86_64 1
#define __x86_64__ 1
```

These may be disabled with the `-ansi` option.

The programmer may print the result of applying the preprocessor over a source
file by running:

```sh
gcc -E file.c
```

The resulting source code is printed to standard output.

Compatibility
-------------

We can force GCC to adhere to specific language standards using the `-std`
option.

- `-std=c89` or `-std=c90` or `-std=iso9899:1990`: The original ANSI/ISO C
  language standard (ANSI X3.159-1989, ISO/IEC 9899:1990)

- `-std=iso9899:199409`: The ISO C language standard with ISO Amendment 1,
  published in 1994

- `-std=c99` or `-std=iso9899:1999`: The revised ISO C language standard,
  published in 1999 (ISO/IEC 9899:1999)

- `std=c11` or `std=iso9899:2011`: ISO C11, the 2011 revision of the ISO C
  standard.

- `-std=gnu89` or `-std=gnu90`: The original ANSI/ISO C language standard with
  the GNU extensions

- `-std=gnu99`: The revised ISO C language standard with the GNU extensions

- `-std=gnu11`: The ISO C11 language standard with the GNU extensions

### GNU Extensions

- `-ansi` (equivalent to `-std=c90`): This option disables the GNU extensions
  that conflict with the ANSI/ISO standard.
- `-pedantic`: This option, when used in combination with `-ansi`, disable
  *all* GNU extensions that don't follow the ANSI/ISO standard

The GNU C Library provides macros to control POSIX extensions
(`__POSIX_C_SOURCE`), BSD extensions (`__BSD_SOURCE`), SVID extensions
(`__SVID_SOURCE`), XOPEN extensions (`__XOPEN_SOURCE`) and GNU extensions
(`__GNU_SOURCE`).

The `__GNU_SOURCE` macro enables all these extensions together, with the POSIX
ones taking precedence over the others in case there are conflicts. This macro
will enable the C library extensions even when compiling with the `-ansi`
option.

See https://gcc.gnu.org/onlinedocs/gcc/C-Extensions.html.

Static Libraries
----------------

A static library is a collection of precompiled object files that may be
*copied* into the final executable using static linking. These object files are
joined using the `ar` archive utility, into `libNAME.a` files.

Given a static library `libfoo.a`, you can include it directly on the final
executable: `gcc -Wall main.c libfoo.a -o main`, or use the `-l` shortcut: `gcc
-Wall main.c -L. -lfoo -o main`. The `-l` option will default to a shared
library if one is available.

In order to create a static library:

1. Compile the source files into objects:

    ```sh
    gcc -Wall file1.c file2.c fileN.c -c
    ```

2. Create an archive out of the object files:

    ```sh
    ar cr libfoo.a file1.c file2.c fileN.c
    ```

We can inspect an archive's "table of contents" with `ar t`:

```sh
$ ar t libfoo.a
__.SYMDEF SORTED
file1.o
file2.o
file3.o
...
```

Shared Libraries
----------------

A shared library is a collection of precompiled object files that are resolved
at runtime. In order to create a shared library with GCC:

1. Compile the source files into objects:

    ```sh
    gcc -fPIC -Wall file1.c file2.c fileN.c -c
    ```

The `PIC` option tells GCC to generate *Position Independent Code*, which means
the linker will not need to relocate anything from the `.text` section (i.e.
because it uses relative jumps), and thus the library's code can be loaded as
read-only, and shared among different programs.

2. Create a shared library using the `-shared` option:

    ```sh
    gcc -shared -o libfoo.so file1.o file2.o fileN.o
    ```

3. Link against the shared library as usual:

    ```sh
    gcc -Wall -lfoo -o test test.c
    ```

The library will be dynamically loaded given its present on the load library
path. We can inspect the test binary to see the shared libraries its pointing
to:

```sh
test:
        libfoo.so (compatibility version 0.0.0, current version 0.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)
```

Code Coverage
-------------

First, compile a program with `-fprofile-arcs` and `-ftest-coverage`, which
adds additional instructions to record what lines have been executed, and then
run the binary as many times as needed.

GCC will create `.gcda` and `.gcno` files recording the code path information
that we can parse by calling `gcov` with the name of the binary:

```sh
$ gcov
File 'main.c'
Lines executed:85.71% of 7
Creating 'main.c.gcov'
```

We can then inspect the `.gcov` files, which are annotated versions of the
source files stating what code paths have not been executed.

Resources
---------

- An Introduction to GCC
