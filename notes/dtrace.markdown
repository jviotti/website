---
title: DTrace
description: A cheat-sheet on DTrace
---

In macOS, run `csrutil enable --without dtrace` in recovery mode (`Cmd+R`
during boot).

Command Line
------------

- List all available probes in the system:

```sh
dtrace -l
```

- Execute in quiet mode:

```sh
dtrace -q
```

You can also add the following pragma:

```
#pragma D option quiet
```

- Enable the C pre-processor:

```sh
dtrace -C
```

- Inspect the arguments of a specific probe:

```sh
dtrace -lvn <probe>
```

One-Liners
----------

- All read files in the system:

```
dtrace -n 'syscall::read:entry /execname != "dtrace"/ { @reads[execname, fds[arg0].fi_pathname] = count(); }'
```

- A distribution graph of the most often I/O requested sizes:

```
dtrace -n 'io:::start { @bytes = quantize(args[0]->b_bcount); }'
```

- The system calls (and the amount) used by each process:

```
dtrace -n 'syscall:::entry { @sc[execname, probefunc] = count(); }'
```

- What processes are opening what files:

```
dtrace -n 'syscall::open:entry { printf("%s %s", execname, copyinstr(arg0)); }'
```

- Kernel functions running on-CPU:

```
dtrace -n 'profile-997hz /arg0/ { @[func(arg0)] = count(); }
```

- User functions running on-CPU:

```
dtrace -n 'profile-997hz /arg1/ { @[execname, ufunc(arg1)] = count(); }'
```

- Processes running the most system calls:

```
dtrace -n 'syscall:::entry { @[pid, execname] = count(); }'
```

- Memory page-faults by process name:

```
dtrace -n 'vminfo:::as_fault { @mem[execname] = sum(arg0); }'
```

- Count requested `malloc` sizes in a process:

```
dtrace -n 'pid$target::malloc:entry { @[arg0] = count(); }' -p <PID>
```

- Distribution of requested `malloc` sizes in a process:

```
dtrace -n 'pid$target::malloc:entry { @ = quantize(arg0); }' -p <PID>
```

- User stack traces that resulted in the most heap memory requests:

```
dtrace -n 'pid$target::malloc:entry { @[ustack()] = sum(arg0); }' -p <PID>
```

- Disk I/O per second:

```
dtrace -n 'io:::start { @io = count(); } tick-1sec { printa("Disk I/Os per second: %@d \n", @io); trunc(@io); }'
```

Scripts
-------

- The top 10 processes causing the most I/O, along with the corresponding files

```dtrace
#!/usr/sbin/dtrace -qs

fsinfo::: /execname != "dtrace"/ {
  @[execname, probename, args[0]->fi_fs, args[0]->fi_pathname] = count();
}

dtrace:::END {
  trunc(@, 10);
  printf("%-16s %-8s %-8s %-42s %-8s\n", "EXEC", "FUNCTION", "FS TYPE", "PATH", "COUNT");
  printa("%-16s %-8s %-8s %-42s %-@8d\n", @);
}
```

The D Language
--------------

From an inline script:

```sh
dtrace -n 'probe /predicate/ { actions }'
```

From the command line:

```sh
dtrace -s script.d
```

From a script file:

```
#!/usr/sbin/dtrace -s

probe
/predicate/
{
  actions
}
```

More than one probe can be defined, separated by comma, if the predicate and
actions remain the same.

You can enable all probes of a certain namespace. For example, instead of
saying `syscall::exit:entry`, you can enable probes for the entry points of all
system calls as `syscall:::entry`. DTrace will interpret blank spaces between
colons as wildcards. You can also use wildcards. Like `syscall::read*:entry`.

A string can be checked for emptiness by comparing it with `NULL`.

Global variables might be accessed by probes firing from different CPUs, so
they can become corrupted.

Thread local variables are stored inside the `self` namespace. For example
`self->a`.

Clause local variables can only be used from a single action group. These are
stored inside the `this` namespace. These variables don't need to be freed as
they are automatically destroyed once the probe is executed.

File Descriptors
----------------

