---
title: Awk
description: AWK is special-purpose programming language to handle text-reformatting jobs
---

Glossary
--------

- **Main Input Loop**: A routine that reads the input, one line at a time, and
  makes it available for processing. Every rule that applies is executed, in
  order, on the current line.

- **Record**: Each line of input
- **Field**: Each word in a record, separated by spaces or tabs
- **Delimiter**: The character(s) separating the fields

Usage
-----

- Execute a script independently

```
#!/usr/bin/env awk -f
```

- Execute an inline script on a file

```sh
awk <script> <file>
```

- Execute a script on a file

```sh
awk -f <script> <file>
```

- Execute a script on a file passing parameters

```sh
awk -f <script> -v key1=value1 -v key2=value2 <file>
```

- Execute script interactively from `stdin`

```sh
awk -f <script>
```

- Execute a script with a custom delimiter

```sh
awk -F <delimiter> -f <script> <file>
```

- Execute a script importing custom functions

```sh
awk -f <script> -f <path/to/library.awk> file
```

> Press `CTRL-D` to signal `EOF`

Rules
-----

### `BEGIN { commands }`

- Execute commands before any input is read.

### `END { commands }`

- Execute commands after all input was read.

Pipes
-----

### `|`

> Redirect output

- Redirect to command

```awk
print "Foo" | "wc -c"
```

- Don't forget to `close` the pipe after done with it

### `>`

> Output to a file

```awk
print "Foo" > "path/to/file"
```

### `>>`

> Append to file

```awk
print "Foo" >> "path/to/file"
```

Functions
---------

You can declare functions in the following form:

```awk
function name([argument1][, argument2][, ...]) {
  command1
  command2
  return [value]
}
```

- Arrays are passed by reference, and the remaining types are passed by value
- The variables defined in the body of the function are global

As an alternative, declare them at the end of the argument list, and don't pass
them at all when invoking the function, which will cause Awk to set them to an
empty string:

```awk
function foo(arg1, arg2, temporary_arg1, temporary_arg2) {
  temporary_arg1 = 5
  temporary_arg2 = 7
}

foo("hello", "world")
```

Variables
---------

### `FS`

> The file separator, it defauls to `" "`

- Assign a custom file separator (analogous to the `-F` option):

```awk
BEGIN {
  FS = ","
}
```

- If `FS` is more than one character, its interpreted as a regular expression:

```awk
BEGIN {
  FS = "[,:]+"
}
```

- Assigning a value of `FS` at runtime only takes effect on the next record

### `OFS`

> The output file separator

- The "output" of a record can be referred by `$0`

- You can access `OFS` from `print` by using a comma

```awk
BEGIN {
  OFS = "\t"
}

# Each comma will be replaced with `\t`

{
  print $1, $2, $3
}
```

### `NF`

> The number of field for the current record

- This variable is automatically set by Awk
- You can use `$NF` to refer to the last field

- Process records with a specific amount of fields:

```awk
NF == <number of fields> {
  commands
}
```

### `RS`

> The record separator, it defaults to `\n`

- Awk only reads the first character of this variable, so multi-character
  values take no effect

### `ORS`

> The output record separator, it defaults to '\n'

### `NR`

> The number of the current record (the current line number)

- This variable is automatically set by Awk

- Execute commands for a certain line number:

```awk
NR == <line number> {
  commands
}
```

### `CONVFMT`

> Control number-to-string conversions, the default value is `%.6g`

- Setting it to `%d` causes every number to be converted to strings using
  integers

### `OFMT`

> Control number-to-string conversions when using `print`

- Work with dollar values:

```awk
BEGIN {
  OFMT = "%.2f"
}
```

### `ARGC`

> Number of arguments passed

### `ARGV`

> List of arguments passed (array)

- If you're processing arguments manually (instead of using `var=value`
  variables), you have to `delete` the variables after processing them,
  otherwise they might be interpreted as file names

- If you specify a file name at the end of `ARGV`, it will be opened as if it
  was passed from the command line

### `ENVIRON`

> Object of environment variables

```awk
print ENVIRON["PATH"]
```

Statements
----------

