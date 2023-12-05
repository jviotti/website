---
title: GNU Debugger
description: A set of notes and recipes on `gdb`, mainly related to C
---

Breakpoints
-----------

There are three ways to instruct GDB to pause execution of your program:

- A breakpoint tells GDB to pause execution at a particular location within the
  program.
- A watchpoint tells GDB to pause execution when a particular memory location
  (or an expression involving one or more locations) changes value
- A catchpoint tells GDB to pause execution when a particular event occurs

Configuration Files
-------------------

GDB will always execute the commands in `$HOME/.gdbinit` before starting a
debugging session. GDB will also look at `$(pwd)/.gdbinit`, which is useful for
project specific configuration.

You can point GDB at a specific configuration file by running:

```sh
gdb -command=config-file <binary>
```

Commands
--------

### Information

| Command | Arguments | Notes |
|---------|-----------|-------|
| `print` | `<variable>` | Print the value of a variable in the scope |
| `print` | `<array>@<size>` | Print a dynamically sized array by telling GDB the length in advance |
| `print/x` | `<variable>` | Same as `print`. Force hexadecimal output |
| `print/c` | `<variable>` | Same as `print`. Force character output |
| `print/s` | `<variable>` | Same as `print`. Force string output |
| `print/f` | `<variable>` | Same as `print`. Force float output |
| `info` | `locals` | Print all local variables |
| `info` | `threads` | Print information about all running threads |
| `info` | `breakpoints` | Print information about all breakpoints/watchpoints/catchpoint |
| `info` | `display` | Print information about all configured displays |
| `backtrace` | `-` | Print the backtrace up to the current function |
| `show` | `user` | List all the macros from the current user |
| `help` | `<topic>` | Get information about a certain topic or command |
| `list` | `<place>` | Show contextual code around a certain function, line number, etc |
| `display` | `<variable>` | Automatically display a variable at any breakpoint |
| `undisplay` | `-` | Undisplay all displayed variables |
| `undisplay` | `<id>` | Undisplay a displayed variable given a display ID |
| `enable` | `display <id>` | Enable a disabled display given its ID |
| `disable` | `display <id>` | Disable a display given its ID |
| `frame` | `<id>` | Print the value of a certain stack frame. `0` is the current one. Check `backtrace`. Printing a frame switches context to that frame |
| `thread` | `<id>` | Switch context to a certain thread |
| `tty` | `<path>` | Set the TTY GDB will use to print the debugged program's output |

The output of `info breakpoints` look like this:

```
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000100000f32 in main at main.c:9
        breakpoint already hit 1 time
2       hw watchpoint  keep y                      argc
3       breakpoint     keep y   0x0000000100000f3f in main at main.c:10
        stop only if argc > 2
```

- `Num`: The breakpoint ID
- `Type`: The type of breakpoint
- `Disp`:
  - `keep`: The breakpoint will be unchanged after the next time it's reached
  - `del`: The breakpoint will be deleted after the next time it's reached
    (i.e. when using `tbreak`)
  - `dis`: The breakpoint will be disabled the next time it's reached (i.e.
    when using `enable once`)
- `Enb`: Whether the breakpoint is enabled or disabled
- `Address`: The location in memory where the breakpoint is set
- `What`: The place or expression used for the breakpoint

Notice that this command also tells us how many times each breakpoint was hit.

### Interaction

| Command | Arguments | Notes |
|---------|-----------|-------|
| `set` | `variable <name> = <expression>`| Modify a local variable |
| `set` | `environment <name> = <expression>`| Set an environment variable |
| `set` | `$<name> = <expression>`| Set an convenience variable for use during the session |

### Flow

| Command | Arguments | Notes |
|---------|-----------|-------|
| `run`   | `-`  | Run the program with the last passed arguments (defaults to none) |
| `run`   | `<args...>` | Run the program with the given arguments |
| `continue` | `-` | Continue execution until a breakpoint is hit |
| `continue` | `<number>` | Continue execution ignoring the next N breakpoints |
| `next` | `-` | Execute the next line and pause |
| `next` | `<times>` | Execute `next` N number of times |
| `step` | `-` | Same as `next`, but enter the function given a line with a function call |
| `finish` | `-` | Resume execution until just after the current stack frame finishes. GDB will stop at any intermediary breakpoints |
| `jump` | `<place>` | Unsafely jump to a certain place in the code and continue execution from there |

### Breakpoints

| Command | Arguments | Notes |
|---------|-----------|-------|
| `delete` | `-` | Delete all breakpoints |
| `delete` | `<id>` | Delete a breakpoint by its ID |
| `disable` | `-` | Disable all breakpoints |
| `disable` | `<id>` | Disable a breakpoint given its ID |
| `enable` | `<id>` | Enable a breakpoint given its ID |
| `enable` | `once <id>` | Enable a breakpoint given its ID *once*, and then disable it again |
| `clear` | `-` | Clear all breakpoints from the current line |
| `clear` | `<place>` | Clear all breakpoints from a certain line, function, etc |
| `break` | `<line>` | Add a breakpoint in a certain line of the current file |
| `break` | `<function>` | Add a breakpoint in a certain function of the current file |
| `break` | `<line>:<function>` | Add a breakpoint in a line of a certain file |
| `break` | `<file>:<function>` | Add a breakpoint in a function of a certain file |
| `break` | `+<offset>` | Add a breakpoint X lines after the current line |
| `break` | `-<offset>` | Add a breakpoint X lines before the current line |
| `break` | `<place> thread <thread>` | Add a breakpoint on a certain thread |
| `break` | `<place> if <expression>` | Create a conditional breakpoint. The expression may call local functions and GDB macros |
| `break` | `<place> thread <thread> if <expression>` | Create a conditional thread breakpoint |
| `watch` | `<variable>` | Stop when a certain variable changes. The watchpoint will be deleted if the variable goes out of scope |
| `watch` | `<expression>` | Stop when a certain expression is true, ie `x < 5`. The watchpoint will be deleted if the referenced variables go out of scope |
| `tbreak` | `<location>` | Set a temporary breakpoint that is deleted after hit once. Syntax is the same as `break` |
| `condition` | `<id> <expression>` | Turn a breakpoint, by its ID, into a conditional expression. Same as `break <place> if <expression>` |
| `condition` | `<id>` | Make a conditional breakpoint inconditional |

Commands
--------

Execute a set of commands everytime a certain breakpoint is hit. The syntax is:

```gdb
command <breakpoint id>
<command 1>
<command 2>
...
<command N>
end
```

- The first command can be `silent` to make GDB quieter so we can better see
  the output of the commands we put here
- The last command (before `end`) can be `continue`, in which case GDB will
  automatically go to the next breakpoint
- The command `call <function>` can be used to execute a C function

Shortcuts
---------

- `ENTER`: Re-execute the last command
- `Ctrl-C`: Stop execution for inspection purposes

Caveats
-------

- GDB highlights the line that's about to be executed, but that its not
  executed yet
- If there are multiple breakpoints on a single line, then GDB will only stop
  once

References
----------

- [The Art of Debugging with GDB, DDD, and Eclipse](https://www.amazon.com/Art-Debugging-GDB-DDD-Eclipse/dp/1593271743)
