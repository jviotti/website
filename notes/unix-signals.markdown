---
title: UNIX Signals
description: Notes on UNIX signals
---

Signals are asynchronous notifications sent to processes by the kernel,
potentially in response to a hardware exception or interrupt. The kernel
interrupts the flow of execution of a process during any non-atomic instruction
to deliver the signal.

Signals are *not* queued. Processes have binary flags to represent whether a
signal is pending. When a signal is delivered, the corresponding binary flag
will be set to true. The signal will be delivered as soon as the signal is not
blocked and the binary flag will be reset to false. If a signal is delivered
multiple times, the corresponding binary flag is set to true, and the signal is
delivered once unless the binary flag is set to false before the new instance
of the signal is delivered.

Signal handlers are only executed when transitioning from kernel mode to user
mode. The kernel checks the pending signals when deciding to schedule a process
to run. When delivering a signal, the kernel stores the current execution
context into the user-space stack, creates a stack frame for the signal
handler, and jumps into the signal handler in user mode. After a signal handler
executes, the kernel takes over control in order to restore the execution
context.

Signal handlers
---------------

A process may specify signal handlers to *respond to*, *ignore*, or *block*
signals other than `SIGKILL` and `SIGSTOP`. If not handled, the default signal
handlers are executed (documented in `sigaction(2)`).

Programs may setup signal handlers using `sigaction(2)`, or its easier-to-use
wrapper `signal(3)`. The handler functions receive the signal number as an
argument.

### Safe handlers

Signals may be delivered while a signal handler is running. For this reason, it
is recommended for signal handlers to be reentrant (it can safely be executed
by multiple threads in parallel) and/or not be interruptible by signal
handlers.

Linux maintains a list of "async-signal-safe" functions that are safe to use in
signal handlers in
[`signal-safety(7)`](https://man7.org/linux/man-pages/man7/signal-safety.7.html).

### Global variables

POSIX defines an integer type `sig_atomic_t` that is safe to use as a global
variable shared between a program and its signal handlers. Read and write to
`sig_atomic_t` variables are atomic operations, but `++` and `--` are not. It
is recommended to declare `sig_atomic_t` variables as `volatile` to prevent
optimizer tricks.

### Handler stack

Signal handlers typically use the process' stack, but they can be configured to
use a custom stack with `sigaltstack(2)`. This can be useful when handling the
`SIGSEGV` signal, which can occur when the process stack space is exhausted.

### Nested signals

A signal may be delivered while its own signal handler is running. The signal
that triggered the handler is blocked by default when the handler runs, unless
the `SA_NODEFER` is set, in which case the new instance of the signal will be
set to pending and will be delivered once the running signal handler exits.

### Passing data

A process may send a signal along with a piece of data (an integer or a
pointer) by using `sigqueue(3)`. The corresponding handler can access this data
if it was setup with the `SA_SIGINFO` flag of `sigaction(2)`.

Working with signals
--------------------

### Sending signals

Processes may send signals using `kill(2)`. A process only has permission to
send a signal if the real or effective user ID match, or the user has
super-user privileges. As an exception, the `SIGCONT` can always be sent to any
descendant of the process. `kill(2)` will fail if the sender is configured to
ignore the signal.

The `kill(2)` function allows a process to send a signal to a specific process
(ignoring its descendants), to all the processes that belong to the sender's
process group ID, or (given super-user privileges) to all the processes
excluding system processes.

The shell sends interrup signals, like `SIGINT`, to the foregroung *process group*.

### Blocking (masking) signals

Signals, other than `SIGKILL` and `SIGSTOP`, can be blocked with
`sigprocmask(2)`. Blocked signals are delivered when the signal is unblocked.
The list of pending signals can be obtained with `sigpending(2)`. Blocking
signals is useful to prevent interrupts during critical code paths. Signal
masks are per thread, and not per process.

> The `SIGCONT` signal can't be blocked on Linux

The `sigaction(2)` function accepts a set of signals that must be blocked when
executing a particular signal handler. Also, the signal that executed the
current signal handler will be blocked unless the `SA_NODEFER` flag is set.

If a signal handler is updated while a signal is pending, then the updated
handler will be executed. The operating system only checks how a process wants
to react to a handler when delivering the signal, and not when setting the
signal's binary flag.

### Ignoring signals

Signals, other than `SIGKILL` and `SIGSTOP`, can be ignored using `signal(3)`
along with `SIG_IGN`.

### Resetting signals

Processes may reset a signal handler to its default by using `signal(3)` along
with `SIG_DFL`. The `sigaction(2)` function also supports a `SA_RESETHAND` flag
to implement one-shot signal handlers where the handler is reset after the
first handler execution.

### Waiting for signals

A process may wait for a signal to occur with the `sigwaitinfo(2)` or
`sigtimedwait(2)` (which supports a timeout argument) functions.

### Pausing and resuming processes

A process may be paused with `SIGSTOP` (sent when pressing `Ctrl-Z` on a shell)
and then resumed with `SIGCONT`.

### Terminating a process

There are many signals to terminate a process. `SIGTERM` allows a process to
gracefully terminate. `SIGKILL` inconditionally aborts the process and can be
used as a last resort. `SIGQUIT` terminates a process, potentially creating a
core dump.

Sub-processes
-------------

A forked process inherits the signal mask and all signal handlers. The
`execve(2)` resets all signal handlers but keeps the set of ignored and blocked
signals.

A parent process receives `SIGCHLD` when a child exits, unless the
`SA_NOCLDSTOP` flag of `sigaction(2)` is set. Handling `SIGCHLD` is *not* a
reliable way to wait for more than one children to exit, as multiple children
might exit while `SIGCHLD` is being handled, but `SIGCHLD` would only be
delivered once.

Threads
-------

If a process has more than one thread, then the signal handler is sent to only
one of its threads. This decision is implementation-specific. Programs may send
a signal to a specific thread using `pthread_kill(3)`.

Some signals generated a result of an specific instruction, such as `SIGSEGV`
and `SIGFPE`, will always be sent to the thread that executed such instruction.

Blocking operations (`EINTR`)
-----------------------------

If a signal is delivered while a blocking system call (like `read(2)`) is
running, then the system call will fail with `EINTR`. The calling program may
deal with `EINTR` by manually restarting the system call. Affected system calls
may also be automatically restarted after signal interruption if the signal is
setup with the `SA_RESTART` flag.

The full list of
affected system calls is documented in `sigaction(2)`:

> The affected system calls include open(2), read(2), write(2), sendto(2),
> recvfrom(2), sendmsg(2) and recvmsg(2)

References
----------

- https://en.wikipedia.org/wiki/Signal_(IPC)
- https://www.amazon.com/Design-UNIX-Operating-System/dp/0132017997
- https://man7.org/training/download/lusp_sighandlers_slides.pdf
- https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xsh_chap02.html#tag_22_02_04_02
- https://www.gnu.org/software/libc/manual/html_node/Job-Control-Signals.html
