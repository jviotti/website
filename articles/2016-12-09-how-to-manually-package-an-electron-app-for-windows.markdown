---
title: How to manually package an Electron app for Windows
date: December 9, 2016
image: electron-default-app-windows.png
description: This article describes how to package an Electron application for Windows without additional tooling
---

There are plenty of modules that take care of packaging Electron applications
for all supported operating systems, such as
[electron-packager][electron-packager] and
[electron-builder][electron-builder], however its useful to know what's going
on under the hood.

Download Electron
-----------------

The way Electron packaging works is that the developer downloads a pre-built
version of Electron, and customizes the package to include their custom code
and resources. You can find pre-built Electron packages at the official [GitHub
Releases][electron-gh-releases].

For this post, we're going to use [v1.4.4][electron-1-4-4], so we'll go ahead
and download [`electron-v1.4.4-win32-x64.zip`][electron-1-4-4-win32-x64].

Let's decompress the ZIP and take a look inside:

```sh
$ unzip electron-v1.4.4-win32-x64.zip
$ ls -1
LICENSE
LICENSES.chromium.html
blink_image_resources_200_percent.pak
content_resources_200_percent.pak
content_shell.pak
d3dcompiler_47.dll
electron.exe
ffmpeg.dll
icudtl.dat
libEGL.dll
libGLESv2.dll
locales/
natives_blob.bin
node.dll
resources/
snapshot_blob.bin
ui_resources_200_percent.pak
version
views_resources_200_percent.pak
xinput1_3.dll
```

Inject your custom code
-----------------------

If you execute `electron.exe` before making any modifications, you'll get the
default Electron application, which lives at `resources/default_app.asar`:

```sh
$ ls -1 resources
default_app.asar
electron.asar
```

![Electron default application](../../../images/electron-default-app-windows.png)

[`asar`][asar] is a tar-like archive format developed by Electron to overcome
problems such as the [Windows maximum path length
limitations][windows-max-path].

If you're curious, you can install the `asar` command line tool and unpack the
default application source code:

```sh
$ npm install -g asar
$ asar extract default_app.asar default_app
$ ls -1 default_app
default_app.js
icon.png
index.html
main.js
package.json
```

Electron defines its default search path for application code in
[`lib/browser/init.js`](https://github.com/electron/electron/blob/master/lib/browser/init.js):

```javascript
const searchPaths = ['app', 'app.asar', 'default_app.asar']
for (packagePath of searchPaths) {
    try {
        packagePath = path.join(process.resourcesPath, packagePath)
        packageJson = require(path.join(packagePath, 'package.json'))
        break
    } catch (error) {
        continue
    }
}
```

This means that Electron will attempt to first open any code located at
`resources/app`. If it can't find any code there, it will try
`resources/app.asar`, otherwise will fallback to `resources/default_app.asar`.

In order to include our custom application code in the Electron package, lets
create a directory at `resources/app` and copy every JavaScript/HTML/CSS file
we need into that folder. Then, we can run `asar pack app app.asar --unpack
"{*.dll,*.node}"` to package it up as an `asar`, and delete the original
unpackaged `app` directory.

We can proceed to delete `resources/default_app.asar` since we don't want to
include it in our final package.

Brand the Electron package
--------------------------

We'll do a series of changes to the Electron directory to include our
application information and other related assets.

- Rename `electron.exe` to `<your application>.exe`
- Replace the contents of `LICENSE` with your license
- Replace the contents of `version` with your application's current version

Every `exe` file contains [read-only information embedded
inside](https://en.wikipedia.org/wiki/Resource_%28Windows%29) that includes the
copyright, the product name, the icon, etc. You can see this information by
right-clicking on an `exe` file (a symbolic link to it won't work) and opening
the "Details" pane.

This is what Google Chrome's executable contains:

![Google Chrome exe resources](../../../images/google-chrome-windows-resources.png)

The Electron team built a handy tool called [rcedit][rcedit] to edit this
embedded information. You can download the v0.7.0 binary
[here](https://github.com/electron/node-rcedit/raw/v0.7.0/bin/rcedit.exe), and
put it somewhere accessible in your `%PATH%`.

I'll assume you renamed `electron.exe` to `MyApp.exe`.

Edit the "File description:"

```sh
$ rcedit.exe MyApp.exe --set-version-string "FileDescription" "My app description"
```

Edit the "Internal name:"

```sh
$ rcedit.exe MyApp.exe --set-version-string "InternalName" "My app internal name"
```

Edit the "Original file name:"

```sh
$ rcedit.exe MyApp.exe --set-version-string "OriginalFilename" "MyApp.exe"
```

Edit the "Product name:"

```sh
$ rcedit.exe MyApp.exe --set-version-string "ProductName" "My product name"
```

Edit the "Company name:"

```sh
$ rcedit.exe MyApp.exe --set-version-string "CompanyName" "My company name"
```

Edit the "Legal Copyright:"

```sh
$ rcedit.exe MyApp.exe --set-version-string "LegalCopyright" "My copyright"
```

Edit the "File version:"

```sh
$ rcedit.exe MyApp.exe --set-file-version "My app version"
```

Edit the "Product version:"

```sh
$ rcedit.exe MyApp.exe --set-product-version "My app version"
```

And finally, we'll set the icon:

```sh
$ rcedit.exe MyApp.exe --set-icon path\to\icon.ico
```

Release your application to the world!
--------------------------------------

You can now release the package to the world, although you'll probably want to
create an installer for it (using something like [NSIS][nsis]), but that's a
subject for another post.

[electron-packager]: https://github.com/electron-userland/electron-packager
[electron-builder]: https://github.com/loopline-systems/electron-builder
[electron-gh-releases]: https://github.com/electron/electron/releases
[electron-1-4-4]: https://github.com/electron/electron/releases/tag/v1.4.4
[electron-1-4-4-win32-x64]: https://github.com/electron/electron/releases/download/v1.4.4/electron-v1.4.4-win32-x64.zip
[asar]: https://github.com/electron/asar
[windows-max-path]: https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
[rcedit]: https://github.com/electron/node-rcedit
[nsis]: http://nsis.sourceforge.net/
