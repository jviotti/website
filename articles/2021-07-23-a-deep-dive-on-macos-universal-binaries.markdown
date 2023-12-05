---
title: A deep dive on macOS universal binaries
date: July 23, 2021
image: generic.jpg
description: This article describes in detail how Mach-O universal binaries work
---

In 2006, Apple transitioned macOS from PowerPC to Intel processors. In 2020,
Apple is transitioning macOS from Intel to ARM. In both cases, universal
binaries played a key role on enabling a smooth CPU architecture transition for
both developers and end-users.

Universal binaries, internally referred to as *fat binaries*, are not Mach-O
objects. Instead, Apple defines fat binaries as simple archives that embed one
or more Mach-O objects.

Let's take the `/usr/bin/wc` utility as an example. The `file(1)` command
detects `/usr/bin/wc` as being an x86_64 and arm64 universal binary:

```sh
$ file /usr/bin/wc
/usr/bin/wc: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64e:Mach-O 64-bit executable arm64e]
/usr/bin/wc (for architecture x86_64):  Mach-O 64-bit executable x86_64
/usr/bin/wc (for architecture arm64e):  Mach-O 64-bit executable arm64e
```

### Parsing the `fat_header` structure

The format of a fat binary is defined in the `/usr/include/mach-o/fat.h` header
within your macOS SDK installation. Assuming you have Xcode installed, the full
path to this header file is the following:

```sh
$(xcrun --show-sdk-path)/usr/include/mach-o/fat.h
```

This file defines the following structures:

```c
struct fat_header {
	uint32_t	magic;		/* FAT_MAGIC or FAT_MAGIC_64 */
	uint32_t	nfat_arch;	/* number of structs that follow */
};

struct fat_arch {
	cpu_type_t	cputype;	/* cpu specifier (int) */
	cpu_subtype_t	cpusubtype;	/* machine specifier (int) */
	uint32_t	offset;		/* file offset to this object file */
	uint32_t	size;		/* size of this object file */
	uint32_t	align;		/* alignment as a power of 2 */
};

struct fat_arch_64 {
	cpu_type_t	cputype;	/* cpu specifier (int) */
	cpu_subtype_t	cpusubtype;	/* machine specifier (int) */
	uint64_t	offset;		/* file offset to this object file */
	uint64_t	size;		/* size of this object file */
	uint32_t	align;		/* alignment as a power of 2 */
	uint32_t	reserved;	/* reserved */
};
```

A fat binary consists of a `fat_header` structure followed by N `fat_arch` or
`fat_arch_64` structures followed by the corresponding Mach-O objects in order.
A fat binary can define a single architecture. However a fat binary cannot
declare the same architecture more than once.

The 4-byte `magic` constant is used by tools such as `file(1)` to determine
whether the file is a fat binary. Additionally, the magic constant determines
whether `fat_arch` or `fat_arch_64` structures will be used. In comparison to
`fat_arch`, `fat_arch_64` uses 64-bit unsigned integers for the offset and
size. As a consequence, `fat_arch_64` can describe larger Mach-O objects than
`fat_arch`.

Let's dump the first 48 octets of `/usr/bin/wc`:

```
$ xxd -l 48 -c 12 /usr/bin/wc
00000000: cafe babe 0000 0002 0100 0007  ............
0000000c: 0000 0003 0000 4000 0000 dba0  ......@.....
00000018: 0000 000e 0100 000c 8000 0002  ............
00000024: 0001 4000 0000 daf0 0000 000e  ..@.........
```

The fat binary starts with the constant `0xCA 0xFE 0xBA 0xBE`. This means that
the fat binary will use `fat_arch` structures, according to the following
definitions from `mach-o/fat.h`:

```c
#define FAT_MAGIC     0xcafebabe
#define FAT_MAGIC_64  0xcafebabf
```

The `magic` constant is followed by the 32-bit unsigned integer 2, which means
that `fat_header` is followed by two `fat_arch` structures.

### Parsing `fat_arch` structures

The first `fat_arch` structure looks like this:

```
cpu_type_t cputype       = 0100 0007 = CPU_TYPE_X86_64 (CPU_TYPE_X86 | CPU_ARCH_ABI64)
cpu_subtype_t cpusubtype = 0000 0003 = CPU_SUBTYPE_X86_64_ALL
uint32_t offset          = 0000 4000 = 16384
uint32_t size            = 0000 dba0 = 56224
uint32_t align           = 0000 000e = 14
```

