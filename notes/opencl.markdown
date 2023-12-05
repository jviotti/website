---
title: OpenCL
description: A library and standard for writing parallel programing for various processors, including GPUs
---

These notes cover OpenCL 1.2 on macOS using an Intel Iris Plus Graphics 655 GPU
chipset.

Compiling
---------

On macOS, use `#include <OpenCL/cl.h>` and compile with `gcc opencl-test.c
-framework OpenCL`.

Architecture
------------

The computer running an OpenCL program (i.e. written in C/C++) is called the
*host*. Each processing element (i.e. a GPU) is called a *device*. The
implementation of OpenCL for a particular device is called a *platform* (i.e.
the Nvidia platform is used to interact with Nvidia devices).

In an OpenCL host application, one or more devices are grouped together as a
logical group called a *context*, where the application might control more than
one context. Each context has *command queues* that the *host* can use to
dispatch *commands* to the *context*, which are by default processed in order.
There are commands to transfer data and to perform computation.

A *kernel* is a *command* that represents a specially coded OpenCL function
that should be executed by one or more *devices*. An OpenCL *program* is a set
of *kernels*, usually defined as `.cl` files.

Device Memory Model
-------------------

An OpenCL device distinguishes four address spaces:

- **Global memory**: Read and write, and available to the whole device
- **Constant memory**: Read only, and available to the whole device. Some
  devices provide a memory region specifically for constant memory, but in many
  cases this is just a subset of the global memory
- **Local memory**: Read and write, and available to a whole work-group. Every
  work-item that belongs to the work-group can access this memory, but a
  work-group can't access the local memory of another work-group. This type of
  data will be allocated and deallocated once per work-group
- **Private memory**: Read and write, and available only to a particular
  work-item

Private memory is the fastest, but also the smallest. Conversely, global memory
is the biggest, but also the slowest.

Extensions
----------

There are various extensions to OpenCL. The ones approved by the OpenCL Working
Group are preffixed with `cl_khr_`, or suffixed with `KHR`, like
`cl_khr_gl_event` and `clCreateEventFromGLsyncKHR`. Non-approved extensions are
preffixed with `cl_<vendor>_`, like `cl_qcom_ext_host_ptr`.

Data Types
----------

OpenCL host programming supports the following two's complement integers:
`cl_char` and `cl_uchar` (8 bits), `cl_short` and `cl_ushort` (16 bits),
`cl_int` and `cl_uint` (32 bits), `cl_long` and `cl_ulong` (64 bits), and the
following floating-point values: `cl_half` (half-precision, 16 bits),
`cl_float` (single-precision, 32 bits), `cl_double` (double-precision, 64
bits).

Platforms
---------

We can find all available platforms, and information about them using
[`clGetPlatformIDs`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetPlatformIDs.html)
and
[`clGetPlatformInfo`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetPlatformInfo.html).

Devices
-------

We can find all the devices that belong to a given platform with
[`clGetDeviceIDs`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetDeviceIDs.html).
We can then get information about a specific device with
[`clGetDeviceInfo`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetDeviceInfo.html).

To get the first available GPU:

```c
cl_platform_id platform;
cl_device_id device;
cl_int result = clGetDeviceIDs(platform,
  CL_DEVICE_TYPE_GPU, 1, &device, NULL);
```

Devices may have a preferred type vector width that you can inspect with the
`CL_DEVICE_PREFERRED_VECTOR_WIDTH_<type>` flag:

```c
cl_device_id device;
cl_uint char_width;

clGetDeviceInfo(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR,
  sizeof(char_width), &char_width, NULL);
```

Its a common practice to fetch the preffered vector width and then pass it as a
define macro to the OpenCL program.

We can determine a device's endianness with the `CL_DEVICE_ENDIAN_LITTLE` flag
and checking whether the return valye is `CL_TRUE` or `CL_FALSE`.

Contexts
--------

