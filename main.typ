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

= Fundamental Concepts
== Classes of Parallelism and Parallel Architectures
There are basically two kinds of parallelism in *applications*:
- _Data-level parallelism(DLP)_ arises because there are many data items that can be operated on at the same time.
- _Task-level parallelism (TLP)_ arises because tasks of work are created that can operate independently and largely in parallel.
*Computer hardware* in turn can exploit these two kinds of application parallelism in four major ways:
+ _Instruction-level parallelism_ exploits data-level parallelism at modest levels with compiler help using ideas like *pipelining* and at medium levels using ideas like *speculative execution*.
+ _Vector architectures, graphic processor units (GPUs)_, and _multimedia instruction sets_ exploit *data-level parallelism* by applying a single instruction to a col-lection of data in parallel.
+ _Thread-level parallelism_ exploits either _data-level parallelism_ or _task-level parallelism_ in a tightly coupled hardware model that allows for interaction between parallel threads.
+ _Request-level parallelism_ exploits parallelism among largely decoupled tasks specified by the programmer or the operating system.

== The Processor Performance Equation
Essentially all computers are constructed using a clock running at a constant rate. These discrete time events are called _clock periods, clocks, cycles,or clock cycles_. Computer designers refer to the time of a clock period by its duration (e.g., 1 ns) or by its rate (e.g., 1 GHz). CPU time for a program can then be expressed two ways:
$
  "CPU time" = "CPU clock cycles for a program" times "Clock cycle time"
$
Or
$
  "CPU time" = "CPU clock cycles for a program" / "Clock rate"
$
In addition to the number of clock cycles needed to execute a program, we can also count the number of instructions executed---the _instruction path length_ or _instruction count_ (IC). If we know the number of clock cycles and the instruction count, we can calculate the average number of _clock cycles per instruction_(CPI). CPI is computed as:
$
  "CPI" = "CPU clock cycles for a program" / "Instruction count"
$

#pagebreak()

= Pipelining
*Pipelining* is an implementation technique whereby multiple instructions are *overlapped* in execution; it takes advantage of *parallelism* that exists among the actions needed to execute an instruction.

A pipeline is like an *assembly line*. In a computer pipeline, each step in the pipeline completes a part of an instruction. Like the assembly line, different steps are completing different parts of different instructions in parallel. Each of these steps is called a _pipe stage_ or a _pipe segment_.

The _*throughput*_ of an instruction pipeline is determined by how often an instruction exits the pipeline. The time required between moving an instruction one step down the pipeline is a *processor cycle*.

Pipelining yields a reduction in the average execution time per instruction. If the starting point is a processor that takes multiple clock cycles per instruction, then pipelining reduces the CPI. Pipelining is an implementation technique that exploits *parallelism* among the instructions in a sequential instruction stream.

== The Basics of the RISC V Instruction Set
All RISC architectures are characterized by a few key properties:
1. All operations on data apply to data in registers and typically change the entire register(32 or 64 bits).
2. The only operations that affect memory are *load* and *store* operations that move data from memory to a register or to memory from a register, respectively.
3. The instruction formats are few in number, with all instructions typically being one size. In RISC V, the register specifiers: *rs1*, *rs2*, and *rd* are always in the same place simplifying the control.

Several common types of instructions in RISC-V:
- ALU instructions:
  - *Sum* between two *registers*:
  ```asm
  add rd, rs1, rs2     # $rd <- $rs1 + $rs2
  ```
  - *Sum* between *register* and *constant*:
  ```asm
  addi rd, rs1, imm    # $rd <- $rs1 + imm
  ```
- Load/Store instructions:
  - *Load*:
  ```asm
  ld rd, offset (rs1)  # $rd <- Memory[$rs1 + offset]
  ```
  From the *rs1* register, calculate the index on the memory with the *offset*, take the value and store it in the *rd* register.
  - *Store*:
  ```asm
  sd rs2, offset (rs1) # Memory[$rs1 + offset] <- $rs2
  ```
  Take the value from the *rs2* register and store it in the memory at the index calculated from the *rs1* register and the *offset*.
- Branch instructions to control the instruction flow:
  - *Conditional branches*:the branch is taken only if the condition is true.
  Only if the condition is true (branch on equal):
  ```asm
    beq rs1, rs2, L1 # go to L1 if (rs1 == rs2)
  ```
  Only if the condition is false (branch on not equal):
  ```asm
    bne rs1, rs2, L1 # go to L1 if (rs1 != rs2)
  ```
  - *Unconditional branches*: the branch is always taken.
  ```asm
      j L1              # go to L1
      jr ra             # go to add. contained in ra
  ```


== A Simple Implementation of a RISC Instruction Set
Every instruction in this RISC subset can be implemented in, at most, 5 clock cycles. The 5 clock cycles are as follows.
+ _Instruction Fetch(IF)_: Send the program counter (PC) to memory and fetch the current instruction from memory. Update the PC to the next *sequential instruction* by adding 4 (because each instruction is 4 bytes) to the PC.
+ _Instruction decode/register fetch cycle (ID)_: Decode the instruction and read the registers corresponding to register source specifiers from the register file. Do the equality test on the registers as they are read, for a possible branch. Sign-extend the offset field of the instruction in case it is needed. Compute the possible branch target address by adding the sign-extended offset to the incremented PC.
+ _Execution/effective address cycle (EX)_: The ALU operates on the operands prepared in the prior cycle, performing one of three functions, depending on the instruction type.
+ _Memory access (MEM)_: If the instruction is a load, the memory does a read using the effective address computed in the previous cycle. If it is a store, then the memory writes the data from the second register read from the register file using the effective address.
+ _Write-back cycle (WB)_: Write the result into the *register file*, whether it comes from the memory system (for a load) or from the ALU (for an ALU instruction).
