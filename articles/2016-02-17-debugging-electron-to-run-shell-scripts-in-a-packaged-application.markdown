---
title: Debugging Electron to run shell scripts in a packaged application
date: February 17, 2016
image: generic.jpg
description: This article discusses a file permissions error on Electron that can affect spawning, and an upstream fix for it
---

I've been working on [Etcher][etcher], a cross-platform [Electron][electron]
application to flash OS images.

[In Windows, the maximum length of a file path is 260
characters](https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx).
To work around this limitation, Electron encourages developers to package their
applications for distribution using a tar-like format called [`asar`][asar].

For `asar`s to work, [Electron patches some functions from the Node.js API to
treat an `asar` package as a virtual
directory](https://github.com/atom/electron/blob/master/docs/tutorial/application-packaging.md#node-api).
One of the patched functions is
[`child_process.execFile`](https://nodejs.org/api/child_process.html#child_process_child_process_execfile_file_args_options_callback),
which when called on a file inside an `asar` archive, will extract the file
into a temporary location and execute it from there.

Etcher makes use of an `npm` module called [`drivelist`][drivelist] to list the
connected drives. This module executes some shell scripts using
`child_process.execFile`, and parses back the results.

We get the following mysterious error as soon as we package the application
inside an `asar` and try running `drivelist`:

```
Error: spawn EACCES
```

The problem is that `asar` discards execution permissions from the files it
archives. For example:

```sh
# Install the command line utility tool
$ npm install -g asar

# Create a directory containing an executable file
$ mkdir asar_test
$ touch asar_test/foo
$ chmod 755 asar_test/foo

# Check that the file has execution permissions for the everyone
$ ls -l asar_test/foo
-rwxr-xr-x  1 jviotti  staff  0 Nov 26 21:54 asar_test/foo*

# Pack the directory and extract the resulting archive
$ asar pack asar_test app.asar
$ asar extract app.asar output

# The file indeed lost its execution permissions
$ ls -l output/foo
-rw-r--r--  1 jviotti  staff  0 Nov 26 21:57 asar_test/foo
```

By looking closer at `asar`, we can see that it stores a serialized 8 bytes
JSON header [at the beginning of the
archive](https://github.com/atom/asar#format) that indexes the files and
directories stored in the archive along with boolean `executable` properties,
[which are set to `true` if the files have execution permissions at the point
where the archive was
created](https://github.com/atom/asar/blob/master/src/filesystem.coffee#L45):

```coffee
if process.platform isnt 'win32' and stat.mode & 0o100
     node.executable = true
```

We can fix this by consulting the `executable` property using the `stat` method
provided by `asar` as part of the `child_process.execFile` Electron function,
and adding the execution permission using `fs.chmod` after the file is
extracted into a temporary location.

> See the following pull request that implements this fix:
> https://github.com/atom/electron/pull/3595

After the above fix, the application runs flawlessly on UNIX based operating
systems, however, we get a new error on Windows:

```
Error: spawn UNKNOWN
```

By taking another closer look at Electron and `asar`, we can see that Electron
extracts files out of the archive appending a generic `.tmp` extension. This
comes from Chromium's
[`CreateTemporaryFile`](https://code.google.com/p/chromium/codesearch#chromium/src/base/files/file_util.h&q=CreateTemporaryFile&sq=package:chromium&type=cs&l=227)
utility, which makes use of [`GetTempFileName` from the Windows
API](https://msdn.microsoft.com/en-us/library/windows/desktop/aa364991%28v=vs.85%29.aspx),
which according to the docs:

> The `GetTempFileName` function creates a temporary file name of the following
> form:
>
> `<path>\<pre><uuuu>.TMP`

Windows fails with an `UNKNOWN` error as it doesn't know how to execute a
`.tmp` file. The solution is to append the file extension when extracting files
out of the `asar`, to we get a `.bat` extension after `.tmp`.

> See the following pull request that implements this fix:
> https://github.com/atom/electron/pull/3648

[etcher]: https://etcher.io
[electron]: http://electron.atom.io/
[asar]: https://github.com/atom/asar
[drivelist]: https://github.com/resin-io/drivelist
