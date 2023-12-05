---
title: Fixing a baffling issue when running Electron as root in GNU/Linux
date: February 19, 2016
image: electron-linux-capset-bug-fedora.png
description: This article discusses a Chromium sandboxing permission error when executing an Electron application as root on GNU/Linux
---

I'm working on [Etcher][etcher], a cross-platform [Electron][electron] to flash
operating systems images to removable drives.

The application needs to get write permissions over devices, so we present a
nice "elevation" dialog at the start of the application to run the application
as `root`.

This works great in OS X and Windows, however, we faced the following error on
GNU/Linux:

```
Uncaught Error: Cannot find module '/home/jviotti/Projects/etcher/node_modules/electron-prebuilt/dist/resources/atom.asar/renderer/lib/init.js'
```

![Demonstration of the error on Fedora 22](../../../images/electron-linux-capset-bug-fedora.png)

Notice that the bug only manifests itself when running an Electron application
on GNU/Linux as `root`.

[This
file](https://github.com/atom/electron/blob/master/atom/renderer/lib/init.js)
is in charge of exposing Electron's public APIs, exporting Node.js bindings to
`global`, and generally initialising the renderer context.

Failing to load this file means that we can't `require()` any modules nor do
anything meaningful, leading the app to a broken state.

We can check that this file exists by using the [`asar`][asar] command line
utility tool:

```sh
asar list resources/atom.asar | grep /renderer/lib/init.js /renderer/lib/init.js
```

After diving into the Electron codebase, the root of the error is
`file_.IsValid()`, a [utility function from
Chromium](https://code.google.com/p/chromium/codesearch#chromium/src/base/files/file.h&q=IsValid&sq=package:chromium&type=cs&l=185),
which returns `-1` on `atom.asar` in [`atom/common/asar/archive.cc's
Archive::Init()`](https://github.com/atom/electron/blob/master/atom/common/asar/archive.cc).

After having a closer look at `file.h`, we see there is a [method called
`error_details` that returns
`Error`](https://code.google.com/p/chromium/codesearch#chromium/src/base/files/file.h&q=IsValid&sq=package:chromium&type=cs&l=197)
that seems to be what we're looking for:

```cpp
// Returns the OS result of opening this file. Note that the way to verify
// the success of the operation is to use IsValid(), not this method:
//   File file(path, flags);
//   if (!file.IsValid())
//     return;
Error error_details() const { return error_details_; }
```

There is also a nice [`static` method to convert `Error` to
`std::string`](https://code.google.com/p/chromium/codesearch#chromium/src/base/files/file.h&q=IsValid&sq=package:chromium&type=cs&l=303):

```cpp
// Converts an error value to a human-readable form. Used for logging.
static std::string ErrorToString(Error error);
```

By combining these two functions, the error becomes `FILE_ERROR_ACCESS_DENIED`.

Why access denied? We're running the application as the superuser, who
presumably has access to everything, and we don't get the error when running
the application as a normal user.

See the following output from running the application with some improved error
logging:

```
$ sudo ./out/D/electron
33204
33204
(electron) loadUrl is deprecated. Use loadURL instead.
33204
-1
Archive is invalid: (FILE_ERROR_ACCESS_DENIED): /home/jviotti/electron-current/out/D/resources/atom.asar
-1
...
Archive is invalid: (FILE_ERROR_ACCESS_DENIED): /home/jviotti/electron-current/out/D/resources/atom.asar
-1
Archive is invalid: (FILE_ERROR_ACCESS_DENIED): /home/jviotti/electron-current/out/D/resources/atom.asar
[30652:0128/113606:ERROR:CONSOLE(340)] "Uncaught Error: Cannot find module '/home/jviotti/electron-current/out/D/resources/atom.asar/renderer/lib/init.js'", source: module.js (340)
```

Notice that the operation succeds a couple of times before the "access denied"
error.

After some experimentation with
[`getuid()`](http://man7.org/linux/man-pages/man2/getuid.2.html), we can see
the operation works from Electron's main thread but fails from any renderer
threads.

Turns out Chromium drops all capabilities from renderer threads with the
[`capset` Linux system call](http://linux.die.net/man/2/capset), which makes
sense from a security point of view in the context of a web browser:

```cpp
// See https://code.google.com/p/chromium/codesearch#chromium/src/sandbox/linux/services/credentials.cc&q=ForkAndDrop&sq=package:chromium&type=cs&l=325

pid_t Credentials::ForkAndDropCapabilitiesInChild() {
  pid_t pid = fork();
  if (pid != 0) {
    return pid;
  }

  // Since we just forked, we are single threaded.
  PCHECK(DropAllCapabilitiesOnCurrentThread());
  return 0;
}
```

Electron makes use of a project called
[`libchromiumcontent`][libchromiumcontent], which provides a shared library
that includes Chromium and all its dependencies. The project contains a set of
`diff` patches that are applied on top of Chromium’s source during the build
phase, which is a perfect place for the fix.

> See the submitted pull request containing the patch here:
> https://github.com/atom/libchromiumcontent/pull/180

The fix described above landed in Electron v0.36.8.

[etcher]: https://etcher.io
[electron]: http://electron.atom.io/
[asar]: https://github.com/atom/asar
[libchromiumcontent]: https://github.com/atom/libchromiumcontent