We can create a context out of a set of devices from the same platform with
[`clCreateContext`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateContext.html).
We can also create a conetxt out of all the devices from the same platform that
match a certain type with
[`clCreateContextFromType`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateContextFromType.html).
A context must be destroyed with
[`clReleaseContext`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clReleaseContext.html).

Programs
--------

A program is usually created with
[`clCreateProgramWithSource`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateProgramWithSource.html)
from the source code out of `.cl` files. The program can then be built with
[`clBuildProgram`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clBuildProgram.html),
which allows us to customize various options such as the include path (`-I`).
Its recommended to report warnings as errors with `-Werror`. Programs are
destroyed with
[`clReleaseProgram`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clReleaseProgram.html).

We can get build logs after attempting to build a program using
[`clGetProgramBuildInfo`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetProgramBuildInfo.html).
For example:

```c
cl_device_id device;
cl_program program;

// Find the size of the logs
size_t log_size;
clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, 0, NULL, &log_size);

char * program_log;
program_log = (char *) malloc(log_size + 1);
program_log[log_size] = '\0';

// Get the logs
clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, log_size + 1, program_log, NULL);
printf("%s\n", program_log);
free(program_log);
```

The macro `__ENDIAN_LITTLE__` is always defined if the device is little endian,
and undefined otherwise.

Command Queues
--------------

A command queue must be created for one or more devices that are part of the
same context. The
[`clCreateCommandQueue`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateCommandQueue.html)
function allows us to configure whether the commands are executed in order or
not. A command queue must be destroyed with
[`clReleaseCommandQueue`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clReleaseCommandQueue.html).

The lifecycle of a command consists of:

- `CL_QUEUED`: The command has been added to the queue
- `CL_SUBMITTED`: The command has been submited to the device
- `CL_RUNNING`: The command is running on the device
- `CL_COMPLETE`: The command has finished running

Every command has a *wait list* that consists of a set of `cl_event`
structures. The command will not start executing until the wait list is empty
(i.e. `NULL`). We can pass a wait list when using i.e.
[`clEnqueueTask`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueTask.html)
as a simple way to synchronize execution.

In order to profile a command queue, create the queue with the
`CL_QUEUE_PROFILING_ENABLE` flag, create a `cl_event` with a callback and
associate it with the command that you want to profile, and on the callback,
execute
[`clGetEventProfilingInfo`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetEventProfilingInfo.html)
with `CL_PROFILING_COMMAND_QUEUED`, `CL_PROFILING_COMMAND_START`, and
`CL_PROFILING_COMMAND_END`, and perform arithmetic between the resulting
timestamps.

Synchronization
---------------

The
[`clEnqueueWaitForEvents`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clEnqueueWaitForEvents.html)
operation forces a command queue to not execute any following commands until
all the events in the queue reached the "completed" state. The
[`clEnqueueBarrier`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clEnqueueBarrier.html)
function has a similar effect, but it enqueues a "barrier command" instead of
using the wait list.

Kernels may use the
[`barrier`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/barrier.html)
function inn a work-item to wait until every other work-item in the group
reached the barrier. Fences (see
[`read_mem_fence`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/read_mem_fence.html),
[`write_mem_fence`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/write_mem_fence.html),
and
[`mem_fence`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/mem_fence.html))
are similar to barriers, but can synchronize specific memory operations.

Currently there is no way to synchronize work-items from different work-groups
apart from executing new kernels.

Events
------

The command queue "enqueue" functions can be associated with a `cl_event` data
structure which contains a callback function that will be executed whenever a
command changes its status. These callback functions have the following signature:

```c
void CL_CALLBACK callback(cl_event event, cl_int status, void * data);
```

An `cl_event` is associated with a callback function using
[`clSetEventCallback`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clSetEventCallback.html).
The `user_data` argument passed to this function will become the callback's
`data` argument. Notice an event must be associated with a callback *after*
enqueuing the command.