The `cpu_type_t` and `cpu_subtype_t` fields represent the target architecture
of the corresponding Mach-O object. The `$(xcrun
--show-sdk-path)/usr/include/mach/machine.h` header defines these CPU types in
terms of the legacy Mach `integer_t` type:

```
typedef integer_t       cpu_type_t;
typedef integer_t       cpu_subtype_t;
```

In turn, `integer_t` is defined as a 32-bit signed integer by `$(xcrun
--show-sdk-path)/usr/include/mach/machine/machine_types.defs`:

```c
type integer_t = int32_t;
```

The `mach/machine.h` header defines the valid `cpu_type_t` and `cpu_subtype_t`
values. In this case, this `fat_arch` structure represents a generic x86_64
Mach-O object (`CPU_TYPE_X86_64` with subtype `CPU_SUBTYPE_X86_64_ALL`).

The fat binary defines that the Mach-O object starts at the offset 16384. We
can corroborate that the offset is correct by reading the first two octects at
such position. The result corresponds to the Little Endian `MH_CIGAM` Mach-O
magic constant defined in `$(xcrun
--show-sdk-path)/usr/include/mach-o/loader.h`:

```sh
$ xxd -s 16384 -l 4 /usr/bin/wc
00004000: cffa edfe                                ....
```

The remaining fields of the `fat_arch` structure tell us that the Mach-O object
has a size of 56224 bytes and that the object is aligned to 16384 (2 ^ 14)
bytes.

The second `fat_arch` structure looks like this:

```
cpu_type_t cputype       = 0100 000c = CPU_TYPE_ARM64 (CPU_TYPE_ARM | CPU_ARCH_ABI64)
cpu_subtype_t cpusubtype = 8000 0002 = CPU_SUBTYPE_ARM64E
uint32_t offset          = 0001 4000 = 81920
uint32_t size            = 0000 daf0 = 56048
uint32_t align           = 0000 000e = 14
```

This time, the CPU information refers to 64-bit ARMv8.3 (`CPU_TYPE_ARM64` with
subtype `CPU_SUBTYPE_ARM64E`). The offset of this Mach-O object is 81920, the
next multiple of 16384 (due to `align`) after the offset of the previous
`fat_arch` structure (16384 + 56224 = 72608). We can corroborate that this
offset points to the start of a valid Mach-O object like we did before:

```sh
$ xxd -s 81920 -l 4 /usr/bin/wc
00014000: cffa edfe                                ....
```

The remaining fields of the `fat_arch` structure tell us that the Mach-O object
has a size of 56048 bytes and that the object is again aligned to 16384 (2 ^
14) bytes.

To automate this process, we can parse fat binaries using the `lipo(1)` utility
tool that ships with macOS along with its `-detailed_info` option:

```sh
$ lipo -detailed_info /usr/bin/wc
Fat header in: /usr/bin/wc
fat_magic 0xcafebabe
nfat_arch 2
architecture x86_64
    cputype CPU_TYPE_X86_64
    cpusubtype CPU_SUBTYPE_X86_64_ALL
    capabilities 0x0
    offset 16384
    size 56224
    align 2^14 (16384)
architecture arm64e
    cputype CPU_TYPE_ARM64
    cpusubtype CPU_SUBTYPE_ARM64E
    capabilities PTR_AUTH_VERSION USERSPACE 0
    offset 81920
    size 56048
    align 2^14 (16384)
```

### Extracting Mach-O objects

A fat binary is a simple uncompressed archive format to embed more than one
standalone Mach-O object in a single file. Each Mach-O object is associated
with a `fat_arch` or `fat_arch_64` structure that defines its offset and size
within the fat binary.

Let's use this knowledge to extract the arm64 Mach-O object from the
`/usr/bin/wc` fat binary. We know that the offset and the size of the arm64
variant is 81920 and 56048, respectively. Therefore, we can use `dd(1)` to
extract the executable into a file called `wc-arm` as follows:

```sh
$ dd if=/usr/bin/wc of=wc-arm iseek=81920 count=56048 bs=1
56048+0 records in
56048+0 records out
56048 bytes transferred in 0.123558 secs (453617 bytes/sec)
```

Running `file(1)` over the newly created file correctly reports that the file
is an arm64 Mach-O object:

```sh
$ file wc-arm
wc-arm: Mach-O 64-bit executable arm64e
```

We can confirm that the binary works by giving execution permissions to it and
using it to count the number of characters in a given string:

```sh
$ chmod +x wc-arm
$ echo "hello" | ./wc-arm -c
       6
```

Instead of manually calculating the start and end offsets and extracting the
objects using `dd(1)`, we can use `lipo(1)` with the `-thin` option by passing
the architecture that we want to extract as a command-line argument:

```sh
$ lipo /usr/bin/wc -thin arm64e -output wc-arm
$ file wc-arm
wc-arm: Mach-O 64-bit executable arm64e
```

### Creating Fat Executable Binaries

The `lipo(1)` utility can be used to create fat binaries out of existing Mach-O
objects using the `-create` option. Let's create a basic C program called
`test.c` that prints a message passed by the pre-processor at build time:

```c
#include <stdio.h>

int main() {
  printf("Test %s\n", ARCH);
  return 0;
}
```

We will compile `test.c` to both arm64 and x86_64, using `-D` to pass a
different architecture message in each case. The arm64 executable will print
`Test arm64` while the Intel x64 executable will print `Test x86_64`:

```sh
$ clang test.c -o arm64-test -arch arm64 -DARCH=\"arm64\"
$ clang test.c -o x86_64-test -arch x86_64 -DARCH=\"x86_64\"
```

We will merge the `arm64-test` and `x86_64-test` Mach-O objects into a fat
binary called `universal-test` using `lipo(1)`:

```sh
$ lipo -create arm64-test x86_64-test -output universal-test
$ file universal-test
universal-test: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64:Mach-O 64-bit executable arm64]
universal-test (for architecture x86_64):       Mach-O 64-bit executable x86_64
universal-test (for architecture arm64):        Mach-O 64-bit executable arm64
```

In order to test the universal binary, we will execute it using the `arch(1)`
utility tool that comes with macOS. This tool takes a fat binary and a desired
architecture to execute inputs. I have an Apple Silicon MacBook Pro, in which
case the arm64 variant will run natively and the x86_64 variant will run on
Rosetta 2:

```sh
$ arch -arm64 ./universal-test
Test arm64
$ arch -x86_64 ./universal-test
Test x86_64
```

### Creating Universal Objects

Fat binaries can bundle any type of Mach-O objects, not only executables of
type `MH_EXECUTE`, and the linker will resolve the right variant automatically.
Let's write a basic C module that exposes a function to print the current
architecture and write different implements for both arm64 and x86_64:

```c
// arch.h
#ifndef ARCH_H_
#define ARCH_H_
#include <stdio.h>
void print_arch();
#endif

// arch-arm64.c
#include "arch.h"
void print_arch() {
  printf("arm64\n");
}

// arch-x86_64.c
void print_arch() {
  printf("x86_64\n");
}
```

Let's separately compile the module for both architectures and create a fat
binary called `arch-universal` out of the results:

```sh
$ clang -c arch-arm64.c -arch arm64
$ clang -c arch-x86_64.c -arch x86_64
$ lipo -create arch-arm64.o arch-x86_64.o -output arch-universal.o
$ file arch-universal.o
arch-universal.o: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit object x86_64] [arm64:Mach-O 64-bit object arm64]
arch-universal.o (for architecture x86_64):     Mach-O 64-bit object x86_64
arch-universal.o (for architecture arm64):      Mach-O 64-bit object arm64
```

Finally, let's write a sample executable program that makes use of this module:

```c
// main.c
#include "arch.h"

int main() {
  print_arch();
}
```

If we compile `main.c` to arm64 and link it to `arch-universal.o`, the linker
will create a Mach-O executable object (not a fat binary) that makes use of the
arm64 implementation of `print_arch`:

```sh
$ clang main.c arch-universal.o -arch arm64 -o main-arm64
$ file main-arm64
main-arm64: Mach-O 64-bit executable arm64
$ ./main-arm64
arm64
```

Similarly, if we compile `main.c` to x86_64 and link it to
`arch-universal.o`, the linker will create a Mach-O executable object that
makes use of the x86_64 implementation of `print_arch`:

```sh
$ clang main.c arch-universal.o -arch x86_64 -o main-x86_64
$ file main-x86_64
main-x86_64: Mach-O 64-bit executable x86_64
$ ./main-x86_64
x86_64
```