### `print [string]`

> Print a string to `stdout`

- Passing no arguments to `print` causes the current line to be printed
- You can pass multiple arguments:

```awk
{ print The first field is $1, and the second is $2 }
```

- Print an empty string:

```awk
{ print "" }
```

- You can use a comma to invoke the `OFS`

- Print to `stderr`

```awk
print "This is an error" > "/dev/stderr"
```

### `printf [expression][, arguments...]`

> Print a formatted string to `stdout`

- This function resembles C's `printf`, so remember to add a `\n` at the end

- Right-justify with a field width of 20 characters:

```awk
{ printf "%20s\n", $1 }
```

- Left-justify with a field width of 20 characters:

```awk
{ printf "%-20s\n", $1 }
```

- You can specify a dynamic width by using an asterisk:

```awk
BEGIN {
  width = 15
}

{
  printf "%*s\n", width, $1
}
```

### `next`

> Get the next record and start over, ignoring any potential rules that would
> have match the current record

### `exit [code]`

> Exit from the script

- `code` defaults to 0

### `Number split(string, array, separator)`

> Create an array by splitting `string` by `separator`. The elements are
> populated into `array`, and the function returns the number of elements

### `delete array[subscript]`

> Delete an element from an array

### `[element] in [array]`

> Test if `element` is inside `array`

```awk
if (foo in ARGV) {
  print "foo is in ARGV"
}
```

- Also useful to iterate through arrays:

```awk
for (index in array) {
  print array[i]
}
```

### `getline`

> Read next input line and save it to `$0`

It might return the following values:

- `1`: If it was able to read a line
- `0`: If it encounters `EOF`
- `-1`: If it encounters an error

***

- You can access its field with `$1`, `$2`, etc
- Do not write `getline()`. Its implementation doesn't accept parenthesis
- Collect values until `EOF`:

```awk
BEGIN {
  while (getline > 0) {
    list = list $0
  }
}
```

- Read from file:

```awk
getline < "path/to/file"
```

- Read from `stdin`:

```awk
getline < "-"
```

- Read the next line of input into a variable:

```awk
BEGIN {
  printf "Enter your name: "
  getline variable < "-"
  print variable
}
```

Notice that when you read into variable, the variable is not split into fields
as when its assigned to `$0`.

- Execute a command using `getline`

```awk
"command" | getline
```

For example:

```awk
"whoami" | getline
```

You may save the output into a variable.

Notice that `getline` only reads the first line of output. Accumulate all using
`while`:

```awk
while ("command" | getline) {
  output = output $0
}
```

### `close([file|pipe])`

> Close a file or pipe

For example:

```awk
BEGIN {
  "whoami" | getline user
  close("whoami")
  print user
}
```

### `system([command])`

> Execute a command, but don't make its output available to Awk

- It returns the exit code from the command

Operators
---------

### `$<N>`

- Refer to the field number `N` of the current record

```awk
{ print $2 }
```

- We can use any number expression by passing it in parenthesis

```awk
BEGIN {
  one = 1
  two = 2
}

{ print $(one + two) }
```

- `$0` refers to the current record

### `<field> ~ <pattern>`

- Only execute the block if `pattern` happens in `field`

```awk
$5 ~ /foo/ {
  print The string "foo" is inside the fifth field
}
```

### `<field> !~ <pattern>`

- Only execute the block if `pattern` doesn't happen in `field`

```awk
$5 !~ /foo/ {
  print The string "foo" is NOT inside the fifth field
}
```

### `[:space:]`

- The space is the string concatenation operator:

```awk
BEGIN {
  foo = "Hello" " - " "World"
}
```

Examples
--------

- Count all blank lines

```awk
BEGIN {
  x = 0
}

/^$/ {
  x += 1
}

END {
  print x
}
```

Tips & Tricks
-------------

- Add comments (lines starting with `#`) to document intention

Caveats
-------

- Every variable in Awk has both a string and numeric value. Strings that don't
  consist of numbers have the numeric value 0

- An uninitialized variale has a default value of 0

- Every integer is converted to string as an integer, no matter the values of
  `CONVFMT` and `OFMT`
