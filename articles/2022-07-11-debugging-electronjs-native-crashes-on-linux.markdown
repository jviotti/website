---
title: Debugging Electron.js native crashes on GNU/Linux
date: July 11, 2022
image: electron-19-0-8-linux-x64-breakpad-symbols.png
description: This article describes in detail how to symbolicalize Electron.js native crashes on GNU/Linux
---

This article aims to explain how to debug a GNU/Linux native crash on a release
build of [Electron.js](https://www.electronjs.org). In the case of GNU/Linux,
this is usually a crash coming from the C++ parts of Electron.js, Chromium or
Node.js. If you maintain a production desktop application built using
Electron.js, a user will report a native crash sooner or later, and it helps to
be prepared for it.

This article is a GNU/Linux adaptation of my [older post on debugging native
crashes on
macOS](https://www.jviotti.com/2021/12/08/debugging-electronjs-native-crashes-on-macos.html).
Some sections of this post have been shamelessly cut-and-pasted from the
original one to make it standalone.

> This article is based on Electron.js v19.0.8 x86_64 running on Ubuntu 20.04
> LTS.

Introducing Chromium's Breakpad and Crashpad
--------------------------------------------

Chromium maintains a cross-platform open-source crash-reporting system called
[Breakpad](https://chromium.googlesource.com/breakpad/breakpad) written in C++
and Objective-C++.  The Breakpad client library provides functionality to
monitor the application for unhandled exceptions, generating dumps and
optionally upload them to Breakpad's own open-source server or Breakpad-aware
third-party error reporting servers such as
[Sentry](https://sentry.io/for/breakpad/) and Mozilla's
[Socorro](https://github.com/mozilla-services/socorro). Chromium also maintains
[Crashpad](https://chromium.googlesource.com/crashpad/crashpad/+/HEAD/README.md),
which is meant to be the eventual successor of Breakpad. Both Crashpad and
Breakpad emit dumps using the same format. At the time of this writing,
Electron.js uses Crashpad on macOS, Windows and GNU/Linux.

When an unhandled exception occurs, both Breakpad and Crashpad generate a dump
using Microsoft's
[minidump](https://docs.microsoft.com/en-ca/windows/win32/debug/dbghelp-structures?redirectedfrom=MSDN)
format. For uniformity and space-efficiency reasons, this Microsoft-specific
dump format is used in all the supported platforms, not only for Windows. You
can read more about minidump files
[here](https://chromium.googlesource.com/breakpad/breakpad/+/HEAD/docs/processor_design.md#dump-files).

Using the `crashReporter` Electron.js module
--------------------------------------------

Electron.js offers the
[`crashReporter`](https://www.electronjs.org/docs/latest/api/crash-reporter)
module to interact with Breakpad and Crashpad from the *main* Electron.js
process using JavaScript. *It is essential for any production-ready Electron.js
application to start the Breakpad client as early as possible during the
application startup logic*.  Otherwise, no dump will be generated if a crash
occurs. For example, you can setup `crashReporter` to generate local-only dumps
as follows:

```js
import { crashReporter, app } from 'electron';
crashReporter.start({ uploadToServer: false });
console.error('Storing dumps inside', app.getPath('crashDumps'));
```

The resulting dumps, if any, will be stored at the path determined by the
configurable
[`crashDumps`](https://www.electronjs.org/docs/latest/api/app#appgetpathname)
setting. By default, this path equals `$HOME/.config/<app name>/Crashpad` for
GNU/Linux.

Fetching Breakpad symbols
-------------------------

The Electron.js release builds that are typically downloaded from [GitHub
Releases](https://github.com/electron/electron/releases) do not include
debugging symbols. Therefore, a dump originating from one of such release
builds omits human-readable information such as symbol names, file names and
line numbers. To simplify the debugging process, developers augment the dump
with human-readable information in the form of [Breakpad symbol
files](https://chromium.googlesource.com/breakpad/breakpad/+/HEAD/docs/symbol_files.md).
Electron.js publishes Breakpad symbols for every official release on GitHub
Releases.

We are running Electron.js v19.0.8 x86_64 for GNU/Linux, so we would download
[electron-v19.0.8-linux-x64-symbols.zip](https://github.com/electron/electron/releases/download/v19.0.8/electron-v19.0.8-linux-x64-symbols.zip)
from the [v19.0.8
release](https://github.com/electron/electron/releases/tag/v19.0.8):

![Electron v19.0.8 GNU/Linux x86_64 official Breakpad symbols](../../../images/electron-19-0-8-linux-x64-breakpad-symbols.png)

It is crucial to use the Breakpad symbols that were extracted when compiling
the precise release build of Electron.js that the application is running.
Electron.js builds are not deterministic. Therefore, the same Breakpad symbols
cannot be used by two Electron.js builds produced out of the exact same source
tree and with the same build arguments.

*Parsing a dump with the incorrect Breakpad symbols is worse than having no
symbols on the first place!*

These are the contents of the Electron.js v19.0.8 GNU/Linux x86_64 symbols ZIP
archive. The directory in which we are interested in is `breakpad_symbols`,
which contains
[`*.sym`](https://chromium.googlesource.com/breakpad/breakpad/+/HEAD/docs/symbol_files.md)
files that describe each ELF file in the Electron.js bundle:

```sh
electron-v19.0.8-linux-x64-symbols
├── LICENSE
├── LICENSES.chromium.html
├── breakpad_symbols
│   ├── electron
│   │   └── 56D9E86E18DCA5EB47E0083D4C1B40BC0
│   │       └── electron.sym
│   ├── libEGL.so
│   │   └── FDBB789C2A465A2261E312142FC065460
│   │       └── libEGL.so.sym
│   └── libGLESv2.so
│       └── 0C1A3A086D0030D11CC32264C9A09A480
│           └── libGLESv2.so.sym
└── version

7 directories, 6 files
```

Extracting symbols from custom Electron.js builds
-------------------------------------------------

As explained previously, Breakpad symbols can only be used to augment dumps
produced by the exact binaries that the symbols have been extracted from.  It
follows that it is not possible to make use of the Breakpad symbols published
for the official Electron.js releases for a custom build of Electron.js. If you
are building Electron.js from source, then you also need to extract the
Breakpad symbols from your build as the official Electron.js builds do and
store them somewhere you can reference them later.

To accomplish this, Electron.js provides a Ninja target called that makes use
of the `dump_syms` tool distributed by Breakpad to extract the symbols from the
various resulting ELF files.

**Note that on GNU/Linux, it is only possible to run these targets when
performing a release build** as Electron.js [guards this logic behind the
`is_official_build`
flag](https://github.com/electron/electron/blob/v19.0.8/BUILD.gn#L1283-L1317).
This flag is only set for the
[`release`](https://github.com/electron/electron/blob/v19.0.8/build/args/release.gn#L3)
profile.

```sh
# (1) Extract Breakpad symbols
$ ninja -C src/out/Release electron:electron_symbols

# (2) Create a ZIP containing the Breakpad symbols
$ ninja -C src/out/Release electron:licenses
$ ninja -C src/out/Release electron:electron_version
$ python3 src/electron/script/zip-symbols.py -b "$(pwd)/src/out/Release"
```

The resulting ZIP is located at `src/out/Release/symbols.zip`.

Using `minidump_stackwalk`
--------------------------

The Breakpad project also ships with a command-line tool named
`minidump_stackwalk` to analyze minidump files, augment them with the Breakpad
symbols obtained before and convert the dumps into human-readable stack-traces.

One way to install `minidump_stackwalk` is to build Breakpad from source as
explained in the
[documentation](https://chromium.googlesource.com/breakpad/breakpad):

```sh
# (1) Clone depot_tools and add it to the PATH
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH="$(pwd)/depot_tools:$PATH"

# (2) Clone Breakpad and its dependencies
$ mkdir breakpad && cd breakpad
$ fetch breakpad && cd src

# (3) Build Breakpad from source
$ ./configure && make

# minidump_stackwalk is located in src/processor
$ file src/processor/minidump_stackwalk
src/processor/minidump_stackwalk: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=71b90819ecaa2175223bb293a5d4e8149dd5152d, for GNU/Linux 3.2.0, with debug_info, not stripped
```

However, if you are building Electron.js from source, then Breakpad is already
available at `src/third_party/breakpad`. The `minidump_stackwalk` tool can be
compiled from an existing Electron.js checkout as follows:

```sh
$ ninja -C src/out/<profile> third_party/breakpad:minidump_stackwalk
$ file src/out/<profile>/minidump_stackwalk
src/out/<profile>/minidump_stackwalk: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=ce4faa5d6bea80e8f077f3a12f693f12f89bd46d, with debug_info, not stripped
```

The `minidump_stackwalk` tool takes a path to a minidump file as the first
positional argument and one or more paths that include Breakpad symbols. For
example:

```sh
$ ./path/to/minidump_stackwalk path/to/dump.dmp path/to/breakpad_symbols
```

Putting it into practice
------------------------

In the context of Electron.js, we can use the
[`process.crash()`](https://www.electronjs.org/docs/latest/api/process#processcrash)
JavaScript function in the main process to cause a native crash.

However, to make the example more interesting, we will artificially cause the
official Electron.js GNU/Linux x86_64 v19.0.8 release build to crash by
deleting `resources.pak`, a set of
[GRIT](https://www.chromium.org/developers/tools-we-use-in-chromium/grit/grit-users-guide/)
resources used by Electron.js such as [user-interface
strings](https://github.com/electron/electron/blob/v19.0.8/electron_strings.grdp)
for internationalization purposes.

```sh
$ rm resources.pak
```

The [default
application](https://github.com/electron/electron/tree/v19.0.8/default_app)
distributed by the official Electron.js release builds at
`Electron.app/Contents/Resources/default_app.asar` does not start the crash
reporter. In order to produce local dumps, we extend the default application
code to start the
[`crashReporter`](https://www.electronjs.org/docs/latest/api/crash-reporter)
module as explained previously:

```diff
diff --git a/default_app/main.ts b/default_app/main.ts
index c1b309170..1ec2c1c0b 100644
--- a/default_app/main.ts
+++ b/default_app/main.ts
@@ -3,7 +3,9 @@ import * as electron from 'electron';
 import * as fs from 'fs';
 import * as path from 'path';
 import * as url from 'url';
-const { app, dialog } = electron;
+const { app, dialog, crashReporter } = electron;
+
+crashReporter.start({ uploadToServer: false });

 type DefaultAppOptions = {
   file: null | string;
```

If you have a local Electron.js checkout, you can apply the above patch,
re-build the application and replace the
[`default_app.asar`](https://github.com/electron/asar) archive on the release
build as follows:

```sh
# (1) Apply the patch described above
$ patch --directory src/electron --strip 1 < path/to/patch

# (2) Rebuild the default application
$ ninja -C src/out/<profile> electron:default_app_asar

# (3) Copy the new default application into the release build
$ cp src/out/<profile>/resources/default_app.asar \
  path/to/electron/resources/default_app.asar
```

Running the application using the `electron` executable results in a crash, as
expected. The error messages clearly indicates that the `resources.pak` file is
missing. As the file definition declares, these logs are printed by
[`resource_bundle.cc`](https://source.chromium.org/chromium/chromium/src/+/refs/tags/102.0.5005.148:ui/base/resource/resource_bundle.cc;l=987-988)
when failing to load PAK files that are not marked as optional:

```sh
$ ./electron
[153116:0711/182237.496224:ERROR:resource_bundle.cc(987)] Failed to load /home/jviotti/Downloads/electron-v19.0.8-linux-x64/resources.pak
Some features may not be available.
[1:0711/182237.496947:ERROR:resource_bundle.cc(987)] Failed to load /home/jviotti/Downloads/electron-v19.0.8-linux-x64/resources.pak
Some features may not be available.
...
[153113:0711/182237.724802:ERROR:resource_bundle.cc(987)] Failed to load /home/jviotti/Downloads/electron-v19.0.8-linux-x64/resources.pak
Some features may not be available.
zsh: trace trap (core dumped)  ./electron
```

Once the application exits, a dump file is created at
`$HOME/.config/Electron/Crashpad`. According to Crashpad's [database
documentation](https://chromium.googlesource.com/crashpad/crashpad/+/refs/heads/main/tools/crashpad_database_util.md),
a dump is moved to `completed` if it was uploaded correctly or if it does not
qualify to be uploaded. The corresponding `.meta` file contains report
information such as the upload time and upload attempts.

```sh
$ tree "$HOME/.config/Electron/Crashpad"
├── attachments
├── client_id
├── completed
│   ├── 0bf78140-2e91-4ee1-bb05-47ebbee457a4.dmp
│   └── 0bf78140-2e91-4ee1-bb05-47ebbee457a4.meta
├── new
├── pending
└── settings.dat

4 directories, 4 files

$ cd "$HOME/.config/Electron/Crashpad/completed"
$ file 0bf78140-2e91-4ee1-bb05-47ebbee457a4.dmp
0bf78140-2e91-4ee1-bb05-47ebbee457a4.dmp: Mini DuMP crash report, 7 streams, Mon Jul 11 22:11:53 2022, 0x0 type
```

Next, we will inspect this minidump file using `minidump_stackwalk` and the
Breakpad symbols corresponding to our official Electron.js build:
[electron-v19.0.8-linux-x64-symbols.zip](https://github.com/electron/electron/releases/download/v19.0.8/electron-v19.0.8-linux-x64-symbols.zip):

```sh
# (1) Download and extract the Breakpad symbols
$ curl --location --output electron-v19.0.8-linux-x64-symbols.zip \
  https://github.com/electron/electron/releases/download/v19.0.8/electron-v19.0.8-linux-x64-symbols.zip
$ unzip electron-v19.0.8-linux-x64-symbols.zip -d electron-v19.0.8-linux-x64-symbols

# (2) Convert the dump into a human-readable stack-trace
$ ./path/to/minidump_stackwalk \
  "$HOME/.config/Electron/Crashpad/completed/0bf78140-2e91-4ee1-bb05-47ebbee457a4.dmp"
  electron-v19.0.8-linux-x64-symbols/breakpad_symbols
```

The `minidump_stackwalk` tool produces significant debugging output. However,
these are the key highlights for this case:

```
...
Thread 0 (crashed)
 0  electron!ui::ResourceBundle::GetLocalizedStringImpl(int) const [resource_bundle.cc : 1168 + 0x1]
    ...
 1  electron!ui::ResourceBundle::GetLocalizedString(int) [resource_bundle.cc : 775 + 0x5]
    ...
 2  electron!l10n_util::GetStringUTF16(int) [l10n_util.cc : 771 + 0xe]
    ...
 3  electron!pdf_extension_util::AddStrings(pdf_extension_util::PdfViewerContext, base::Value*) [pdf_extension_util.cc : 149 + 0x9]
    ...
 4  electron!extensions::ElectronComponentExtensionResourceManager::ElectronComponentExtensionResourceManager() [electron_component_extension_resource_manager.cc : 37 + 0xa]
    ...
 5  electron!electron::ElectronExtensionsBrowserClient::ElectronExtensionsBrowserClient() [unique_ptr.h : 725 + 0x8]
    ...
 6  electron!electron::ElectronBrowserMainParts::PreMainMessageLoopRun() [unique_ptr.h : 725 + 0x8]
    ...
```

Many of these functions are defined in Chromium. The
[`DEPS`](https://github.com/electron/electron/blob/v19.0.8/DEPS#L5) file of
Electron.js declares that v19.0.8 depends on Chromium 102.0.5005.148. An easy
way to inspect Chromium's source code is to use the online [Chromium Code
Search](https://source.chromium.org/chromium/chromium/src) web-app. We can
select the Chromium version we want to inspect at the top left part of the
screen:

![Selecting Chromium 102.0.5005.148 on Chromium Code Search](../../../images/chromium-source-select-102-0-5005-148.png)

The top entry of the stack points at line number 1168 of the
`ui::ResourceBundle::GetLocalizedStringImpl(int)` function defined in
[`ui/base/resource/resource_bundle.cc`](https://source.chromium.org/chromium/chromium/src/+/refs/tags/102.0.5005.148:ui/base/resource/resource_bundle.cc).
This line number contains a production assertion that checks that fetching the
data resource declared by `resource_id` results in non-empty data:

```c++
std::u16string ResourceBundle::GetLocalizedStringImpl(int resource_id) const {
  ...
      data = GetRawDataResource(resource_id);
      CHECK(!data.empty())
          << "Unable to find resource: " << resource_id
          << ". If this happens in a browser test running on Windows, it may "
             "be that dead-code elimination stripped out the code that uses the"
             " resource, causing the resource to be stripped out because the "
             "resource is not used by chrome.dll. See "
             "https://crbug.com/1181150.";
  ...
```

Let's inspect the highlighted frames from the bottom-up to learn how we ended
up there. Frame #6 points us at the
`electron::ElectronBrowserMainParts::PreMainMessageLoopRun()` function defined
by Electron.js in
[`shell/browser/electron_browser_main_parts.cc`](https://github.com/electron/electron/blob/v19.0.8/shell/browser/electron_browser_main_parts.cc#L429-L430):

```c++
int ElectronBrowserMainParts::PreMainMessageLoopRun() {
...
#if BUILDFLAG(ENABLE_ELECTRON_EXTENSIONS)
  ...
  extensions_browser_client_ =
      std::make_unique<ElectronExtensionsBrowserClient>();
  ...
#endif
...
```

This function initializes the
[`ElectronExtensionsBrowserClient`](https://github.com/electron/electron/blob/v19.0.8/shell/browser/extensions/electron_extensions_browser_client.h)
class if the `ENABLE_ELECTRON_EXTENSIONS` build flag is set. This macro
definition is set by the
[`buildflags/BUILDFLAG.gn`](https://github.com/electron/electron/blob/v19.0.8/buildflags/BUILD.gn#L19)
GN definition if the `enable_electron_extensions` GN argument is set. Such
argument is defaulted to `true` by
[`buildflags/buildflags.gni`](https://github.com/electron/electron/blob/v19.0.8/buildflags/buildflags.gni#L30):

```
...
  # Enable Chrome extensions support.
  enable_electron_extensions = true
...
```

Inspecting Frame #5, we can see that the constructor of the
`ElectronExtensionsBrowserClient` class defined in
[`shell/browser/extensions/electron_extensions_browser_client.cc`](https://github.com/electron/electron/blob/v19.0.8/shell/browser/extensions/electron_extensions_browser_client.cc#L59-L74)
in turn initializes the `ElectronComponentExtensionResourceManager` class
declared in
[`shell/browser/extensions/electron_component_extension_resource_manager.h`](https://github.com/electron/electron/blob/v19.0.8/shell/browser/extensions/electron_component_extension_resource_manager.h):

```c++
ElectronExtensionsBrowserClient::ElectronExtensionsBrowserClient()
  ...
  resource_manager_ =
      std::make_unique<extensions::ElectronComponentExtensionResourceManager>();
  ...
```

Inspecting Frame #4, we can see that the constructor of the
`ElectronComponentExtensionResourceManager` class has logic to setup the PDF
viewer for internationalization purposes if the `ENABLE_PDF_VIEWER` build flag
is set:

```c++
ElectronComponentExtensionResourceManager::
    ElectronComponentExtensionResourceManager() {
  ...
#if BUILDFLAG(ENABLE_PDF_VIEWER)
  ...
  // Register strings for the PDF viewer, so that $i18n{} replacements work.
  base::Value pdf_strings(base::Value::Type::DICTIONARY);
  pdf_extension_util::AddStrings(
      pdf_extension_util::PdfViewerContext::kPdfViewer, &pdf_strings);
  ...
#endif
}
```

Similar to `ENABLE_ELECTRON_EXTENSIONS`, the `ENABLE_PDF_VIEWER` macro
definition is set by
[`buildflags/BUILD.gn`](https://github.com/electron/electron/blob/v19.0.8/buildflags/BUILD.gn#L16)
if the `enable_pdf_viewer` is enabled. This GN argument is also defaulted to
`true` by
[`buildflags/buildflags.gni`](https://github.com/electron/electron/blob/v19.0.8/buildflags/buildflags.gni#L15).

Frame #3 takes us back at Chromium. The `pdf_extension_util::AddStrings`
function defined in
[`chrome/browser/pdf/pdf_extension_util.cc`](https://source.chromium.org/chromium/chromium/src/+/refs/tags/102.0.5005.148:chrome/browser/pdf/pdf_extension_util.cc;l=176-186;bpv=0;bpt=1)
calls the
[`AddPdfViewerStrings`](https://source.chromium.org/chromium/chromium/src/+/refs/tags/102.0.5005.148:chrome/browser/pdf/pdf_extension_util.cc;l=54-160;drc=b7ab9ca5f95bf642973381e326bfb3dea74cc55d;bpv=0;bpt=1)
function defined in the same file. The latter will attempt to load a series of
PDF-related GRIT resources:

```c++
// Adds strings that are used only by the stand-alone PDF Viewer.
void AddPdfViewerStrings(base::Value* dict) {
  static constexpr webui::LocalizedString kPdfResources[] = {
    {"annotationsShowToggle", IDS_PDF_ANNOTATIONS_SHOW_TOGGLE},
    {"bookmarks", IDS_PDF_BOOKMARKS},
    {"bookmarkExpandIconAriaLabel", IDS_PDF_BOOKMARK_EXPAND_ICON_ARIA_LABEL},
    {"downloadEdited", IDS_PDF_DOWNLOAD_EDITED},
    {"downloadOriginal", IDS_PDF_DOWNLOAD_ORIGINAL},
    {"labelPageNumber", IDS_PDF_LABEL_PAGE_NUMBER},
    {"menu", IDS_MENU},
    {"moreActions", IDS_DOWNLOAD_MORE_ACTIONS},
    {"passwordDialogTitle", IDS_PDF_PASSWORD_DIALOG_TITLE},
    {"passwordInvalid", IDS_PDF_PASSWORD_INVALID},
    {"passwordPrompt", IDS_PDF_NEED_PASSWORD},
    {"passwordSubmit", IDS_PDF_PASSWORD_SUBMIT},
    {"present", IDS_PDF_PRESENT},
    {"propertiesApplication", IDS_PDF_PROPERTIES_APPLICATION},
    {"propertiesAuthor", IDS_PDF_PROPERTIES_AUTHOR},
    {"propertiesCreated", IDS_PDF_PROPERTIES_CREATED},
    {"propertiesDialogClose", IDS_CLOSE},
    {"propertiesDialogTitle", IDS_PDF_PROPERTIES_DIALOG_TITLE},
    {"propertiesFastWebView", IDS_PDF_PROPERTIES_FAST_WEB_VIEW},
    {"propertiesFastWebViewNo", IDS_PDF_PROPERTIES_FAST_WEB_VIEW_NO},
    {"propertiesFastWebViewYes", IDS_PDF_PROPERTIES_FAST_WEB_VIEW_YES},
    {"propertiesFileName", IDS_PDF_PROPERTIES_FILE_NAME},
    {"propertiesFileSize", IDS_PDF_PROPERTIES_FILE_SIZE},
    {"propertiesKeywords", IDS_PDF_PROPERTIES_KEYWORDS},
    {"propertiesModified", IDS_PDF_PROPERTIES_MODIFIED},
    {"propertiesPageCount", IDS_PDF_PROPERTIES_PAGE_COUNT},
    {"propertiesPageSize", IDS_PDF_PROPERTIES_PAGE_SIZE},
    {"propertiesPdfProducer", IDS_PDF_PROPERTIES_PDF_PRODUCER},
    {"propertiesPdfVersion", IDS_PDF_PROPERTIES_PDF_VERSION},
    {"propertiesSubject", IDS_PDF_PROPERTIES_SUBJECT},
    {"propertiesTitle", IDS_PDF_PROPERTIES_TITLE},
    {"thumbnailPageAriaLabel", IDS_PDF_THUMBNAIL_PAGE_ARIA_LABEL},
    {"tooltipDocumentOutline", IDS_PDF_TOOLTIP_DOCUMENT_OUTLINE},
    {"tooltipDownload", IDS_PDF_TOOLTIP_DOWNLOAD},
    {"tooltipPrint", IDS_PDF_TOOLTIP_PRINT},
    {"tooltipRotateCCW", IDS_PDF_TOOLTIP_ROTATE_CCW},
    {"tooltipThumbnails", IDS_PDF_TOOLTIP_THUMBNAILS},
    {"zoomTextInputAriaLabel", IDS_PDF_ZOOM_TEXT_INPUT_ARIA_LABEL},
  ...
  for (const auto& resource : kPdfResources)
    dict->SetStringKey(resource.name, l10n_util::GetStringUTF16(resource.id));
  ...
```

It is clear now that the crash occurs because Chromium cannot load a certain
GRIT-encoded string related to the PDF viewer component. These PDF-related
strings are defined in
[`components/pdf_strings.grdp`](https://source.chromium.org/chromium/chromium/src/+/refs/tags/102.0.5005.148:components/pdf_strings.grdp).
Its resulting PAK file is included by Electron.js in
[`electron_paks.gni`](https://github.com/electron/electron/blob/v19.0.8/electron_paks.gni#L98-L100)
to be included within `resources.pak`, the file we deleted:

```
output = "${invoker.output_dir}/resources.pak"
...
if (enable_pdf_viewer) {
  sources += [ "$root_gen_dir/chrome/pdf_resources.pak" ]
  deps += [ "//chrome/browser/resources/pdf:resources" ]
}
...
```

It would have been extremely difficult to pin-point the problem without a
human-readable stack-trace!