A user event is an event controlled by the host application. See
[`clCreateUserEvent`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clCreateUserEvent.html)
and
[`clReleaseEvent`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clReleaseEvent.html).
A user event is not associated with a particular command queue, so we can use
the same event for multiple devices. If you set a user event in a command's
wait list, the command will not execute until you manually update the user
event's status from the host with
[`clSetUserEventStatus`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clSetUserEventStatus.html).

Kernels
-------

See
[`clCreateKernel`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateKernel.html)
and
[`clReleaseKernel`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clReleaseKernel.html).
We need to set the arguments to the kernel with
[`clSetKernelArg`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clSetKernelArg.html)
**before** enqueuing it. We can enqueue kernels on a command queue using
[`clEnqueueTask`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueTask.html)
and
[`clEnqueueNDRangeKernel`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueNDRangeKernel.html).
The latter offers finer control over how the kernel executes.

Kernel declarations must start with `__kernel` and must always return `void`.
Since kernels don't have a return value, we have to "output" data by writing to
arguments.

Every kernel argument must have either `__global`, `__constant`, `__local` or
the `__private` (default) qualifier (see *Device Memory Model*). The `__global`
qualifier can only be used with pointers. Since `__constant` is read-only, it
must be initialized on its declaration (a define `-D` macro is usually
preferred). If a kernel argument doesn't have an address space qualifier, then
its assumed to be `__private`. Transferring `NULL` to a kernel will make it
just reserve memory in its local space for the kernel argument.

Private kernel arguments can only be primitives or vectors. We can use
primitives such as `int` but also i.e. an array of 4 floats interpreted in the
kernel as `float4`, as private arguments can't be pointers.

For performance reasons: try to re-use private variables to reduce kernel
memory consumption, inline non kernel functions, use the
[`fma`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/fma.html)
for multiply and add operations, access local memory sequentially, and avoid
branch "miss penalties" by ensuring conditional statements are more often true
than false.

