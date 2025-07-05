#import "@local/simple-note:0.0.1": *

#let nonum(eq) = math.equation(block: true, numbering: none, eq)

= Introduction
== Classes of Parallelism and Parallel Architectures
There are basically two kinds of parallelism in *applications*:
- _Data-level parallelism(DLP)_ arises because there are many data items that can be operated on at the same time.
- _Task-level parallelism (TLP)_ arises because tasks of work are created that can operate independently and largely in parallel.
*Computer hardware* in turn can exploit these two kinds of application parallelism in four major ways:
+ _Instruction-level parallelism_ exploits data-level parallelism at modest levels with compiler help using ideas like *pipelining* and at medium levels using ideas like *speculative execution*.
+ _Vector architectures, graphic processor units (GPUs)_, and _multimedia instruction sets_ exploit *data-level parallelism* by applying a single instruction to a col-lection of data in parallel.
+ _Thread-level parallelism_ exploits either _data-level parallelism_ or _task-level parallelism_ in a tightly coupled hardware model that allows for interaction between parallel threads.
+ _Request-level parallelism_ exploits parallelism among largely decoupled tasks specified by the programmer or the operating system.

All computers can be in one of the four categories:
- *_Single instruction stream, single data stream_* (SISD) --- This category is the uni-processor. It can exploit ILP, such as superscalar and speculative execution.
- _*Single instruction stream, multiple data streams*_ (SIMD) --- The same instruction is executed by multiple processors using different data streams. SIMD computers exploit data-level parallelism by applying the same operations to multiple items of data in parallel.
- _*Multiple instruction streams, single data stream*_ (MISD) --- No commercial multiprocessor of this type has been built to date, but it rounds out this simple classification.
- _*Multiple instruction streams, multiple data streams*_ (MIMD) --- Each processor fetches its own instructions and operates on its own data, and it targets task-level parallelism. It exploits both data-level parallelism and task-level parallelism. MIMD computers are the most common *_multiprocessors_* in use today.

#pagebreak()

== The Basics of the RISC V Instruction Set
All RISC architectures(*RISC V, MIPS, ARM*) are characterized by a few key properties:
+ *All operations on data apply to data in registers* and typically change the entire register(32 or 64 bits).
+ The only operations that affect memory are *load* and *store* operations that move data from memory to a register or to memory from a register, respectively.
+ The instruction formats are few in number, with all instructions typically being one size. In RISC V, the register specifiers: *rs1*, *rs2*, and *rd* are always in the same place simplifying the control.

=== ALU instructions:
- *Sum* between two *registers* (Read from *rs1* and *rs2*, Write to *rd*):
```asm
  add rd, rs1, rs2     # $rd <- $rs1 + $rs2
```
- *Sum* between *register* and *constant* (Read from *rs1*, Write to *rd*):
```asm
  addi rd, rs1, imm    # $rd <- $rs1 + imm
```

=== Load/Store instructions:
- *Load* (*Read* the value of *rs1* for address calculation, Write to *rd*):
```asm
  ld rd, offset (rs1)  # $rd <- Memory[$rs1 + offset]
```
From the *rs1* register, calculate the index on the memory with the *offset*, take the value and store it in the *rd* register.
- *Store* (*Read* the value of *rs1* for address calculation and the value of *rs2* for writing):
```asm
  sd rs2, offset (rs1) # Memory[$rs1 + offset] <- $rs2
```
Take the value from the *rs2* register and store it in the memory at the index calculated from the *rs1* register and the *offset*.

=== Branch instructions
- *Conditional branches*: the branch is taken only if the condition is true.
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

#pagebreak()
