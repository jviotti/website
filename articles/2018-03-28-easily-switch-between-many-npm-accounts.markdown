---
title: Easily switch between many NPM accounts
date: March 28, 2018
image: generic.jpg
description: This article describes a trick for easily switching between multiple NPM accounts on the terminal
---

I maintain Node.js packages using my personal and my company's NPM accounts. I
used to rely on my password manager to switch between them using `npm login`,
but it turns out there is a much better way.

Auth tokens
-----------

When you log in, the `npm` command-line tool adds a non-expiry authentication
token to `$HOME/.npmrc` as a line that looks like this:

```
//registry.npmjs.org/:_authToken=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

The auth token is an [UUID][rfc-uuid].

The trick is that `.npmrc` can read the authentication token through an
environment variable. For example:

```
//registry.npmjs.org/:_authToken=${NPM_AUTH_TOKEN}
```

Before we continue, log in to all your accounts and keep a note of the tokens
that npm adds to `.npmrc` (I couldn't find a better way to do this).

Managing profiles
-----------------

We will create a set of environment variables that look like:
`NPM_AUTH_TOKEN_{{profile}}`, where `profile` stands for any descriptive name
you can come up with. I have `NPM_AUTH_TOKEN_PERSONAL` and
`NPM_AUTH_TOKEN_RESIN`, since I work at [resin.io][resin].

The idea is to set `NPM_AUTH_TOKEN`, the variable that `.npmrc` reads the token
from, to the right value depending on what profile we choose. However,
environment variables are defined on a per-process basis, so how are we going
to "update" the variable npm will read?

Shell scripts FTW
-----------------

This is the shell script I use, which I call `npm_run`:

```zsh
#!/bin/zsh

set -u
set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <profile> <command...>" 1>&2
  exit 1
fi

# Transform to uppercase
# See http://stackoverflow.com/a/11392235/1641422
ARGV_PROFILE=$(echo "$1" | tr '[:lower:]' '[:upper:]')

TOKEN_ENVIRONMENT_VARIABLE="NPM_AUTH_TOKEN_$ARGV_PROFILE"

# We need to check the variable exists before attempting
# to blindly expand it afterward to avoid shell errors
if ! set | grep --text "^$TOKEN_ENVIRONMENT_VARIABLE" >/dev/null; then
  echo "Unknown profile: $ARGV_PROFILE"
  exit 1
fi

echo "Loading profile $ARGV_PROFILE..."

# Dynamically expand variable
# See http://unix.stackexchange.com/a/251896/43448
export NPM_AUTH_TOKEN=$(print -rl -- ${(P)TOKEN_ENVIRONMENT_VARIABLE})

echo "Logged in as $(npm whoami)"
npm ${@:2}
```

This script takes a profile and a set of npm command arguments and will call
`npm` with the right authentication token.

It will all work as long as you run the script instead of calling `npm`
directly, and your shell can access the `NPM_AUTH_TOKEN_{{profile}}`
environment variables (if they live in `.zshrc` for instance)

With this script, I can easily publish a package using my personal account by
running `npm_run PERSONAL publish` instead of `npm publish`. If I need to
install dependencies from private npm packages owned by my company, I can run
`npm_run RESIN install` instead of `npm install`, and so forth.

[rfc-uuid]: https://tools.ietf.org/html/rfc4122
[resin]: https://resin.io
