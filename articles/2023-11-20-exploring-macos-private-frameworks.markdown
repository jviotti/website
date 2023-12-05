---
title: Exploring macOS private frameworks
date: November 20, 2023
image: xcode-developer-documentation.png
description: This article describes a series of approaches for reverse engineering macOS private frameworks
---

Apple develops a growing amount of frameworks. As an application developer, you
are probably familiar with public frameworks such as
[AppKit](https://developer.apple.com/documentation/appkit?language=objc) and
[Core Data](https://developer.apple.com/documentation/coredata?language=objc).
These frameworks are well documented, and you will find lots of tutorials and
examples at
[developer.apple.com](https://developer.apple.com/documentation/technologies?language=objc)
or in the Xcode developer documentation (at `Help -> Developer Documentation`):

![Exploring AppKit using Xcode Developer Documentation](../../../images/xcode-developer-documentation.png)

Apart from public frameworks, macOS ships with over 1000 private frameworks
that are used by system services or as dependencies of public frameworks. Due
to their private nature, these frameworks are not documented at all.

This article presents a series of non-exclusive approaches for digging into
private frameworks, using the [Disk
Utility](https://support.apple.com/en-gb/guide/disk-utility/welcome/mac)
built-in application as an example. Whether you are a security researcher or
want a deeper understanding of how macOS software works, being able to peek
into these private frameworks is a great tool to keep in your tool belt.

> The credit from this post goes to [Wojciech
> Reguła](https://wojciechregula.blog), from whom I learnt all of these
> techniques (and more!)

Approach 1: `otool`
-------------------

Xcode comes with a command-line program called `otool(1)`. This is a
general-purpose tool for interacting with
[Mach-O](https://en.wikipedia.org/wiki/Mach-O) Apple binary files. One of its
convenient features is to list the shared libraries a Mach-O executable links
to (using the `-L` option). With it, we can identify the private frameworks
that Apple applications or services link to.

The *Disk Utility* built-in application we will be looking into in this article
lives in `/System/Applications/Utilities/Disk Utility.app`. Following the
structure of [macOS application
bundles](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html)
and its `Info.plist`, we can determine its main executable is
`Contents/MacOS/Disk Utility`.

Every private macOS framework resides in `/System/Library/PrivateFrameworks`,
so we can filter `otool(1)` results by `PrivateFrameworks` using `grep(1)`:

```sh
$ otool -L /System/Applications/Utilities/Disk\ Utility.app/Contents/MacOS/Disk\ Utility | grep PrivateFrameworks
    /System/Library/PrivateFrameworks/Restore.framework/Versions/A/Restore (compatibility version 1.0.0, current version 615.0.0)
    /System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement (compatibility version 1.0.0, current version 1.0.0)
    /System/Library/PrivateFrameworks/StorageKit.framework/Versions/A/StorageKit (compatibility version 1.0.0, current version 53.0.0)
    /System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/DiskImages (compatibility version 1.0.8, current version 649.0.0)
    /System/Library/PrivateFrameworks/IASUtilities.framework/Versions/A/IASUtilities (compatibility version 1.0.0, current version 119.0.0)
    /System/Library/PrivateFrameworks/LocalAuthenticationRecoveryUI.framework/Versions/A/LocalAuthenticationRecoveryUI (compatibility version 1.0.0, current version 1394.40.33)
    /System/Library/PrivateFrameworks/MobileObliteration.framework/Versions/A/MobileObliteration (compatibility version 1.0.0, current version 1.0.0)
    /System/Library/PrivateFrameworks/LoginUIKit.framework/Versions/A/LoginUIKit (compatibility version 1.0.0, current version 357.1.0)
    /System/Library/PrivateFrameworks/FindMyDeviceUI.framework/Versions/A/FindMyDeviceUI (compatibility version 1.0.0, current version 1.0.0)
    /System/Library/PrivateFrameworks/apfs_boot_mount.framework/Versions/A/apfs_boot_mount (compatibility version 1.0.0, current version 1.0.0)
    /System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight (compatibility version 64.0.0, current version 600.0.0)
```

An interesting private framework we can explore further, out of these 11
results, is `/System/Library/PrivateFrameworks/DiskManagement.framework`. But
how can we learn more about it if it doesn't come with any documentation?

Approach 2: RuntimeBrowser
--------------------------

[RuntimeBrowser](https://github.com/nst/RuntimeBrowser) is an open-source macOS
application that will list every available public and private framework image
and generate Objective-C declarations out of them.  RuntimeBrowser browser is
not available on [Homebrew](https://brew.sh), so you will need to either build
it from source (using Xcode) or download the (unsigned) pre-built version from
the official GitHub repository.

In the previous section, we identified
`/System/Library/PrivateFrameworks/DiskManagement.framework` as a potentially
interesting private framework to explore. Using RuntimeBrowser, we can locate
the `DiskManagement` image, list the classes it declares, choose a potentially
interesting one, and explore its Objective-C interface.

![Exploring the `DMPartitionDisk` class using RuntimeBrowser](../../../images/runtime-browser-example.png)

In the above example, we are inspecting the `DMPartitionDisk` class, which has
interesting Objective-C methods like `addPartitionFollowingPartition`. If you
have
[SIP](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)
(System Integrity Protection) disabled, you can attach LLDB to *Disk Utility*
and add breakpoints on these methods to explore them further.

You can also import the generated interfaces to an Objective-C project that
links to the relevant private frameworks and attempt to call these classes
yourself. But how can we better understand these methods to know how to we
should use them?

Approach 3: Hopper Disassembler
-------------------------------

[Hopper](https://www.hopperapp.com) is a popular disassembler for reverse
engineering macOS frameworks. It requires a paid license to enable its full set
of features, but the trial is enough for simple cases like the ones in this
article.

In the previous sections, we explored the
`/System/Library/PrivateFrameworks/DiskManagement.framework` private framework
that the *Disk Utility* application links to. If you try to open this framework
using Hopper, you will realize that while such framework directory exists on
the file system, it doesn't contain the actual library. In fact, the symbolic
link at the top-level of the framework bundle is broken:

```sh
$ file /System/Library/PrivateFrameworks/DiskManagement.framework/DiskManagement
/System/Library/PrivateFrameworks/DiskManagement.framework/DiskManagement: broken symbolic link to Versions/Current/DiskManagement
```

Starting from Big Sur, macOS [caches all built-in
libraries](https://mjtsai.com/blog/2020/06/26/reverse-engineering-macos-11-0/)
into a single file for startup performance reasons. Instead of shipping each
shared library into their respective locations, macOS now maintains a shared
cache for each architecture it supports in the
`/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld` directory. On my
system, I have caches for `arm64e` and `x86_64`:

```sh
$ file /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e
/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e: Dyld shared cache version 1 arm64e

$ file /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_x86_64
/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_x86_64: Dyld shared cache version 1 x86_64
```

When an application launches,
[`dyld`](https://opensource.apple.com/source/dyld/) (the open-source Apple
dynamic linker), will load the required frameworks from the cached location
(referred to as the `dyld` shared cache) without incurring additional I/O. This
is great for performance, but not so great for the purposes of reverse
engineering.

The good news is that Hopper is capable of inspecting Mach-O binaries directly
from *within* the `dyld` shared cache. Let's use the Hopper CLI to open the
`arm64e` shared cache:

```sh
$ hopper --executable /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e
```

When the Hopper application launches, it will let you browse the cache for the
frameworks that you are interested in using its built-in *DYLD Shared Cache*
loader.

![Using Hopper to search for `DiskManagement` in the DYLD Shared Cache](../../../images/hopper-dyld-cache-diskmanagement.png)

Once we select `DiskManagement.framework`, we can use Hopper to find the
`addPartitionFollowingPartition` method (using the *Labels* section) we saw
before in RuntimeBrowser, and select the *Pseudo-code mode* to see a
disassembled version of it.

![Using Hopper to disassemble a method of `DiskManagement`](../../../images/hopper-diskmanagement-disassemble.png)

Finally, you can also export an Objective-C header file out of a framework,
similar to how `RuntimeBrowser` does it, by selecting `File -> Export
Objective-C Header File...`.

![Using Hopper to export the Objective-C headers of `DiskManagement`](../../../images/hopper-export-objective-c.png)

If you want to generate Objective-C headers out of a Mach-O binary from the
command-line, a tool worth looking into is
[`class-dump`](https://github.com/nygard/class-dump).

Approach 4: `dyld-shared-cache-extractor`
-----------------------------------------

While Hopper can select frameworks out of the `dyld` shared cache for
individual inspection, often you want to perform searches (or other operations)
across the entire set of private frameworks. However, this is inconvenient to
do on the shared cache monolith file.

Luckily, there is an open-source tool called
[`dyld-shared-cache-extractor`](https://github.com/keith/dyld-shared-cache-extractor),
which as its name implies, can extract the `dyld` shared cache into individual
files. You can install this program using the author's [Homebrew
Tap](https://github.com/keith/homebrew-formulae) or build it from source (its a
single file of C code).

Once you have it, you can run it by passing as arguments the `dyld` shared
cache you want to extract and the output location. For example, I can extract
the `arm64e` shared cache into `$HOME/Projects/dyld-cache-arm64e` as follows:

```sh
$ dyld-shared-cache-extractor \
  /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e \
  $HOME/Projects/dyld-cache-arm64e
```

After a few seconds, your output directory will be populated with every entry
of the shared cache, including `DiskManagement.framework`:

```sh
$ file ~/Projects/dyld-cache-arm64e/System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement
/Users/jviotti/Projects/dyld-cache-arm64e/System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement: Mach-O 64-bit dynamically linked shared library arm64e
```

On my system, the `arm64e` extracted shared cache is 3.5 GB and contains 1535
private frameworks:

```sh
$ du -sh ~/Projects/dyld-cache-arm64e
3.5G    /Users/jviotti/Projects/dyld-cache-arm64e

$ ls -1 ~/Projects/dyld-cache-arm64e/System/Library/PrivateFrameworks | wc -l
    1534
```

Now you can more conveniently open the framework you want to explore in Hopper,
but you can also perform searches across the entire cache using `grep(1)`. For
example, we can find every private framework that mentions the
[FileVault](https://support.apple.com/en-gb/guide/deployment/dep82064ec40/web)
disk encryption service as follows:

```sh
$ grep --recursive FileVault ~/Projects/dyld-cache-arm64e/System/Library/PrivateFrameworks
Binary file System/Library/PrivateFrameworks/ConfigurationEngineModel.framework/Versions/A/ConfigurationEngineModel matches
Binary file System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement matches
Binary file System/Library/PrivateFrameworks/Install.framework/Versions/A/Install matches
Binary file System/Library/PrivateFrameworks/Install.framework/Frameworks/DistributionKit.framework/Versions/A/DistributionKit matches
Binary file System/Library/PrivateFrameworks/ConfigurationProfiles.framework/Versions/A/ConfigurationProfiles matches
Binary file System/Library/PrivateFrameworks/CoreUtilsExtras.framework/Versions/A/CoreUtilsExtras matches
Binary file System/Library/PrivateFrameworks/DistributedEvaluation.framework/Versions/A/DistributedEvaluation matches
Binary file System/Library/PrivateFrameworks/LoginUIKit.framework/Versions/A/LoginUIKit matches
Binary file System/Library/PrivateFrameworks/StoreFoundation.framework/Versions/A/StoreFoundation matches
Binary file System/Library/PrivateFrameworks/SpotlightServices.framework/Versions/A/SpotlightServices matches
Binary file System/Library/PrivateFrameworks/SystemMigration.framework/Versions/A/SystemMigration matches
Binary file System/Library/PrivateFrameworks/CoreServicesInternal.framework/Versions/A/CoreServicesInternal matches
Binary file System/Library/PrivateFrameworks/APFS.framework/Versions/A/APFS matches
Binary file System/Library/PrivateFrameworks/SetupAssistantSupport.framework/Versions/A/SetupAssistantSupport matches
Binary file System/Library/PrivateFrameworks/QuickLookIosmac.framework/Versions/A/QuickLookIosmac matches
Binary file System/Library/PrivateFrameworks/SystemAdministration.framework/Versions/A/SystemAdministration matches
Binary file System/Library/PrivateFrameworks/RemoteManagementModel.framework/Versions/A/RemoteManagementModel matches
Binary file System/Library/PrivateFrameworks/FinderKit.framework/Versions/A/FinderKit matches
Binary file System/Library/PrivateFrameworks/OSUpdate.framework/Versions/A/OSUpdate matches
Binary file System/Library/PrivateFrameworks/QuickLookThumbnailingDaemon.framework/Versions/A/QuickLookThumbnailingDaemon matches
Binary file System/Library/PrivateFrameworks/DeviceManagementTools.framework/Versions/A/DeviceManagementTools matches
```

As you would expect, `DiskManagement.framework` appears within the occurrences
(its the second result).

Approach 5: `dylibtree`
-----------------------

[`dylibtree`](https://github.com/keith/dylibtree) is an open-source third-party
utility (from the same author as `dyld-shared-cache-extractor`) to get a
tree-view of the frameworks used by the application.  Similar to
`dyld-shared-cache-extractor`, you can install this program using the author's
[Homebrew Tap](https://github.com/keith/homebrew-formulae) or build it from
source.

This tool relies on the `dyld` shared cache file we saw on previous sections,
and it is convenient if want to better understand the dependency chain of
applications and their frameworks without having to scan one by one using
`otool(1)`.

For example, you can list the dependencies of `DiskManagement.framework` up to
3 levels deep using the following command:

```sh
$ dylibtree --depth 3 \
  --shared-cache-path /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e \
  ~/Projects/dyld-cache-arm64e/System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement
/Users/jviotti/Projects/dyld-cache-arm64e/System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement:
  /System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement:
    /usr/lib/libcsfde.dylib:
      /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation:
      /System/Library/PrivateFrameworks/ProtectedCloudStorage.framework/Versions/A/ProtectedCloudStorage:
      /usr/lib/libCoreStorage.dylib:
      /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit:
      /System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices:
      /System/Library/Frameworks/SystemConfiguration.framework/Versions/A/SystemConfiguration:
      /System/Library/Frameworks/Security.framework/Versions/A/Security:
      /System/Library/PrivateFrameworks/EFILogin.framework/Versions/A/EFILogin:
      /usr/lib/libc++.1.dylib:
      /usr/lib/libSystem.B.dylib:
      /System/Library/Frameworks/CFNetwork.framework/Versions/A/CFNetwork:
    /usr/lib/libCoreStorage.dylib
    /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit
    /System/Library/Frameworks/Security.framework/Versions/A/Security
    /System/Library/PrivateFrameworks/MediaKit.framework/Versions/A/MediaKit:
      /System/Library/PrivateFrameworks/APFS.framework/Versions/A/APFS:
      /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit
      /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
      /usr/lib/libz.1.dylib:
      /usr/lib/libSystem.B.dylib
    /System/Library/Frameworks/DiskArbitration.framework/Versions/A/DiskArbitration:
      /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
      /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit
      /System/Library/Frameworks/Security.framework/Versions/A/Security
      /usr/lib/libSystem.B.dylib
    /System/Library/Frameworks/DiscRecording.framework/Versions/A/DiscRecording:
      /usr/lib/libz.1.dylib
      /usr/lib/libobjc.A.dylib:
      /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
      /System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices
      /System/Library/Frameworks/DiskArbitration.framework/Versions/A/DiskArbitration
      /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation:
      /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit
      /System/Library/Frameworks/Security.framework/Versions/A/Security
      /System/Library/Frameworks/AudioToolbox.framework/Versions/A/AudioToolbox:
      /usr/lib/libc++.1.dylib
      /usr/lib/libSystem.B.dylib
      /System/Library/Frameworks/CFNetwork.framework/Versions/A/CFNetwork
    /System/Library/PrivateFrameworks/CoreAnalytics.framework/Versions/A/CoreAnalytics:
      /System/Library/PrivateFrameworks/AppleSauce.framework/Versions/A/AppleSauce:
      /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
      /usr/lib/libobjc.A.dylib
      /usr/lib/libc++.1.dylib
      /usr/lib/libSystem.B.dylib
      /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
    /System/Library/PrivateFrameworks/APFS.framework/Versions/A/APFS
    /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
    /usr/lib/libobjc.A.dylib
    /usr/lib/libSystem.B.dylib
    /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
  /usr/lib/libcsfde.dylib
  /usr/lib/libCoreStorage.dylib
  /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit
  /System/Library/Frameworks/Security.framework/Versions/A/Security
  /System/Library/PrivateFrameworks/MediaKit.framework/Versions/A/MediaKit
  /System/Library/Frameworks/DiskArbitration.framework/Versions/A/DiskArbitration
  /System/Library/Frameworks/DiscRecording.framework/Versions/A/DiscRecording
  /System/Library/PrivateFrameworks/CoreAnalytics.framework/Versions/A/CoreAnalytics
  /System/Library/PrivateFrameworks/APFS.framework/Versions/A/APFS
  /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
  /usr/lib/libobjc.A.dylib
  /usr/lib/libSystem.B.dylib
  /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
```

As an engineer working on macOS, you hopefully find these approaches useful!
