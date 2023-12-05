---
title: Launching macOS applications from the command-line
date: November 28, 2022
image: generic.jpg
description: This article describes in detail how to launch macOS application bundles from the command line
---

A quick tour on how to run a macOS application bundle in the foreground while
also inheriting standard output and standard error. The executive summary is:

```sh
$ open -W --stdout $(tty) --stderr $(tty) <path/to/Bundle.app>
```

An overview of application bundles
----------------------------------

The macOS platform enforces a predefined directory layout for graphical
applications referred to as the [Application
Bundle](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html).
We will not go into the details of this directory structure in this post, but
you can see examples of it by inspecting macOS built-in applications. Here is
what the high-level directory structure of the `Calculator.app` application
bundle looks like:

```sh
$ tree -L 3 /System/Applications/Calculator.app
/System/Applications/Calculator.app
└── Contents
    ├── Info.plist
    ├── MacOS
    │   └── Calculator
    ├── PkgInfo
    ├── PlugIns
    │   ├── BasicAndSci.calcview
    │   └── Hexadecimal.calcview
    ├── Resources
    │   ├── AppIcon.icns
    │   ├── Assets.car
    │   ├── Base.lproj
    │   ├── Calculator.loctable
    │   ├── ConversionCategories.plist
    │   ├── ConversionSheet-BBBAA77A32-C4EBFEA440.loctable
    │   ├── ConversionSheet.loctable
    │   ├── ConversionsFromBase.plist
    │   ├── ConversionsToBase.plist
    │   ├── InfoPlist.loctable
    │   ├── Localizable.loctable
    │   ├── Speakable.plist
    │   ├── UnitNames.loctable
        ...
    ├── _CodeSignature
    │   └── CodeResources
    └── version.plist

47 directories, 17 files
```

With regards to execution, the application's main executable is always located
inside the `Contents/MacOS` subdirectory. By convention, the executable name
matches the bundle name. For example, the executable of `Calculator.app` is
`Calculator`. However, the application binary is arbitrary as long as it is
properly declared on the `CFBundleExecutable` entry of the
`Contents/Info.plist` file. Plist properties can be easily read using the
`PlistBuddy(8)` built-in tool:

```sh
$ /usr/libexec/PlistBuddy -c "print CFBundleExecutable" /System/Applications/Calculator.app/Contents/Info.plist
Calculator
```

Cocoa and the `open` command
----------------------------

Native macOS applications are typically built using the
[Cocoa](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaFundamentals/WhatIsCocoa/WhatIsCocoa.html)
set of frameworks. In comparison to other operating systems, native macOS
applications *do not steal focus by default*. If you attempt to run a
Cocoa-based application by invoking its main executable directly on the
terminal, the shell will run the app as a child process, capture its standard
input, standard output and standard error, but the application will run on the
background.

Try this out on the `Calculator.app` application. You should see application
logs in your terminal, but the calculator window will not steal focus:

```sh
$ /System/Applications/Calculator.app/Contents/MacOS/Calculator
```

