---
title: SSH
description: Secure Shell (SSH) is a protocol for creating an encrypted communications channel between two networked hosts
---

SSH quickly spread to replace insecure protocols such as telnet, rsh, and
rlogin.

OpenSSH
-------

- OpenSSH is the most widely deployed implementation of the SSH protocol
- OpenSSH is developed by the OpenBSD Project, a team known for writing secure
  software

### OpenBSD and OpenSSH Portable version

- The OpenBSD version is where the main development happens, but it only
  supports OpenBSD
- The OpenSSH Portability Team takes the OpenBSD version and adds the glue
  necessary to make OpenSSH work on other operating systems, creating Portable
  OpenSSH

PuTTY
-----

The most popular Microsoft Windows SSH client.

SSH protocol versions
---------------------

- **Always** use SSH-2, since SSH-1 is known to ver vulnerable to attacks
- If you own a SSH server, don't support SSH-1 at all
- There are no known security problems with the protocol

How OpenSSH encryption works
----------------------------

- Every SSH server has a key pair
- Whenever a client connects, the server and the client use this key pair to
  negotiate a temporary key pair shared only between those two hosts
- The client and the server both use this temporary key to derive a symmetric
  key that they will use to exchange data during this session, as well as
  related keys to provide connection integrity
- If the session runs for a long time or exchanges a lot of data, the computers
  will intermittently negotiate a new temporary key pair and a new symmetric
  key

Verifying server keys
---------------------

- Each SSH server has a unique public key
- The first time a client connects to a server, the SSH clients prints the
  server fingerprint
- Users are expected to manually check the fingerprint
- The client then caches the server key

### View the fingerprint of a server public key from the server

```sh
ssh-keygen -lf /etc/ssh/ssh_host_*_key.pub
```

- Distribute fingerprints to your users in a secure, encrypted way

Rules of thumb
--------------

