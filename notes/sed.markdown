---
title: Sed
description: Sed is a Unix utility that parses and transforms text, using a simple, compact programming language
---

Glossary
--------

- **Pattern Space**: A temporary buffer where all lines are stored, one at a
  time, in order for Sed to process them before piping them to `stdout`

- **Hold Space**: A set-aside buffer for temporary storage

Usage
-----

- Execute a single rule on a file

```sh
sed <rule> <file>
```

- Execute multiple rules on a file

```sh
sed -e <rule1> -e <rule2> -e <rule3> <file>
```

- Execute a script on a file

```sh
sed -f <script> <file>
```

- Execute a script on multiple files

```sh
sed -f <script> <file1> <file2> <file3>
```

- Don't print anything by default (tip: use the `p` command)

```sh
sed -n -f <script> <file>
```

Comments
--------

Lines starting with `#`.

- Some versions of Sed only allow comments as the first lines of the program.

Grouping
--------

You may nest commands by surrounding them in curly braces. For example, this
command deletes lines containing `bar` and replaces every occurrence of `baz`
with `qux` only on lines in betwee lines that start with `START` and `END`:

```sed
/^START/,/^END/ {
  /bar/ d
  s/baz/qux/g
}
```

- Multiple levels of grouping are permitted.

Commands
--------

### `substitute (s)`

> `[address] s/pattern/replacement/flags`

### `replacement`

Characters with special meaning:

- `&`: Replaced by the string matched by the regular expression

- `\n`: Matches the nth substring (`n` is a single digit) previously specified
  in the `pattern` using `\(` and `\)`

### `flags`

- `n`: A number (1 to 512) indicating that a replacement should be made for
  only the nth occurrence of the `pattern`

> This is commonly used in instances where the regular expression repeats
  itself on a line.

- `g`: Make changes globally on all occurrences in the pattern space

- `p`: Print the contents of the pattern space

> This is commonly used when the default output is suppressed (`-n`)

- `w <file>`: Write the contents of the pattern space to `file`

### Extras

- You can set the delimiter to be any character, for example:

```sed
s!/foo/bar!/bar/baz!g
```

### `delete (d)`

> `[address] d`

### `insert (i)`

```sed
[address] i\
<line1>\
<line2>\
...\
<lineN>
```

Insert the supplied text *before* the current line in the pattern space.

### `append (a)`

```sed
[address] a\
<line1>\
<line2>\
...\
<lineN>
```

Insert the supplied text *after* the current line in the pattern space.

### `change (c)`

```sed
[address] c\
<line1>\
<line2>\
...\
<lineN>
```

Replace the line range specified by the pattern space.

- It can be used when you want to match a line and replace it entirely

- The `change` command clears the pattern space, having the same effect on the
  pattern space as the `delete` command. No command following the change
  command in the script is applied

### `list (l)`

Displays the contents of the pattern space, showing non-printing characters as
two-digit ASCII codes.

- It can be used to detect "invisible" characters in the input

- It should be used with `-n`, since the `list` command produces immediate
  output, causing duplicates of every line otherwise

Example:

```sh
cat file | sed -n "l"
```

### `transform (y)`

> `[address] y/abc/xyz/`

Transform each character by string position. In the above example, `a` is
transformed to `x`, `b` to `y`, and `c` to `z`.

- It acts on the entire contents of the pattern space

### `print (p)`

> `[address] p`

Causes the contents of the pattern space to be printed.

- Its usually used with `-n` to avoid duplicates

### `print line number (=)`

> `[address] =`

Prints the line number of the matched line.

- This command cannot operate on a range of lines

### `next (n)`

> `[address] n`

Outputs the contents of the pattern space and then reads the next line of input
without returning to the top of the script.

For example, delete a blank line after a `troff` header (`.H1 <text>`):

```sed
/^\.H1/ {
  n
  /^$/ d
}
```

### `read (r)`

> `[address] r <file>`

Read the contents of `file` into the pattern space *after* the address line.

- It cannot operate on a range of lines
- It will not complain if the file doesn't exist

### `write (w)`

> `[address] w <file>`

Write the contents of the pattern space into `file`.

- It will create the file if it doesn't exist
- If there are multiple instructions writing to the same file in one script,
  then each write command appends to the file
