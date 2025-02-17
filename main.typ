#import "./template.typ": *
#import "@preview/codelst:2.0.1": sourcecode
#import "@preview/lovelace:0.3.0": *

#show: template.with(
  title: [ Advanced Computer Architecture ],
  date: datetime(year: 2025, month: 2, day: 17),
  authors: (
    (
      name: "Rao",
      github: "https://github.com/Raopend",
      homepage: "https://github.com/Raopend",
    ),
  ),
  affiliations: (
    (
      id: "1",
      name: "Politecnico di Milano",
    ),
  ),
  // cover-image: "./figures/polimi_logo.png",
  background-color: "#FAF9DE",
)
#set math.mat(delim: "[")
#set math.vec(delim: "[")
#set math.equation(supplement: [Eq.])

= Pipelining
*Pipelining* is an implementation technique whereby multiple instructions are *overlapped* in execution; it takes advantage of *parallelism* that exists among the actions needed to execute an instruction.

A pipeline is like an *assembly line*. In a computer pipeline, each step in the pipeline completes a part of an instruction. Like the assembly line, different steps are completing different parts of different instructions in parallel. Each of these steps is called a _pipe stage_ or a _pipe segment_.

The _*throughput*_ of an instruction pipeline is determined by how often an instruction exits the pipeline. The time required between moving an instruction one step down the pipeline is a *processor cycle*.

Pipelining yields a reduction in the average execution time per instruction. If the starting point is a processor that takes multiple clock cycles per instruction, then pipelining reduces the CPI.

Pipelining is an implementation technique that exploits *parallelism* among the instructions in a sequential instruction stream.

== The Basics of the RISC V Instruction Set
All RISC architectures are characterized by a few key properties:
- All operations on data apply to data in registers and typically change the entire register(32 or 64 bits).
- The only operations that affect memory are *load* and *store* operations that move data from memory to a register or to memory from a register, respectively.
- The instruction formats are few in number, with all instructions typically being one size. In RISC V, the register specifiers: *rs1*, *rs2*, and *rd* are always in the same place simplifying the control.

== A Simple Implementation of a RISC Instruction Set
Every instruction in this RISC subset can be implemented in, at most, 5 clock cycles. The 5 clock cycles are as follows.
+ _Instruction Fetch(IF)_: Send the program counter (PC) to memory and fetch the current instruction from memory. Update the PC to the next *sequential instruction* by adding 4 (because each instruction is 4 bytes) to the PC.
+ _Instruction decode/register fetch cycle (ID)_: Decode the instruction and read the registers corresponding to register source specifiers from the register file. Do the equality test on the registers as they are read, for a possible branch. Sign-extend the offset field of the instruction in case it is needed. Compute the possible branch target address by adding the sign-extended offset to the incremented PC.
+ _Execution/effective address cycle (EX)_: The ALU operates on the operands prepared in the prior cycle, performing one of three functions, depending on the instruction type.
+ _Memory access (MEM)_: If the instruction is a load, the memory does a read using the effective address computed in the previous cycle. If it is a store, then the memory writes the data from the second register read from the register file using the effective address.
+ _Write-back cycle (WB)_: Write the result into the register file, whether it comes from the memory system (for a load) or from the ALU (for an ALU instruction).