We can use asynchronous calls to transfer data between global and local memory.
See
[`async_work_group_copy`](https://www.khronos.org/registry/OpenCL/sdk/1.2/docs/man/xhtml/async_work_group_copy.html),
and
[`async_work_group_strided_copy`](https://www.khronos.org/registry/OpenCL/sdk/1.2/docs/man/xhtml/async_work_group_strided_copy.html).
In order to wait until the data transfers complete, see
[`wait_group_events`](https://www.khronos.org/registry/OpenCL/sdk/1.2/docs/man/xhtml/wait_group_events.html).

Vectors
-------

This is a composite data type that consist of an array of a certain number of
primitive elements. For example `float4` represents an array of 4 floats.  The
possible types are `charN`, `ucharN`, `shortN`, `ushortN`, `intN`, `uintN`,
`longN`, `ulongN` and `floatN`, where `N` is 2, 3, 4, 8, or 16. Some devices
may support `doubleN` and `halfN`.

We can initialize vectors as `(type) (value1, value2, ..., valueN)` where the
values are primitives or other vectors. For example:

```c
float4 vector1 = (float4) (1.0, 2.0, 3.0, 4.0);
float2 subvector1 = (float2) (1.0, 2.0);
float4 vector2 = (float4) (subvector1, 3.0, 4.0);
```

OpenCL supportts arithmetic operations over vectors. For example:

```c
float4 vector1 = (float4) (1.0, 2.0, 3.0, 4.0);
float4 vector2 = (float4) (3.0, 4.0, 5.0, 6.0);
float4 result = vector1 + vector2;
// (4.0, 6.0, 8.0, 10.0)
```

Vectors are indexed for read or write purposes as `vector.<index>` where index
can be `.s` and one or more hexadecimal digits starting from 0 (`vector.s0`,
`vector.s01234`, `vector.s01AB`), `.x`/`.y`/`.z`/`.w`, which are synonymous to
`.s0`/`.s1`/`.s2`/`.s3`, `.hi` or `.lo` (highest or lowest halves), and
`.even`/`.odd` (even or odd elements).

Buffers
-------

Buffers belong to a context. They are created with
[`clCreateBuffer`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateBuffer.html)
and
[`clCreateSubBuffer`](https://www.khronos.org/registry/OpenCL/sdk/1.1/docs/man/xhtml/clCreateSubBuffer.html),
and destroyed with
[`clReleaseMemObject`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clReleaseMemObject.html).
A sub-buffer is useful if a kernel needs a subset of the data passed to another
kernel. The sub-buffer is a reference to an offset of the super-buffer, and
there is no allocation involved.

Buffers take the following access flags: `CL_MEM_READ_WRITE`,
`CL_MEM_READ_ONLY`, and `CL_MEM_WRITE_ONLY`. If you are passing a write-only
parameter to get data back from a kernel, then you can set the access level to
`CL_MEM_WRITE_ONLY` and make it initially `NULL`:

```c
cl_context context;
cl_int result;
cl_mem output = clCreateBuffer(context, CL_MEM_WRITE_ONLY, sizeof(result), NULL, NULL);
```

Image Objects
-------------

Image objects are `cl_mem` buffers meant to hold pixel data. See
[`clCreateImage2D`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateImage2D.html)
and
[`clCreateImage3D`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clCreateImage3D.html).
These two constructors take a `row_pitch` argument that determines how many
bytes each row occupies.  If `row_pitch` is set to 0, OpenCL will assume its
value equals `width * pixel size`. `clCreateImage3D` also takes a `slice_pitch`
argument that determines the number of bytes in each 2D slice. If `slice_pitch`
is set to 0, its value will be set to `row_pitch * height`.

On GPUs, image objects are stored in *texture memory*, a special global memory
region cached for performance reasons.

Data Transfer
-------------

- [`clEnqueueCopyBuffer`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueCopyBuffer.html):
  Copy a buffer to another buffer
- [`clEnqueueCopyImage`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueCopyImage.html):
  Copy an image object to another image object
- [`clEnqueueMapBuffer`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueMapBuffer.html):
  Map a buffer into host memory
- [`clEnqueueMapImage`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueMapImage.html):
  Map an image object into host memory
- [`clEnqueueUnmapMemObject`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueUnmapMemObject.html):
  Unmap a buffer or image object
- [`clEnqueueReadBuffer`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueReadBuffer.html):
  Read a buffer into host memory
- [`clEnqueueReadImage`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueReadImage.html):
  Read an image object into host memory
- [`clEnqueueWriteBuffer`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueWriteBuffer.html):
  Write to a buffer from host memory
- [`clEnqueueWriteImage`](https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clEnqueueWriteImage.html):
  Write to an image object from host memory

The read/write functions take a `blocking` argument to control whether the
function should wait for the data transfer to complete before returning or not.

Atomic Operations
-----------------

OpenCL defines various atomic operations for kernel programming such as
`atomic_add` and `atomic_inc`. See [Atomic
Functions](https://www.khronos.org/registry/OpenCL/sdk/1.2/docs/man/xhtml/atomicFunctions.html)
for details. The availability of these functions depend on the extensions
supported by the target device.

We can use
[`atom_xchg`](https://www.khronos.org/registry/OpenCL/sdk/1.2/docs/man/xhtml/atom_xchg.html)
(swap arguments) and
[`atom_cmpxchg`](https://www.khronos.org/registry/OpenCL/sdk/1.2/docs/man/xhtml/atom_cmpxchg.html)
(ternary conditional operation) to implement a mutex system. These two
functions require the `cl_khr_int64_base_atomics` extension, which can be
enabled with `#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable`.

Resources
---------

- [Mac computers that use OpenCL and OpenGL graphics](https://support.apple.com/en-us/HT202823)
- [Khronos OpenCL Registry](https://www.khronos.org/registry/OpenCL/)
- [OpenCL in Action](https://www.manning.com/books/opencl-in-action)
- [The OpenCL v1.2 Extension Specification](https://www.khronos.org/registry/OpenCL/specs/opencl-1.2-extensions.pdf)
- [How does a GPU shader core work?](http://aras-p.info/texts/files/2018Academy%20-%20GPU.pdf)
