---
title: How to code-sign OS X Electron apps in Travis CI
date: March 16, 2016
image: travis-ci-secure-environment-variables.png
description: This article discusses how to code-sign OS X Electron apps using Travis CI
---

This blog post assumes you already generated your `*.p12` certificate. If not,
please refer to any of the plenty awesome tutorials out there.

Accessing the certificate from Travis CI
----------------------------------------

Travis CI doesn’t have a feature to securely upload files that will be
accessible within the build.

As a workaround, we can base64 encode our `*.p12` file and store it as a secure
environment variable from our project's settings section. During the build, we
can decode the environment variable and normaly access our certificate file.

We can perform the encoding by running the following command:

```sh
base64 path/to/certificate.p12
```

If your certificate is password-protected, you might want to store the password
as well.

![Travis CI secure environment variables](../../../images/travis-ci-secure-environment-variables.png)

Later, we can decode by piping the contents of the environment variable to
`base64 --decode`:

```sh
echo $CERTIFICATE_OSX_P12 | base64 --decode > certificate.p12
```

Importing the certificate to the Keychain
-----------------------------------------

Now that we know how access our certificate from a Travis CI build, the next
step is to import it to the Keychain in order to use with `codesign`.

In order to get code-signing to work on Travis CI, we need to explicitly unlock
the Keychain before being to able to make use of the certificates it contains.

Sadly we don't have the Travis CI System Keychain password to perform the
unlocking, so we’ll create a new Keychain, set it as default, and unlock it
ourselves using the handy [security command line tool][security-cli]:

```sh
security create-keychain -p mysecretpassword build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p mysecretpassword build.keychain
```

We can finally import our certificate to our new Keychain with the following
command:

```sh
security import certificate.p12 -k build.keychain -P <certificate password, if any> -T /usr/bin/codesign
```

You can ensure the certificate was added correctly with the following command:

```sh
security find-identity -v
```

Which should output something like:

```sh
1) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX “Developer ID Application: John Doe (XXXXXXXXXX)”
    1 valid identities found
```

Code-signing the application
----------------------------

Now that everything is setup, we can pass our sign identity to
[electron-packager][electron-packager] and
[electron-builder][electron-builder].

Alternatively, you can use the lower level
[electron-osx-sign][electron-osx-sign] package, or even use `codesign`
yourself:

```sh
codesign --deep --force --verbose --sign "<identity>" Application.app
```

Here's an example script you can use in your `.travis.yml` deploy section:

```sh
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  export CERTIFICATE_P12=Certificate.p12;
  echo $CERTIFICATE_OSX_P12 | base64 — decode > $CERTIFICATE_P12;
  export KEYCHAIN=build.keychain;
  security create-keychain -p mysecretpassword $KEYCHAIN;
  security default-keychain -s $KEYCHAIN;
  security unlock-keychain -p mysecretpassword $KEYCHAIN;
  security import $CERTIFICATE_P12 -k $KEYCHAIN -P $CERTIFICATE_PASSWORD -T /usr/bin/codesign;

  make deploy-or-whatever;
fi
```

[security-cli]: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html
[electron-packager]: https://github.com/electron-userland/electron-packager
[electron-builder]: https://github.com/loopline-systems/electron-builder
[electron-osx-sign]: https://github.com/electron-userland/electron-osx-sign