Given a file descriptor (i.e. as an argument to the `write` system call), we
can fetch a `fileinfo_t` structure with information about the file descriptor
using the `fds` object.

The `fileinfo_t` structure looks like this:

```c
typedef struct fileinfo {
  string fi_name;        // Basename of `fi_pathname`
  string fi_dirname;     // Dirname of `fi_pathname`
  string fi_pathname;    // Full path name
  offset_t fi_offset;    // Offset within the file
  string fi_fs;          // Filesystem
  string fi_mount;       // Mount point of file system
}
```

For example, we can find what files we're writing to with `write` as:

```
syscall::write:entry {
  @[fds[arg0].fi_pathname] = count();
}
```

Probes
------

Probe names are specified like this:

```
provider:module:function:name
```

- `provider`: The library providing such probe
- `module`: The kernel module or shared object library containing the probe
- `function`: The software function that contains this probe
- `name`: The descriptive name of the probe

### `dtrace:::BEGIN`

Triggers at the start of the program. Useful to print output headers.

### `dtrace:::END`

Triggers at the end of the program. Useful to print final reports.

### `profile:::profile-<number><unit>`

Fires on every CPU at a rate of `<number><unit>`. For example
`profile:::profile-199hz`.

This probe has two arguments: `arg0` is the program counter if running on the
kernel, and `arg1` is the program counter when running in user mode. Therefore
if `arg0` is true, then we're running in the kernel, and vice-versa.

### `profile:::tick-<number><unit>`

Fires on one CPU only, every `<number><unit>`. For example:
`profile:::tick-1s`.

Globals
-------

The D language provides the following variables in predicates:

- `arg0...arg9`: Probe arguments as unsigned 64-bit integers. Specific to each
  probe
- `args[]`: Typed probe arguments
- `cpu`: Current CPU id
- `curpsinfo`: Process state info for the current thread
- `curthread`: OS structure for the current thread
- `errno`: Error value from the last system call
- `execname`: Program name
- `pid`: Process ID
- `ppid`: Parent process ID
- `probeprov`: Provider name of the current probe
- `probemod`: Module name of the current probe
- `probefunc`: Function name of the current probe
- `probename`: Name of the current probe
- `stackdepth`: Current thread's stack frame depth
- `tid`: Current thread ID
- `timestamp`: Time since boot
- `uid`: Real user ID
- `uregs[]`: Current thread register values
- `vtimestamp`: Current thread's time in CPU
- `walltimestamp`: Epoch time

Macros
------

- `$target`: The process passed as `-p <pid>` or `-c <command>`
- `$1..$N`: Command line arguments to the D script
- `$$1..$$N`: Command line arguments to the D script, coerced to string

Aggregates
----------

Variables prefixed by `@`. For example:

```
@a = count();
```

They can be indexed, and the indexes appear as different columns:

```
@a[uid, probefunc] = count();
```

If the script only uses one aggregation, then you can just use `@` directly
(without a name).

The result is automatically sorted in ascending order.

### Aggregation Functions

- `count`: The number of times a probe was executed
- `sum`: The total value
- `avg`: The average value
- `min`: The smallest value
- `max`: The largest value
- `stddev`: The standard deviation
- `lquantize`: A linear frequency distribution
- `quantize`: A power-of-two frequency distribution

Functions
---------

### `trace()`

Print a variable.

### `printf()`

Print with formatting.

### `tracemem()`

Print a region of memory.

Providers
---------

These are libraries of probes. The most common ones are:

- `dtrace`: Housekeeping probes
- `syscall`: Probes at the entry and return points of all system calls
- `proc`: Probes for process and threads events
- `profile`: Probes for time-based data collection
- `fbt`: Boundary tracing, and probes at the entry and exit point of most
  kernel functions
- `lockstat`: Probes for kernel synchronization primitives
- `io`: Probes for I/O tracing

You can see a list of probes from a particular provider as:

```sh
dtrace -l -P <provider>
```

References
----------

- [DTrace: Dynamic Tracing in Oracle Solaris, Mac OS X and FreeBSD](https://www.amazon.com/DTrace-Dynamic-Tracing-Solaris-FreeBSD/dp/0132091518)