- You can only open up to 10 files per script

### `quit (q)`

> `[address] q`

Stop reading new input lines.

### `append next line (N)`

> `[address] N`

Add the next line to the current pattern space. The pattern space will be
separated by `\n` characters.

- It is recommended to always use it as `$!N` in order to always exclude the
  final line, otherwise there will be nothing to consume, so Sed will quit and
  the last line will not be printed

### `multiline delete (D)`

> `[address] D`

Delete a portion of the pattern space, up to the first embedded `\n`, and it
returns to the top of the script.

### `multiline print (P)`

> `[address] P`

Prints a portion of the pattern space, up to the first embedded `\n`. The
remaining parts of the pattern space are automatically printed after the last
command.

### `hold (h)`

> `[address] h`

Copy the contents of the pattern space to the hold space.

- Its usually paired with delete commands

### `hold (H)`

> `[address] H`

Append the contents of the pattern space to the hold space.

- Its usually paired with delete commands

### `get (g)`

> `[address] g`

Copy the contents of the hold space to the pattern space.

### `get (G)`

> `[address] G`

Append the contents of the hold space to the pattern space.

### `exchange (x)`

> `[address] x`

Exchange the contents of the hold space and the pattern space.

### `branch (b)`

> `[address] b [label]`

For example:

```sed
:loop
command1
command2
[address] b loop
```

- The `label` maximum length is 7 characters
- Branching to no `label` goes to the end of the script

### `test (t)`

> `[address] t [label]`

Branch to `label` if a successful substitution has been made on the currently
addressed line.

- Passing no `label` goes to the end of the script
- Useful to write `case`-like constructs:

```sed
[address] {
  s/<pattern1>/<substitution1>
  t label1
  s/<pattern2>/<substitution2>
  t label2
}

:label1
...

:label2
...
```

Cookbook
--------

### `substitute (s)`

- Replace a occurrence of `pattern` with `replacement` on every line

```sed
s/pattern/replacement/
```

- Replace a occurrence of `pattern` with a blank line

```sed
s/pattern/\
/
```

- Replace all occurrences of `pattern` with `replacement` on every line

```sed
s/pattern/replacement/g
```

- Replace all occurrences of `pattern` with `replacement` on every line that
  matches `address`

```sed
/address/ s/pattern/replacement/g
```

- Replace all occurrences of `pattern` with `replacement` on every line that
  matches `address1`, up to a line that matches `address2`

```sed
/address1/,/address2/ s/pattern/replacement/g
```

- Replace all occurrences of `pattern` with `replacement` on line number `N`

```sed
N s/pattern/replacement/g
```

- Replace all occurrences of `pattern` with `replacement` from line number `N`
  to line number `M`

```sed
1,10 s/pattern/replacement/g
```

- Don't replace `pattern` with `replacement` on every line that matches `address`

```sed
/address/ !s/pattern/replacement/g
```

- Surround `pattern` in parenthesis

```sed
s/pattern/(&)/
```

### `delete (d)`

- Delete the line number N

```sed
N d
```

- Delete the last line

```sed
$ d
```

- Delete from line number `N` to the end of the file

```sed
N, d
```

- Delete every line *except* the ones that match `address`

```sed
/address/ !d
```

### 'append next line (N)'

- Reduce multiple blank lines to one

```sed
/^$/ {
  N
  /^\n$ D
}
```

Tips & Tricks
-------------

- By default, each line of input is sent to `stdout` after all the commands
  have been applied to it. You can suppress this behaviour by usind the `-n`
  command line option, or by starting the program with `#n`.

Caveats
-------

- Sed executes every single rule on a script on every line, one at a time,
  rather than executing each rule, one at a time, on the whole file

- If no address is specified, then the command is applied to every line

- Don't forget to escape ampersands (`&`) in the `replacement` sections (`\&`)

- When using the `delete` command, remember that it deletes the whole line, and
  not the substring that was matched. To delete a portion of a string, use the
  `substitute` command and replace `pattern` with nothing

- The `append` and `insert` commands can be applied only to a single line
  address, not a range of lines

- You cannot match a character by ASCII value (nor can you match octal values)
  in Sed. Instead, you have to find a key combination in `vi` to produce it
