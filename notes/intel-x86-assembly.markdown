---
title: Intel x86 Assembly
description: Notes on x86 assembly
---

- Output Intel assembly from C program: `clang -S -masm=intel <program>.c`
- Dissasemble object: `gobjdump -d -M intel <object>`

Resources
---------

- [x86 and amd64 instruction reference](https://www.felixcloutier.com/x86/)
- [Intel x86 Assembler Instruction Set Opcode Table](http://sparksandflames.com/files/x86InstructionChart.html)
- [Intel 64 and IA-32 Architectures Software Developer's Manual](https://software.intel.com/sites/default/files/managed/39/c5/325462-sdm-vol-1-2abcd-3abcd.pdf)

Registers
---------

- Register names are case-insensitive in Intel assembly
- Registers `EAX`, `EBX`, `ECX`, and `EDX` include "sub-registers" called
  subsections
- On LLDB, read registers with `register read --all`

#### General Purpose Registers

| Name | Size | Notes |
|------|------|-------|
| `RAX` | 64-bits | |
| `RBX` | 64-bits | |
| `RCX` | 64-bits | |
| `RDX` | 64-bits | |
| `RSI` | 64-bits | |
| `RDI` | 64-bits | |
| `EAX` | 32-bits | Least-significant half of `RAX` |
| `EBX` | 32-bits | Least-significant half of `RBX` |
| `ECX` | 32-bits | Least-significant half of `RCX` |
| `EDX` | 32-bits | Least-significant half of `RDX` |
| `ESI` | 32-bits | Least-significant half of `RSI` |
| `EDI` | 32-bits | Least-significant half of `RDI` |
| `AX` | 16-bits | Least-significant half of `EAX` |
| `BX` | 16-bits | Least-significant half of `EBX` |
| `CX` | 16-bits | Least-significant half of `ECX` |
| `DX` | 16-bits | Least-significant half of `EDX` |
| `AH` | 8-bits | Most-significant half of `AX` |
| `AL` | 8-bits | Least-significant half of `AX` |
| `BH` | 8-bits | Most-significant half of `BX` |
| `BL` | 8-bits | Least-significant half of `BX` |
| `CH` | 8-bits | Most-significant half of `CX` |
| `CL` | 8-bits | Least-significant half of `CX` |
| `DH` | 8-bits | Most-significant half of `DX` |
| `DL` | 8-bits | Least-significant half of `DX` |

Size Directives
---------------

| Name | Size |
|------|------|
| `BYTE` | 8-bits |
| `WORD` | 16-bits |
| `DWORD` | 32-bits |
| `QWORD` | 64-bits |

C Calling Convention
--------------------

- (Caller) Push the caller-saved registers onto the stack (`EAX`, `ECX`, `EDX`)
- (Caller) Push subroutine arguments onto the stack in reverse order (first
  argument last)
- (Caller) Push the return address onto the stack (done by `call`)
- (Caller) Jump to the subroutine address
- (Callee) Push the current base pointer (`EBP`) onto the stack
- (Callee) Copy the stack pointer (`ESP`) into the base pointer (`EBP`, which
  will be the point of reference to access arguments)
- (Callee) Increase the size of the stack to account for local variables
  (accessed using `EBP` as a point of reference as well)
- (Callee) Push the callee-saved (`EBX`, `EDI`, `ESI`) registers used by the
  function onto the stack
- (Callee) Perform the subroutine computation
- (Callee) Store the return value in `EAX`
- (Callee) Pop the called-saved registers from the stack
- (Callee) Restore the stack pointer my moving `ESP` to `EBP` (de-allocates
  local variables)
- (Callee) Pop the base pointer (`EBP`) from the stack
- (Callee) Pop the return address from the stack and jump to it (done by `ret`)
- (Caller) Remove subroutine arguments from the stack
- (Caller) Pop the caller-saved registers from the stack


