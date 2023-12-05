---
title: Speeding up Windows Electron.js builds with SCCACHE
date: July 7, 2021
image: generic.jpg
description: This article describes the back story behind a Chromium CL to restore SCCACHE support on Windows
---

[SCCACHE](https://github.com/mozilla/sccache) is a cross-platform tool
developed by Mozilla to cache C, C++, Rust, and CUDA compilation units to speed
up future compilations.

For various reasons that we will get into soon, SCCACHE does not work when
performing Chromium or Electron.js builds on Windows. I'm leading the Desktop
Engineering team at [Postman](https://www.postman.com), where we run a heavily
modified fork of Electron.js suited to our needs. Running Windows builds was
proving to be either really slow (due to the lack of SCCACHE support) or really
expensive (as we needed to provision incredibly powerful Windows machines to
compensate for the lack of a cache).

This article describes my adventure making SCCACHE work on Windows and
contributing the results back to Chromium:
[9c7622d](https://chromium.googlesource.com/chromium/src/+/9c7622d23e56390856cc8ce287b4537c77147dad).

### SCCACHE vs Goma

Electron.js used to rely on SCCACHE to perform fast builds on macOS and
GNU/Linux. However, it retired SCCACHE support throughout 2020 (see
[#26701](https://github.com/electron/electron/pull/26701) and
[#23297](https://github.com/electron/electron/pull/23297)) and moved entirely
to [Goma](https://chromium.googlesource.com/infra/goma/client/) (see
[#26324](https://github.com/electron/electron/pull/26324) and
[#26476](https://github.com/electron/electron/pull/26476)), an SCCACHE
alternative built by Google. While that sounds great, the main Goma server is
hosted by Google, which only offers access to it to core Chromium and
Electron.js contributors.  While the upstream Electron.js project gets fast
builds both locally and on Continuous Integration due to Goma, companies
operating Electron.js forks typically cannot get Goma access (mainly for
Continuous Integration). Also, running a self-hosted Goma infrastructure is not
an easy task compared to the simplicity of SCCACHE.

Forks can continue to make use of SCCACHE for macOS and GNU/Linux on Chromium
and Electron.js builds, however SCCACHE results in few cache-hits on Windows
despite supporting MSVC as an official compiler.  There have been various
requests and unsuccessful attempts in both Electron.js
([#15090](https://github.com/electron/electron/issues/15090)) and Chromium
([#787983](https://bugs.chromium.org/p/chromium/issues/detail?id=787983)) to
make SCCACHE, or a similar technology, work on Windows. The lack of SCCACHE
Windows support was one of the reasons why the Electron.js upstream project
eventually moved to Goma.

### Profile Guided Optimization (PGO)

PGO is an technique implemented by clang to help the compiler make better
optimization choices based on an existing profile that aims to represent common
runtime execution patterns. If you are curious, you can explore how Chromium
implements PGO support at
[`src/build/config/compiler/pgo`](https://source.chromium.org/chromium/chromium/src/+/main:build/config/compiler/pgo/).

Sadly, SCCACHE does not support PGO yet. However, at the time of this writing,
there is an open PR to address this feature:
[#952](https://github.com/mozilla/sccache/pull/952). Until that PR is merged,
we can easily disable PGO support by declaring the following GN argument:

```
chrome_pgo_phase = 0
```

### `/Brepro` and deterministic builds

The `cl.exe` MSVC compiler supports an *undocumented* flag called `/Brepro`
that allows the linker to not inject timestamps into the compiled objects to
support deterministic builds.

SCCACHE does not recognize the undocumented `/Brepro` flag as a valid compiler
option, and marks the outcome as un-cacheable for safety reasons. There is an
[in-progress PR](https://github.com/mozilla/sccache/pull/980) to white-list
this flag in the SCCACHE MSVC definition. Until then, we can disable it.
Interestingly enough, turns out that the `/Brepro` flag is [automatically
disabled when using
Goma](https://chromium.googlesource.com/chromium/src/+/48e0435a92b1e0b1f9687e8aa1d904af31130554)
too, as the Goma backend does not support it either.

### `/showIncludes:user` and `.ninja-deps`

Similar to other compilers such as GCC, the `cl.exe` MSVC compiler can be
configured to output the list of included file paths of the source files to
`stderr`.  The Ninja build system parses this dependency information during the
build process and maintains an internal dependency database, `.ninja-deps`, to
optimize rebuilds.  To perform this task, the `cl.exe` compiler officially
supports the `/showIncludes` option that outputs all include file paths,
including the system ones. To optimize the Ninja internal dependency database,
the clang-cl project introduced a `/showIncludes:user` variant that omits
system include paths.

However, SCCACHE does not recognize the possibility of an argument to the
`/showIncludes` flag in their MSVC compiler implementation, leading to
un-cacheable compilation requests.

We can use the officially supported `/showIncludes` flag to make SCCACHE work
and optimize Ninja rebuilds. We pay the cost of parsing and maintaining a
larger dependency database, however that overhead is minimal compared to the
compile speed increase provided by SCCACHE.

### Final results

Once all the discusses changes are applied, the SCCACHE stats will show that
the cache starts getting populated:

```
Compile requests                  27222
Compile requests executed         27222
Cache hits                          515
Cache hits (C/C++)                  515
Cache misses                      26707
Cache misses (C/C++)              26707
Cache timeouts                        0
Cache read errors                     0
Forced recaches                       0
Cache write errors                    0
Compilation failures                  0
Cache errors                          8
Cache errors (C/C++)                  8
Non-cacheable compilations            0
Non-cacheable calls                   0
Non-compilation calls                 0
Unsupported compiler calls            0
Average cache write               0.001 s
Average cache read miss           8.813 s
Average cache read hit            0.003 s
Failed distributed compilations       0
```

Re-running the build in top of the cache results in a high number of cache hits
and a 3x build time improvement in our setup:

```
Compile requests                  27222
Compile requests executed         27222
Cache hits                        27218
Cache hits (C/C++)                27218
Cache misses                          4
Cache misses (C/C++)                  4
Cache timeouts                        0
Cache read errors                     0
Forced recaches                       0
Cache write errors                    0
Compilation failures                  0
Cache errors                          0
Non-cacheable compilations            0
Non-cacheable calls                   0
Non-compilation calls                 0
Unsupported compiler calls            0
Average cache write               0.000 s
Average cache read miss           8.364 s
Average cache read hit            0.028 s
Failed distributed compilations       0
```

The Chromium CL landed on a recent version of Chromium that is not consumed by
Electron.js yet. However, you can still backport [the
patch](https://chromium.googlesource.com/chromium/src/+/9c7622d23e56390856cc8ce287b4537c77147dad)
to your Chromium tree, which we are doing for our Electron.js v11 builds.