While this behaviour might be surprising at first, it allows the operating
system to have control of whether an application runs in the foreground or in
the background rather than delegating this responsibility to each application.
To support this model, macOS provides the built-in `open(1)` that dates back to
[NextStep](https://en.wikipedia.org/wiki/NeXTSTEP), the pre-cursor of Mac OS X.
The `open(1)` command provides a plethora of options for running application
bundles or load documents in application bundles. By default, it runs an
application and brings their windows to the foreground, but this behaviour may
be omitted using the `-g` option.

Try this out on the `Calculator.app`:

```sh
# Run the application on the foreground
$ open /System/Applications/Calculator.app
# Run the application on the background
$ open -g /System/Applications/Calculator.app
```

Improving on the defaults
-------------------------

If you paid attention when running the last examples, you noticed two important
distinctions of `open(1)`'s default behaviour compared to directly running the
application bundle's executable:

- `open(1)` immediately returns control to the shell
- `open(1)` does not pipe standard output and standard error back to the shell

### Process hierarchy

When directly running the application's executable, `ps(1)` allows us to
confirm that the shell owns the application process. In my setup, the
application's parent process id (PPID) equals the process id (PID) of my shell:

```sh
$ ps -f
  UID   PID  PPID   C STIME   TTY           TIME CMD
  ...
  501 38133   747   0  8:42PM ttys005    0:00.31 -zsh
  501 38343 38133   0  8:42PM ttys005    0:00.43 /System/Applications/Calculator.app/Contents/MacOS/Calculator
  ...
```

In comparison, if we run the application using `open(1)`, the application
process is owned by the process with an id (PID) of 1: the
[`launchd`](https://en.wikipedia.org/wiki/Launchd) init process. In other
words, `open(1)` spawns the application process in a detached mode:

```sh
$ ps -A -x -f
  UID   PID  PPID   C STIME   TTY           TIME CMD
    0     1     0   0  8:26AM ??         3:09.23 /sbin/launchd
  ...
  501 39528     1   0  8:45PM ??         0:00.52 /System/Applications/Calculator.app/Contents/MacOS/Calculator
  ...
```

As a solution, the `open(1)` command supports the `-W` option to wait for the
application to quit before exiting:

```sh
$ open -W /System/Applications/Calculator.app
```

Interestingly enough, this does not cause `open(1)` to run the application as a
child process. The application is still ran in detached mode, but `open(1)`
will wait on the application's process id using a system call such as
`waitpid(2)`:

```sh
$ ps -A -x -f
  UID   PID  PPID   C STIME   TTY           TIME CMD
    0     1     0   0  8:26AM ??         3:12.89 /sbin/launchd
  ...
  501 42889     1   0  8:54PM ??         0:00.42 /System/Applications/Calculator.app/Contents/MacOS/Calculator
  ...
  501 42796   747   0  8:54PM ttys003    0:00.12 -zsh
  ...
  501 42888 42796   0  8:54PM ttys003    0:00.04 open -W /System/Applications/Calculator.app
  ...
```

### TTYs and Standard I/O

We know that `open(1)` will never run the application bundle as a child
process. This explains why `open(1)` does not pipe standard I/O to our shell
and why we cannot see the applications logs anymore as we could by running the
executable directly. However, `open(1)` supports options called `--stdin`,
`--stdout` and `--stderr` to pipe standard input, standard output and standard
error to paths provided by the user, respectively.

When a shell starts, its process is associated to a pseudo-teletype (TTY)
special character device. For example, my current `zsh` session is associated
with the `ttys004` device located in `/dev/ttys004`. The `tty(1)` command is a
handy utility to print the TTY device associated with the current process'
standard I/O. If you need to get this value programmatically, you can use the
[`ttyname(3)`](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/isatty.3.html)
function from the standard C library.

```sh

$ ps
  PID TTY           TIME CMD
  ...
47136 ttys004    0:00.17 -zsh

$ file /dev/ttys004
/dev/ttys004: character special (16/4)

$ tty
/dev/ttys004
```

Unsurprisingly, I can print to my current terminal session by piping data to
this special character device:

```sh
$ echo "Hello" > /dev/ttys004
Hello
```

Leaving standard input aside, which is uncommon for macOS graphical
applications to read, we can pipe standard output and error to the caller
terminal by pointing `--stdout` and `--stderr` to the shell's TTY. We can pair
this with `-W` to ensure we get clean output:

```sh
$ open -W --stdout $(tty) --stderr $(tty) /System/Applications/Calculator.app
```

What about Chromium?
--------------------

Interestingly enough, many Chromium-based apps like Google Chrome and Brave
always steal focus, even when executing their application bundle binaries
directly, and Electron-based apps are no exception. As a consequence, standard
`open(1)` flags like `-g` to run an application on the background do not work
at all with these apps:

```sh
# Wrong behaviour! The app still opens in the foreground
$ open -g /Applications/Google\ Chrome.app
```

Why this happens is a topic for a future post!
