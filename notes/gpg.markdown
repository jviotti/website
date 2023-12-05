---
title: GPG
description: A tool for secure communication
---

The OpenPGP standard is available at https://tools.ietf.org/html/rfc4880.

Subordinate pairs
-----------------

GnuPG also supports a more sophisticated scheme, where a user has a primary key
pair, and zero or more additional subordinate pairs.

- The primary and subordinate key pairs are bundled together for convenience,
  and can often be considered simply as one key pair

Key length
----------

- GnuPG requires keys to be no smaller than 768 bits
- The recommended size is 1024 bits at the very least
- The longer the key, the more secure it is against brute force attacks
- The longer the key, the slower encryption and decryption
- Once selected, the key size can never be changed
- A long key may affect signature length

User IDs
--------

- The user ID is used to associate the key being created with a real person
- It is possible to create additional user IDs for a single key pair
- A user ID can't be changed after set

Expiration
----------

- A key pair that doesn't expire is adequate for most users
- It is possible to change the expiration date, but it might be difficult to
  communicate to users that already have your public key

Revocation certificates
-----------------------

- You should create one as soon as a key pair is created
- Useful if your key is compromised, or lost
- Used to notify others that the public key should no longer be used

Trust model
-----------

- Does not require you to personally validate each key you import
- Key signing allows you to detect tampering on your keyring
- Key signing allows you to certify that a key truly belongs to the person
  named by a user ID (to prevent man-in-the-middle attacks, for example)
- When a subkey or user ID is generated, it is self-signed using the master
  signing key to avoid tampering

### Web of trust

- The responsibility of validating public keys is delegated to people you trust
- You automatically trust anyone that the people you trust has trusted, unless
  you reduce the trust level of a certain person
- A key is considered valid if it was signed by enough valid keys
- A key is considered valid if the path of signed keys from the key to you is
  five steps or shorter (can be customised)

### Trust levels

- `unknown`: Nothing is known about the key
- `none`: The owner is known to improperly sign other keys
- `marginal`: The owner properly validates keys before signing them
- `full`: The owner's signature on a key would be as good as your own

Key servers
-----------

- Public key servers are used to collect and distribute public keys
- Users sign (e.g. trust) keys and re-upload to the key server
- People interested in certain keys can re-fetch them at will
- The major key servers synchronize themselves

### Send a key to a key server

```sh
gpg --keyserver server.pgp.com --send-key <key specifier>
```

- You should do this every time a new GPG version is released, so you tell
  other people that you support new crypto algorithms

### Retrieve a key from a key server

```sh
gpg --keyserver server.pgp.com --recv-key <key ID>
```

Fingerprints
------------

- A key is validated by verifying the key's fingerprint, and then signing the
  key (with your own key) to certify it as a valid key
- If the fingerprint you get for a public key is the same as the fingerprint of
  the key's owner, then you're sure you have a correct copy of the key
- If the fingerprint matches, you can go a head and sign the key

Default keypair
---------------

You can set a default key pair by setting the `GPGKEY` environment variable:

```sh
export GPGKEY=<key id>
```

Signatures
----------

- A digital signature certifies and timestamps a document
- If the document is modified in any way, the verification of the signature
  will fail
- A document is signed using a private key
- The signature of a document is verified using the public key of the person
  who signed it
- A digital signature is the result of applying a hash function to the document
- The hash value *is* the signature
- The hash function needs to satisfy two important properties
  - It should be hard to find two documents that hash to the same value
  - Given a hash value, it should be hard to recover the document that produced
    the value
- Checking a signature means hashing the value of the document and comparing
  the result with the hash of the signature

Ciphers
-------

- A good cipher puts all the security in the key and none in the algorithm
- It should be no help if the attacker knows what cipher was used

### Symmetric

- A symmetric cipher uses the same key for both encryption and decryption
- It must be very difficult to guess the key, since today computers can guess
  keys very quickly
- The primary problem is communicating the key. How secure was the channel
  where the key was communicated?

### Public-key

- These ciphers were invented to avoid the key-exchange problem
- All the security rests in the key
- Key tampering is the major security weakness of these types of ciphers

### Hybrid

- Symmetric ciphers are stronger from a security standpoint
- A public-key cipher is used to share the key for the symmetric cipher
- Both PGP and GnuPG are hybrid ciphers. The session key, encrypted using the
  public-key cipher, and the message being sent, encrypted with the symmetric
  cipher, are automatically combined in one package
- The security of a hybrid cipher is as strong as the weakest link (either the
  public-key or the symmetric cipher, usually the public-key cipher)

Snippets
--------

### Generate a key

```sh
gpg --gen-key
```

### Generating a revocation certificate

```sh
gpg --output revoke.asc --gen-revoke <key specifier>
```

- The specifier may be the key ID or any part of the user ID

### List the keys in the public keyring

```sh
gpg --list-keys
```

### List the keys in the public keyring along with their fingerprints

```sh
gpg --fingerprint --list-signatures
```

### Check the signature of a public key

```sh
gpg --edit-key <key specifier>
Command> check
```

### Export a public key (binary format)

```sh
gpg --output mypublickey.gpg --export <key specifier>
```