- Don't manually prefer certain algorithms over other algorithms. Let the
  OpenSSH developer choose (they know what they're doing)

- Never allow `root` SSH access

- Give accounts the least level of privileges that will let users and programs
  accomplish their required tasks
- Change the TCP/IP port OpenSSH runs on (security through obscurity)

- Don't change the OpenSSH banner, since some clients make use of this
  information to connect correctly

- By only allowing authorized IP addresses on your network to access your SSH
  server, you block the vast majority of attackers. Use firewalls instead of
  server settings when possible

- The most effective way to protect your server is to disable passwords and
  only allow logins via keys

- Never use passphrases over SSH. Use SSH keys instead

OpenSSH configuration
---------------------

- Server: `/etc/ssh/sshd_config` (see all options in `sshd_config` man page)
- Client: `/etc/ssh/ssh_config` or `$HOME/.ssh/config` (see all options in
  `ssh_config` man page)
- The server's private key: `/etc/ssh/ssh_host_*_key`
- The server's public key: `/etc/ssh/ssh_host_*_key.pub`

Basic server configuration
--------------------------

### `Port <number>`

The TCP port the OpenSSH server should run in.

### `AddressFamily <string>`

The TCP/IP version the server should use.

- `inet`: for IPv4
- `inet6`: for IPv6
- `any`: for both IPv4 and IPv6

### `ListenAddress <ip address[:port]>`

Many hosts have multiple IP addresses. By default, `sshd` listens for incoming
requests on all of them. If you want limit the IP addresses that `sshd`
attaches to, use this option.

- This option may be set multiple times

### `Protocol <number[,number...]>`

The SSH protocol to support. This can be `1`, `2`, or `1,2`.

- **Always use `2`**

### `Banner <file>`

The path to the file containing the banner message.

- Keep in mind that whether this is shown or not depends on the client

### `PrintMotd <yes|no>`

Whether to print `/etc/motd` after a client successfully connects.

### `PrintLastLog <yes|no>`

Whether to print information about the last time the user logged in to the
client, after it connects successfully.

- It is recommended to leave this turned on, to alert users about potential
  intrusions

### `LoginGraceTime <string>`

How much time a user has to connect to the server. If the user fails to
connect, then the connection is terminated.

Example:

- `60s`
- `2m`
- `1h`

### `MaxAuthTries <number>`

The maximum amount of times a user can try to authenticate before closing the
connection.

- After half of the user attempts failed, the system logs any further failures

### `UseDNS <yes|no>`

Verify the forward and reverse DNS names for a client's IP address, to reject
potentially malicious connection attempts where the client spoofs the DNS name.

- DNS checks can increase system load (only relevant if you have hundreds of
  SSH users)

For example:

- Client controls the reverse DNS name for his IP address
- Client changes the DNS name to make it appear it comes from your company
- Client connects to your SSH server using the spoofed DNS name

If this option is set:

- Server queries its DNS for the host the client is trying to connect as:W
- If the IP address it has on the DNS doesn't match the real IP address, reject
  the connection

### `PidFile <path>`

The path to store the PID file.

### `ChrootDirectory <string|none>`

- Useful if you want to lock SSH users to a certain file tree (a `chroot`), and
  want to prohibit them from escaping that jail
- The chroot directory must be owned by `root` and not be writable by the
  restricted user

This option can take `%h` (host) and `%u` (username) macros.

Server logging
--------------

OpenSSH makes use of `syslog`.o

### `SyslogFacility <string>`

Any valid `syslog` facility.

### `LogLevel <string>`

This can be:

- `QUIET`
- `FATAL`
- `ERROR`
- `INFO`
- `VERBOSE`

These may violate privacy:

- `DEBUG1`
- `DEBUG2`
- `DEBUG3`

User access control
-------------------

You can use the following options, which take a comma-delimited list of
identifiers, to tweak user access permissions:

- `AllowUsers`
- `AllowGroups`
- `DenyUsers`
- `DenyGroups`

These options may also accept an IP or host name after a `@` sign to further
control where the allowed users should be permitted to log in.

For example:

```
AllowUsers johndoe@192.0.2.0/25
```

### Advices

- Make use of groups whenever possible

### Rules

- If a user is inside `DenyUsers` but his group is inside `AllowGroups`, the
  user will be denied

- If a user is inside `AllowUsers` but his group is inside `DenyGroups`, the
  user will be allowed to connect

- The presence of `AllowUsers` and/or `AllowGroups` means that no one else can
  connect

Match blocks
------------

Sometimes you need to dynamically set OpenSSH server options based on a certain
pattern. You can use match statements for this:

```
Match <criteria> <value>
```

Anything that comes after the match statement applies if the conditions are
true, until the next match statement or, the end-of-file mark.

- Match statements should appear at the bottom of the `sshd_config` file
- You can pass multiple match conditions one after the other one

Available criterias:

- `User`
- `Group`
- `Host`
- `LocalAddress`
- `LocalPort`
- `Address`

For example:

```
match User johndoe,janedoe
<rule 1>
<rule 2>
<rule 3>

match Group mygroup
<rule 1>
<rule 2>
<rule 3>

match Group mygroup Address 192.168.0.*
<rule 1>
<rule 2>
<rule 3>
```

OpenSSH server snippets
-----------------------

### Run `sshd` with a custom configuration file

```sh
/usr/sbin/sshd -f path/to/sshd_config -p <port>
```

- You need to execute `sshd` using an absolute path, since the tools needs to
  be able to easily re-spawn itself when accepting a connection
- Remember to kill the SSH server when you're done with it

### Run `sshd` in debugging mode

This will make `sshd` print a lot of verbose debugging information of
everything is happening on the server.

```sh
/usr/sbin/sshd -d
```

- You can pass `-d` multiple times to increase verbosity
- An OpenSSH server in debugging mode will not fork, so it can only accept one
  client connection at a time
- Ctrl-C causes a SSH server running in debug mode to die instantly

Basic client configuration
--------------------------

### `Port <number>`

The port to use by default.

### `User <string>`

The username to connect as.

### `Host <string...>`

Set a host for which the following settings apply, until a new `Host` keyword
is encountered, or the end-of-file marked is reached.

For example:

```
Host *.example.com
  Port 2222

Host 192.168.0.* foobar.com
  Port 24
```

- Put any defaults at the end of the file

### `AddressFamily <inet|inet6>`

Force a connection over IPv4 (`inet`) or IPv6 (`inet6`).

### `StrictHostKeyChecking <yes|no|ask>`

Whether to require users to manually verify hosts and add them to
`known_hosts`.

Setting it to `no` means that `ssh` will blindly trust *any* server.

- Don't ever set this to `no`

### `HashKnownHosts <yes|no>`

Whether to hash the entries of the `known_hosts` host file, so no-one can read
them in plain-text.

- It is recommended to set this to `yes` for security purposes
- Older entries will remain un-hashed. Execute `ssh-keygen -H` to hash existing
  entries

### `AllowTcpForwarding <yes|no>`

Whether to allow port forwarding or not.

### `GatewayPorts <yes|no|clientspecified>`

This option controls whether a client can bind a forwarded port to any server
address other than the localhost.

If set to "yes" all forwarded ports are bound to the network-facing IP address.

If set to "clientspecified," the software will accept any configuration given
by the SSH client.

### `PermitOpen <host:port...>`

Restrict which TCP ports and addresses can receive forwarding.

For example:

```
PermitOpen localhost:80 localhost:221
```

Keeping SSH connections open
----------------------------

- `(Client|Server)AliveInterval`: How many seconds the connection needs to be
  idle before the hosts sends a keepalive request

- `(Client|Server)AliveCountMax`: How many unsuccessful keepalive requests to
  send before terminating the connection

### Server

```
ClientAliveInterval 90
ClientAliveCountMax 5
```

### Client

```
ServerAliveInterval 90
ServerAliveCountMax 4
```

OpenSSH client snippets
-----------------------

### Run `ssh` in debugging mode

```sh
ssh -v <host>
```

- You can pass `-d` multiple times to increase verbosity

### Pass a custom configuration file

```sh
ssh -F path/to/config <host>
```

### Manually pass a configuration option

```sh
ssh -o <key>=<value> <host>
```

For example:

```sh
ssh -o Port=2222 <host>
```

### Connect with a custom SSH key

```sh
ssh -i path/to/key <host>
```

### Add a key to the ssh agent

```sh
ssh-add path/to/key
```

Copying files using `scp`
-------------------------

- This program reads `ssh_config`

### Copy files from two OpenSSH servers

```sh
scp source-hostname:<file> destination-hostname:<file>
```

### Recursively copy files from two OpenSSH servers

```sh
scp -rf source-hostname:<file> destination-hostname:<file>
```

### Copy files from the local file-system to an OpenSSH server

```sh
scp <file> destination-hostname:<file>
```

- All remote paths are relative to the default login location
- If we omit the destination file path, then it will be copied to the default
  login location

### Copy files from an OpenSSH server to the local file-system

```sh
scp source-hostname:<file> file>
```

Managing files with `sftp`
--------------------------

`sftp` stands for SSH File Transfer Protocol, and its basically a
reimplementation of the FTP protocol using SSH.

- It allows for much more flexibility than `scp`
- This program reads `ssh_config`

### Open an FTP-like prompt

```sh
sftp <host>
```

- Use `help` to print all the available commands
- Use `get <filename>` to get a file to your local file-system
- Use `put <filename>` to put a file from your local file-system
- Use `ls` to list the remote directories
- Use `cd` to change to another directory in the server
- Use `lcd` to change to another directory in the client
- Use `rename <file1> <file2>` to rename files in the server
- Use `exit` to quit the interactive session

### Allow `sftp`-only users

For cases where some users need to copy files, but don't need interactive
sessions.

```
Match Group <group>
  ChrootDirectory %h
  ForceCommand internal-sftp
  AllowTcpForwarding no
```

Generate server keys
--------------------

- While any user can generate keys, only the superuser can copy them to the
  expected location

### On newer systems

```sh
ssh-keygen -A
```

### On older systems

- Server keys have no passphrase (because the SSH service needs to start when
  the system boots, almost always non-interactively), so we set `-N` to an
  empty string
- Remember to retrieve the fingerprints after creating keys

```sh
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_dsa_key -N ''
```

Generate client keys
--------------------

The following command will allow you pick all the options interactively:

```sh
ssh-keygen
```

- Store keys in the default location, since OpenSSH and other related programs
  look for key-pairs there
- Always pick the recommended algorithm at that time
- Generate one SSH key-pair per machine (never re-use them)

Disable server passwords authentication
---------------------------------------

```
ChallengeResponseAuthentication no
PasswordAuthentication no
PubkeyAuthentication yes
```

Agent forwarding
----------------

If you `ssh` to host `foo`, and need to copy a file from `foo` to `bar`, you
will need your private SSH keys in `foo` in order to access `bar`, which is a
security issue.

You can enable agent forwarding to route private keys between hosts.

### Server configuration

```
AllowAgentForwarding yes
```

### Client configuration

```
ForwardAgent yes
```

- Only do this if you trust the server!

X11 forwarding
--------------

### Server configuration

```
X11Forwarding yes
```

### Client configuration

#### Basic X11 forwarding (more secure)

```
ForwardX11 yes
```

#### Trusted X11 forwarding (less secure)

```
ForwardX11Trusted yes
```

- Only if basic X11 forwarding is not enough
- Only enable this per-host:

```
ForwardX11 no

Host foo
  ForwardX11 yes
  ForwardX11Trusted yes
```

It is recommended to use `ssh` CLI options to enable X11 forwarding when you
need it, instead of always enabling it for all connections to certain hosts:

#### Basic X11 forwarding

```sh
ssh -X <host>
```

#### Trusted X11 forwarding

```sh
ssh -Y <host>
```

You can check if X11 forwarding was successfull by checking the value of the
`DISPLAY` environment variable, which will be undefined if X11 forwarding
didn't work.

- Do not run X11 programs if `DISPLAY` looks wrong

#### Directly run an X11 program

The `-f` option tells `ssh` to go to the background after executing the
command.

```
ssh -f <host> <x11-program>
```

Port forwarding
---------------

To create a background process that does the forwarding, do:

```sh
ssh -f -N <forwarding options> <host>
```

- The `-f` option will put the `ssh` process in the background
- The `-N` option will make the client run nothing on the server (not even a
  shell)

### Local port forwarding

Bind a port of a server to a port of your local machine.

```sh
ssh -L localIP:localport:remoteIP:remoteport hostname
```

Or add an entry to `ssh_config`:

```
LocalForward client-IP:client-port server-IP:server-port
```

- This can be useful to make use of any unencrypted protocol over an encrypted
  connection

### Remote port forwarding

Bind a port of your local machine to a port of a server.

```sh
ssh -R remoteIP:remoteport:localIP:localport hostname
```

Or add an entry to `ssh_config`:

```
RemoteForward client-IP:client-port server-IP:server-port
```

- Useful to access a service from behind a firewall

### Dynamic port forwarding

Setups a generic gateway that can carry any TCP/IP traffic between two
machines.

```sh
ssh -D localaddress:localport hostname
```

Or add an entry to `ssh_config`:

```
DynamicForward host:port
```

- This creates a SOCKS proxy on the specified address and port
- You can connect any application to the proxy, which will pipe any TCP/IP
  traffic

The `authorized_keys` file
--------------------------

Contains entries in the following standard form:

- Prefix
- Key
- Hostname

You can pass additional keywords and instructions at the beginning of these
lines for more finer control. Separate multiple keywords by commas.

### `command="<command>"`

Whenever someone logs in using the key, run the specified command.

### `environment="<name>=<value>"`

Whenever someone logs in using the key, set the specified environment variable.

- Needs `PermitUserEnvironment` to be enabled

### `from="<ssh pattern>"`

Only allow logins from a certain SSH pattern. For example:

```
from="192.168.0.1/25" ssh-rsa ... hostname
```

- Remember that reverse DNS on hosts can be forged. If you really want to
  restrict the hosts that can log in, stick with IP addresses

### `no-agent-forwarding`

Disables agent forwarding.

### `no-port-forwarding`

Disables port forwarding.

### `no-X11-forwarding`

Disables X11 forwarding.

Key-pair authentication
-----------------------

OpenSSH servers keep a list of "trusted" public keys in a file called
`$HOME/.ssh/authorized_keys`. This file contains a public key per line.

### Appending entries to `authorized_keys`

Its recommended to:

1. Copy the public key using `scp` or `sftp`
2. Concatenate it to `authorized_keys` using `cat`

  ```sh
  cat id_rsa.pub >> $HOME/.ssh/authorized_keys
  ```

This is to avoid any silly copy-pasting issues.

Host key cache
--------------

The OpenSSH client records approved keys in `$HOME/.ssh/known_hosts`.

The structure of each line is the following:

- Marker (optional) (`@cert-authority`, `@revoked`)
- Hostnames (including IP addresses) (separated by comma)
- Type of key
- The public key
- Comment (optional) (anything you desire)

### `@cert-authority` marker

An entry that starts with this comment indicates that the host key is for a
certification authority.

References
----------

- https://www.michaelwlucas.com/tools/ssh