### Export a public key (ASCII format)

```sh
gpg --armor --output mypublickey.gpg --export <key specifier>
```

- Useful when sending the key via e-mail, for example

### Importing a public key

```sh
gpg --import publickey.gpg
```

- It will now appear on the public keyring

### Export a private key (binary format)

```sh
gpg --output identity.key --export-secret-key <key specifier>
```

### Export a private key (ASCII format)

```sh
gpg --output identity.key.asc --armor --export-secret-key <key specifier>
```

### Signing a public key

```sh
gpg --edit-key <key specifier>
Command> sign
```

- You can view the fingerprint by typing the `fpr` command

### Encrypting a file

```sh
gpg --output file.txt.gpg --encrypt --recipient <key specifier> file.txt
```

- You have to encrypt the file using the public key of the person that needs to
  decrypt it. If you send a file to someone, encrypt the file using that
  person's public key
- The recipient can only decrypt the file if it has the corresponding private
  key
- You can pass multiple `--recipient` options
- Your own public key is always automatically added as a recipient

We can then check the recipients that are allowed to decrypt the data by
running:

```sh
gpg --list-packets file.txt.gpg
```

This will return a list of public keys, like:

```
:pubkey enc packet: version 3, algo 1, keyid BC5EB4A7A76C6BD3
        data: [4096 bits]
```

And we can verify that the keyid is the right one by inspecting a key using
`--edit-key`:

```
ssb  rsa4096/BC5EB4A7A76C6BD3
     created: 2016-11-24  expires: never       usage: E
[ultimate] (1). Juan Cruz Viotti <jv@jviotti.com>
```

### Encrypting a file using symmetric encryption

Symmetric encryption means that you can pick a passphrase at the moment of
encrypting the file, and anyone with the passphrase can decrypt it, without
needing any private key.

```sh
gpg --output file.txt.gpg --symmetric file.txt
```

### Decrypting a file

```sh
gpg --output file.txt --decrypt file.txt.gpg
```

- You need to own the corresponding private key of one of the specified
  recipient's public key in order to decrypt it

### Signing a file (output binary)

```sh
gpg --output file.txt.sig --sign file.txt
```

- You can retrieve the file back by decrypting it

### Signing a file (output ASCII)

```sh
gpg --output file.txt.sig --clearsign file.txt
```

- Useful to sign email messages

### Signing a file (using a detached signature)

```sh
gpg --output file.txt.sig --detach-sig file.txt
```

- Useful so that recipients don't have to decrypt the signed document, or edit
  the clear-signed file to omit the GPG wrapper

### Verify a signature

```sh
gpg --verify file.txt.sig
```

### Verify a detached signature

```sh
gpg --verify file.txt.sig file.txt
```

### View information of a key-pair

```sh
gpg --edit-key <key specifier>
```

- The first column indicates the type of the key
  - `pub`: public key
  - `sub`: subordinate key
- The second column indicates the key's bit length, type, and ID

```
pub  rsa4096/AAAAAAAAAAAAAAAA
     created: 2016-03-14  expires: 2020-01-07  usage: SCEA
     trust: unknown       validity: unknown
sub  rsa4096/BBBBBBBBBBBBBBBB
     created: 2016-03-14  expires: 2020-01-07  usage: SEA
```

In this case, the keys are RSA keys of 4096 bits. The ID of the public key is
`AAAAAAAAAAAAAAAA`, and the id of the subordinate key is `BBBBBBBBBBBBBBBB`.

Other types:

- `D`: a DSA key
- `g`: an encryption only ElGamal key
- `G`: an encryption and signing ElGamal key

### Add a user ID to an existing key

```sh
gpg --edit-key <key specifier>
Command> adduid
Command> save
```

### Revoking a subkey

```sh
gpg --edit-key <key specifier>
Command> key <n> # Select the key
Command> revkey
```

- Don't forget to re-upload to the keyserver to tell the world about it

### Revoking a user ID

A user ID is revoked by revoking its own self-signature.

```sh
gpg --edit-key <key specifier>
Command> uid <n> # Select the user ID
Command> revsig
```

### Update expiration time

```sh
gpg --edit-key <key specifier>
Command> key <n> # Optional
Command> expire
```

### Adjust your trust in a key's owner

This command will interactively ask you to pick a trust level.

```sh
gpg --edit-key <key specifier>
Command> trust
```

### Export ownertrust

The owner trust is a list of public key ids and how much you trust each
of them.

```sh
gpg --export-ownertrust > ownertrust-file
```

### Import ownertrust

```sh
gpg --import-ownertrust ownertrust-file
```

Keycards
--------

- Yubikey: https://suva.sh/posts/gpg-ssh-smartcard-yubikey-keybase/

References
----------

- https://en.wikipedia.org/wiki/GNU_Privacy_Guard
- https://www.gnupg.org/gph/en/manual.html
- https://erroneousthoughts.org/2013/02/12/gnupg-subkeys-for-the-not-so-dummies/
- https://alexcabal.com/creating-the-perfect-gpg-keypair/
- http://codesorcery.net/old/mutt/mutt-gnupg-howto
