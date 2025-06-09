#import "@local/simple-note:0.0.1": *
#import "@preview/cetz:0.3.4": *
#import "@preview/muchpdf:0.1.0": muchpdf
#show: codly-init.with()

#show: simple-note.with(
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
  background-color: "#DDEEDD",
)
#set text(fill: rgb("#000000"))
#set math.mat(delim: "[")
#set math.vec(delim: "[")
#set math.equation(supplement: [Eq.])

#let nonum(eq) = math.equation(block: true, numbering: none, eq)
#let firebrick(body) = text(fill: rgb("#b22222"), body)


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

All computers can be in one of the four categories:
- *_Single instruction stream, single data stream_* (SISD) --- This category is the uniprocessor. It can exploit ILP, such as superscalar and speculative execution.
- _*Single instruction stream, multiple data streams*_ (SIMD) --- The same instruction is executed by multiple processors using different data streams. SIMD computers exploit data-level parallelism by applying the same operations to multiple items of data in parallel.
- _*Multiple instruction streams, single data stream*_ (MISD) --- No commercial multiprocessor of this type has been built to date, but it rounds out this simple classification.
- _*Multiple instruction streams, multiple data streams*_ (MIMD) --- Each processor fetches its own instructions and operates on its own data, and it targets task-level parallelism. It exploits both data-level parallelism and task-level parallelism. MIMD computers are the most common *_multiprocessors_* in use today.

#muchpdf(read("figures/parallelism.pdf", encoding: none))

#pagebreak()

== Five classic components of a computer
The five classic components are shown in the @fig:five-classic-components. The five components perform the tasks of *inputting, outputting, processing and storing data*.

#figure(
  image("figures/five-classic-components.jpg", width: 80%),
  caption: [ Five classic components of a computer],
) <fig:five-classic-components>

The five classic components of a computer are *input, output, memory, datapath, and control*, with the last two sometimes combined and called the processor.
- The *processor* gets instructions and data from memory.
- *Input* writes data to memory, and *output* reads data from memory.
- *Control* sends the signals that determine the operations of the datapath, memory, input, and output.

== The CPU Performance
Essentially all computers are constructed using a clock running at a constant rate. These discrete time events are called _clock periods, clocks, cycles,or clock cycles_. Computer designers refer to the time of a clock period by its duration (e.g., 1 ns) or by its rate (e.g., 1 GHz). CPU time for a program can then be expressed two ways:
$
  "CPU time" = "CPU clock cycles for a program" times "Clock cycle time"
$
Alternatively, because clock rate and clock cycle time are inverses,
$
  "CPU time" = "CPU clock cycles for a program" / "Clock rate"
$
#example("Improving Performance")[
  Our favorite program runs in 10 seconds on computer A, which has a 2 GHz clock. We are trying to help a computer designer build a computer, B, which will run this program in 6 seconds. The designer has determined that a substantial increase in the clock rate is possible, but this increase will affect the rest of the CPU design, causing computer B to require 1.2 times as many clock cycles as computer A for this program.

  What clock rate should we tell the designer to target?

  Find the number of clock cycles for computer A:
  #nonum($
    "CPU time"_A =& "CPU clock cycles for a program"_A / "Clock rate"_A \
    10 =& "CPU clock cycles for a program"_A / (2 times 10^9) \
  $)
  #nonum($
    "CPU clock cycles"_A =& 20 times 10^9
  $)

  CPU time for B can be found using this equation:
  #nonum($
    "CPU time"_B =& "CPU clock cycles for a program"_B / "Clock rate"_B \
    6 =& 1.2 times "CPU clock cycles for a program"_A / "Clock rate"_B \
  $)
  #nonum($
    "Clock rate"_B=& (1.2 times 20 times 10^9) / 6 = 4 "Ghz"
  $)
]

== Instruction Performance
One way to think about execution time is that it equals the number of instructions executed multiplied by the average time per instruction. Therefore, the number of clock cycles required for a program can be written as *CPI* is computed as:
$
  "CPU clock cycles" = "Instructions for a program" times "Average cycles per instruction"
$
The term clock cycles per instruction, which is the average number of clock cycles each instruction takes to execute, is often abbreviated as *CPI*.
$
  "CPI" = "CPU clock cycles" / "Instructions for a program"
$
We can now write this basic performance equation in terms of instruction count (the number of instructions executed by the program), CPI, and clock cycle time:
$
  "CPU time" = "Instruction count" times "CPI" times "Clock cycle time"
$
or, since the clock rate is the inverse of clock cycle time:
$
  "CPU time" = "Instruction count" times "CPI" / "Clock rate"
$

== The Basics of the RISC V Instruction Set
All RISC architectures(*RISC V, MIPS, ARM*) are characterized by a few key properties:
1. *All operations on data apply to data in registers* and typically change the entire register(32 or 64 bits).
2. The only operations that affect memory are *load* and *store* operations that move data from memory to a register or to memory from a register, respectively.
3. The instruction formats are few in number, with all instructions typically being one size. In RISC V, the register specifiers: *rs1*, *rs2*, and *rd* are always in the same place simplifying the control.

Several common types of instructions in RISC-V:
- ALU instructions:
  - *Sum* between two *registers* (Read from *rs1* and *rs2*, Write to *rd*): ```asm
    add rd, rs1, rs2     # $rd <- $rs1 + $rs2
    ```
  - *Sum* between *register* and *constant* (Read from *rs1*, Write to *rd*): ```asm
    addi rd, rs1, imm    # $rd <- $rs1 + imm
    ```
- Load/Store instructions:
  - *Load* (*Read* the value of `rs1` for address calculation, Write to *rd*): ```asm
    ld rd, offset (rs1)  # $rd <- Memory[$rs1 + offset]
    ```
  From the *rs1* register, calculate the index on the memory with the *offset*, take the value and store it in the *rd* register.
  - *Store* (*Read* the value of `rs1` for address calculation and the value of `rs2` for writing): ```asm
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

#pagebreak()

= Instruction-Level Parallelism
There are two largely separable approaches to exploiting ILP:
- An approach that relies on hardware to help discover and exploit the parallelism dynamically
- An approach that relies on software technology to find parallelism statically at *compile time*.

== Dependences and Hazards
There are three different types of dependences: _data dependences_ (also called true data dependences), _name dependences_, and _control dependences_.

=== (True) Data Dependences
An instruction $j$ is data-dependent on instruction $i$ if either of the following holds:
- Instruction $i$ produces a result that may be used by instruction $j$.
- Instruction $j$ is *data-dependent* on instruction $k$, and instruction $k$ is data-dependent on instruction $i$.
The second condition simply states that one instruction is dependent on another if there exists a chain of dependences of the first type between the two instructions. This dependence chain can be as long as the entire program. Note that a dependence within a single instruction (such as `add x1, x2, x3`)

A data dependence conveys three things:
+ the possibility of a *hazard*
+ the order in which results must be calculated
+ an upper bound on *how much parallelism* can possibly be exploited.

=== Name Dependences
A _*name dependence*_ occurs when two instructions use the same register or memory location, called a name, *but there is no flow of data* between the instructions associated with that name. There are two types of name dependences between an instruction $i$ that precedes instruction $j$ in program order:
+ An _*antidependence*_ between instruction $i$ and instruction $j$ occurs when instruction $j$ writes a register or memory location that instruction $i$ reads. *(Write After Read, WAR)*
+ An _*output dependence*_ when instruction $i$ and instruction $j$ write the same register or memory location. The ordering between the instructions must be preserved to ensure that the value finally written corresponds to instruction $j$. *(Write After Write, WAW)*

== Summary of Data Dependencies
Data dependency does not directly determine the *number of pipeline stalls*, whether true hazards occur, and how to eliminate them; it depends on how the pipeline handles these dependencies. In other words, the architectural characteristics of the pipeline determine:
- wether there is a hazard
- If there is a hazard, how to eliminate it(hardware or compiler)
- If it cannot be optimized, the pipeline needs to stop several times

When the pipeline executes instructions, the dependency relationships between instructions may lead to the following three types of data hazards:
- *RAW hazards* correspond to *true data dependencies*
- *WAR hazards* correspond to *anti-dependencies*
- *WAW hazards* correspond to *output dependencies*

Dependencies are a property of the program, while hazards are a property of the pipeline architecture.

A control dependence determines the ordering of instructions and it is preserved by two properties:
- Instructions execution in program order to ensure that an instruction that occurs before a branch is executed before the branch.
- Detection of control hazards to ensure that an instruction (that is control-dependent on a branch) is not executed until the branch direction is known.

Although preserving control dependence is a simple way to preserve program order, control dependence is not the critical property that must be preserved(as seen when we've studied scheduling techniques to fill in the branch delay slot).

Two properties are critical to preserve program correctness (and normally preserved by maintaining both data and control dependencies during scheduling):
- *Data flow*: Actual flow of data values among instructions that produces the correct results and consumes them.
- *Exception behavior*: Preserving exception behavior means that any changes in the ordering of instruction execution must not change how exceptions are raised in the program.

== Register Renaming
If the register used could be changed, then the instructions do not conflict anymore.

#example("Register Renaming")[
  ```asm
  Ii: r3 <-  (r1)  op  (r2)
  Ij: r1 <- (r4) op (r5) => r4 <- (r4) op (r5)

  Ii: r3 <-  (r1)  op  (r2)
  Ij: r3 <- (r6) op (r7) => r4 <- (r6) op (r7)
  ```
]
Register renaming can be more easily done, if there are enough registers available in the ISA. Register Renaming can be done either statically by the compiler or dynamically by the hardware.



== Multi-cycle Pipeline
We consider *single-issue* processors (one instruction issued per clock cycle).
- Instructions are then *issued in-order*.
- *Execution stage* might require multiple cycles latency, depending on the operation type (i.e., multiply operations are typically longer than add/sub operations).
- *Memory stages* might require multiple cycles access time due to instruction and data cache misses.

=== Multi-cycle In-Order Pipeline
#figure(
  image("figures/multi-cycle-in-order-pipeline.jpg", width: 80%),
  caption: "Multi-cycle In-Order Pipeline",
)

#figure(image("figures/multi-cycle-in-order-pipeline1.jpg", width: 80%))

- *In-order issue* & *In-order commit* of instructions.
- This avoids the generation of *WAR* & *WAW* hazards and preserves the *precise exception model*.

=== Multi-cycle Out-of-Order Pipeline
#figure(
  image("figures/multi-cycle-out-of-order.jpg", width: 80%),
  caption: "Multi-cycle Out-of-Order Pipeline",
)
- ID stage split in 2 stages: Instr. Decode (*ID*) & Register Read (*Issue*);
- Multiple functional units with variable latency;
- Long latency *multi-cycle floating-point instructions*;
- Memory systems with variable access time: *Multi-cycle memory accesses* due to data cache misses (unpredictable statically);
- *Out-of-order commit*: Need to check for WAR & WAW hazards and imprecise exception

#figure(image("figures/multi-cycle-out-of-order1.jpg", width: 80%))
- *In-order issue* of instructions
- *Out-of-order execution & out-of-order commit* of instructions
- Need to check the generation of *WAR & WAW hazards* and imprecise exceptions.

=== Dynamic Scheduling
*Problem*: Hazards due to true data dependencies that
cannot be solved by forwarding cause stalls of the pipeline. No new instructions are fetched nor issued even if they are not data dependent
\
*Solution*: Allow data independent instructions behind a stall to proceed: Hardware manages dynamically the instruction execution to reduce stalls: an instruction execution begins as soon as their operands are available.

#pagebreak()

= Hardware Pipelining
*Pipelining* is an implementation technique whereby multiple instructions are *overlapped* in execution; it takes advantage of *instruction-level parallelism* that exists among the actions needed to execute an instruction.

A pipeline is like an *assembly line*. In a computer pipeline, each step in the pipeline completes a part of an instruction. Like the assembly line, different steps are completing different parts of different instructions in parallel. Each of these steps is called a _pipe stage_ or a _pipe segment_.

The _*throughput*_ of an instruction pipeline is determined by how often an instruction exits the pipeline. The time required between moving an instruction one step down the pipeline is a *processor cycle*.

Pipelining yields a reduction in the average execution time per instruction. If the starting point is a processor that takes multiple clock cycles per instruction, then pipelining reduces the CPI. Pipelining is an implementation technique that exploits *parallelism* among the instructions in a sequential instruction stream.

#attention("throughput")[
  Remind that pipelining improves *instruction throughput*, but not the latency of the single instruction.
]

In a pipelined processor, *_Instruction Memory (IM), Data Memory (DM), and the Register File (RF)_* are critical components that interact with different pipeline stages to enable parallel instruction execution.
+ The *Instruction Memory* Stores the program instructions, and is accessed in the *Instruction Fetch (`IF`)* stage of the pipeline.
+ The *Data Memory* Stores runtime data (variables, arrays, etc.) and is accessed in the *Memory Access (`MEM`)* stage of the pipeline.
+ The *Register File* Holds the CPU's registers (e.g., 32 registers in RISC-V). In `ID` stage, it reads the source registers specified by the instruction, and in `WB` stage, it writes back results to the destination register.

#pagebreak()

== Five Stage Implementation of a RISC Instruction Set
Every instruction in this RISC subset can be implemented in, at most, *5 clock cycles*. The 5 clock cycles are as follows.

=== Instruction Fetch (IF)
Send the *program counter* (PC) to memory and fetch the current instruction from *_Instruction Memory_*. Update the PC to the next *sequential instruction* by adding 4 (because each instruction is 4 bytes) to the PC.


=== Instruction Decode/Register Fetch (ID)
Decode the instruction and read the registers corresponding to register source specifiers from the *register file*. Do the equality test on the registers as they are read, for a possible branch. Sign-extend the offset field of the instruction in case it is needed. Compute the possible branch target address by adding the sign-extended offset to the incremented PC.

=== Execution/effective address cycle (EX)
The *ALU* operates on the operands prepared in the prior cycle, performing one of three functions, depending on the instruction type.
- _Memory reference_ --- The ALU adds the base register and the *offset* to form the effective address.
- _Register-Register ALU instruction_ --- The ALU performs the specified operation on the two source registers.
- _Register-Immediate ALU instruction_ --- The ALU performs the specified operation on the source register and the immediate value.
- _Conditional branch_ --- Determine whether the condition is true.

=== Memory access (MEM)
If the instruction is a *load*, the memory does a read using the effective address computed in the previous cycle. If it is a *store*, then the memory writes the data from the second register read from the register file using the effective address.

=== Write-back cycle (WB)
Write the result into the *register file*, whether it comes from the memory system (for a load) or from the ALU (for an ALU instruction).

#pagebreak()

== Implementation of RISC-V processor
The *Instruction Memory*(read-only memory) is separated from *Data Memory*. 32 General-Purpose Registers organized in a *Register File(RF)* with 2 read ports and 1 write port.

For every instruction, the first two steps are identical:
+ Send the *_program counter (PC)_* to the memory that contains the code and fetch the instruction from that memory.
+ *Read one or two registers*, using fields of the instruction to select the registers to read. For the `ld` instruction, we need to read only one register, but most other instructions require reading two registers.

Fortunately, for each of the three instruction classes(memory-reference,arithmetic-logical, and branches), the actions are largely the same, independent of the exact instruction:

For example, all instruction classes use the *arithmetic-logical unit* (ALU) after reading the registers.
- For the *memory-reference* instructions, the ALU computes the effective address by adding the offset to the base register.
- For the *arithmetic-logical* instructions, the ALU performs the operation specified by the instruction.
- For the *branch* instructions, the ALU compares the two registers to determine if the branch should be taken(*equality test*).

#figure(
  image("figures/basic-implementation-risc-datapath.jpg", width: 80%),
  caption: "Basic Implementation of a RISC-V data path",
)

#figure(
  image("figures/implementation-risc-datapath.jpg", width: 80%),
  caption: "A complete implementation of RISC-V data path",
)

== Five-Stage Pipeline
Sequential is slower than pipeline. The following figure shows the difference (in terms of clock cycles) between sequential and pipeline.

#figure(
  image("figures/sequential-vs-pipelining-1.jpg", width: 70%),
  caption: "Sequential vs Pipeline",
)

The time to advance the instruction of one stage in the pipeline corresponds to a *clock cycle*. The total cost is: 9 clock cycles.

The pipeline stages must be *synchronized*, the duration of a clock cycle is defined by the time requested by the *slower stage* of the pipeline. The goal is to balance the length of each pipeline stage. If the stages are perfectly balanced, the *ideal speedup* due to pipelining is equal to the number of pipeline stages.

The sequential and pipelining cases consist of 5 instructions, each of which is divided into 5 low-level instructions of 2 ns each.
- The *latency* (total execution time) of each instruction is not varied, it's always 10 ns.
- The *throughput* (number of low-level instructions completed in the time unit) is improved:
  - Sequential: 1 instruction completed every 10 ns
  - Pipelining: 1 instruction completed every 2 ns

We want to perform the following assembly lines:
```asm
op $x , $y , $z       # assume $x <- $y + $z
lw $x , offset ($y)   # $x <- M[$y + offset ]
sw $x , offset ($y)   # M[$y + offset ] <- $x
beq $x , $y , offset
```

#figure(
  image("figures/pipeline_execution.jpg", width: 80%),
  caption: [ Pipeline Execution of RISC-V Instructions ],
)

Resources used during the pipeline execution
*IM* is Instruction Memory, *REG* is Register File and *DM* is Data Memory:

#figure(
  image("figures/resource_used_pipeline.jpg", width: 80%),
  caption: [Resources used during the pipeline execution ],
)

#pagebreak()

== Pipeline Performance Metrics
=== Clocks Per Instruction (CPI)
For pipelined processors, CPI is significantly affected by pipeline characteristics:
- *Ideal Pipeline CPI*: In a perfect $k$-stage pipeline with no hazards: $ "CPI"_"ideal" = 1 $
- *Actual Pipeline CPI*: In real pipelines, CPI includes stall cycles due to hazards: $ "Ave. CPI"_"pipeline" = "CPI"_"ideal" + "Structural stalls" + "Data hazard stalls" + "Control stalls" $


=== Instruction Per Clock Cycle (IPC)
*IPC* measures the instruction throughput of the pipeline:
$ "IPC" = "Instructions executed" / "Clock cycles" = 1 / "CPI" $

=== Pipeline Clock Cycles Calculation
The total number of clock cycles for a pipelined program:
$
  "Total Clock Cycles" = "IC" + "Pipeline depth" - 1 + "Stall cycles"
$

=== MIPS in Pipelined Processors
For pipelined processors, MIPS calculation considers the effective CPI:
$
  "MIPS"_"pipeline" = f_"clock" / ("CPI"_"pipeline" times 10^6)
$

*Peak MIPS* (theoretical maximum with no stalls):
$
  "MIPS"_"peak" = f_"clock" / (1 times 10^6) = f_"clock" / 10^6
$

#example("Speedup of Pipeline")[
  Consider the unpipelined processor in the previous section. Assume that it has a *4 GHz* clock (or a 0.5 ns clock cycle) and that it uses *four cycles* for ALU operations and branches and *five cycles* for memory operations.

  Assume that the relative frequencies of these operations are 40%, 20%, and 40%, respectively.

  Suppose that due to clock skew and setup, *pipelining the processor adds 0.1 ns* of overhead to the clock. Ignoring any latency impact, how much speedup in the instruction execution rate will we gain from a pipeline?


  The average instruction execution time on the unpipelined processor is:
  $
    "Average instruction execution time" =& "Clock cycle" times "Average CPI" \
    =& 0.5 "ns" times [(40%+20%) times 4 + 40% times 5] \
    =& 0.5 "ns" times 4.4 \
    =& 2.2 "ns"
  $
  In the pipelined implementation, the clock must run at the speed of the slowest stage plus overhead, which will be $0.5 + 0.1$ or $0.6 "ns"$; this is the average instruction execution time. Thus, the speedup from pipelining is:
  $
    "Speedup" =& "Unpipelined execution time" / "Pipelined execution time" \
    =& (2.2 "ns") / (0.6 "ns") \
    =& 3.67 "times"
  $
]

#pagebreak()

== Pipeline Hazards
There are situations, called *_hazards_*, that prevent the next instruction in the instruction stream from executing during its designated clock cycle. Hazards reduce the performance from the ideal speedup gained by pipelining. There are *three classes of hazards*.

=== Structural Hazards
*Structural hazards* occur when we attempt to use the same resource from different instructions simultaneously.

The RISC-V architecture avoids *structural hazards* by two key design decisions:
+ *Separate Instruction and Data Memories (_Harvard-Style Architecture_)*: The *fetch stage (IF)* of the pipeline accesses the *Instruction Memory* to read the next instruction. The *memory stage (MEM)* of the pipeline accesses the *Data Memory* to read/write operands. Since the *IM* and *DM* are separate, fetching an instruction and accessing data can happen in parallel without resource competition.
+ *Multiple-Ported Register File Design*: Read ports allow instructions in the decode stage (`ID`) to read operands. Write ports allow instructions in the write-back stage (WB) to update registers. #firebrick[Register file read/write operations can occur in the same clock cycle without conflict.]

=== Data Hazards
If the instructions executed in the pipeline are *dependent to each other*, data hazards can arise when instructions are too close. There are three types of data hazards:
+ *Read After Write (RAW) hazard*: Instruction $n+1$ tries to read a source operand before the previous instruction $n$ has written its value in the Register File.
+ *Write After Read (WAR) hazard*: This hazard occurs when read of register x by instruction $n+1$ occurs after a write of register x by instruction $n$.
+ *Write After Write (WAW) hazard:* This hazard occurs when write of register x by instruction $n+1$ occurs after a write of register x by instruction $n$.

Let's look at a sequence with many dependences, shown in color:
```asm
sub x2, x1, x3   # Register x2 written by sub
and x12, x2, x5  # 1st operand(x2) depends on sub
or  x13, x6, x2  # 2nd operand(x2) depends on sub
add x14, x2, x2  # 1st(x2) & 2nd(x2) depend on sub
sw  x15, 100(x2) # Base (x2) depends on sub
```
The four instructions are all dependent on the result in register `x2` of the first instruction. The @fig:data-hazards-example illustrates the execution of these instructions using a multiple-clock-cycle pipeline representation. The top of @fig:data-hazards-example shows the value ofregister `x2`, which changes during the middle of clock cycle 5, when the `sub` instruction writes its result.

The first hazard in the sequence is on register `x2`, between the result of `sub x2, x1, x3` and the first read operand of and x12, x2, x5. This hazard can be detected when the and instruction is in the `EX` stage and the prior instruction is in the `MEM` stage, so this is hazard 1a:
#nonum($
  "EX/MEM.RegisterRd" = "ID/EX.RegisterRs1"
$)

#definition("Notation of Pipeline Register")[
  A notation that names the fields of the pipeline registers allows for a more precise notation of dependences. For example, "*ID/EX.RegisterRs1*" refers to the number of one register whose value is found in the pipeline register ID/EX;that is, the one from the first read port of the register file. The first part of the name, to the left of the period, is the name of the pipeline register; the second part is the name of the field in that register. Using this notation, the two pairs of hazard conditions are
  - 1a. EX/MEM.RegisterRd = ID/EX.RegisterRs1
  - 1b. EX/MEM.RegisterRd = ID/EX.RegisterRs2
  - 2a. MEM/WB.RegisterRd = ID/EX.RegisterRs1
  - 2b. MEM/WB.RegisterRd = ID/EX.RegisterRs2
]

#figure(
  image("figures/data-hazards-example.jpg", width: 60%),
  caption: "Data Hazards Example",
) <fig:data-hazards-example>

#example("Dependence Detection")[
  The pipeline can be illustrated as:
  #figure(
    image("figures/pipelines-example.jpg", width: 80%),
    caption: "Pipeline Example",
  )
  The `sub-and` instruction pair:
  - Dependence: The value from `x2` is from the `sub` instruction.
  - Timing overlap: When `and` is in `ID` stage(cycle 3), `sub` is in `EX` stage. The `sub` x2 has not been written back to the register (has to wait until the `sub` `WB` stage, cycle 5).
  - Hazards type: 1a. EX/MEM.RegisterRd = ID/EX.RegisterRs1

  The `sub-or` instruction pair:
  - Dependence: The value from `x2` is from the `sub` instruction.
  - Timing overlap: When `or` is in `ID` stage(cycle 4), `sub` is in `MEM` stage. The `sub` x2 has not been written back to the register (has to wait until the `sub` `WB` stage, cycle 5).
  - Hazards type: 2b. MEM/WB.RegisterRd = ID/EX.RegisterRs2

  The `sub-add` instruction pair:
  - Dependence: The two value from `x2` is from the `sub` instruction.
  - Timing overlap: When `add` is in `ID` stage(cycle 5), `sub` is in `WB` stage. The `sub` x2 has been written back to the register.
  - So there is no hazard between `sub` and `add`. Register file read/write operations can occur in the same clock cycle without conflict.

  The `sub-sw` instruction pair:
  - Dependence: The value from `x2` is from the `sub` instruction.
  - Timing overlap: When `sw` is in `ID` stage(cycle 6), `sub` is in `WB` stage. The x2 is stably stored in a register file.
  - So there is no hazard between `sub` and `sw`.
]

The problem posed in @fig:data-hazards-example can be solved with a simple hardware technique called _*forwarding*_.

#figure(
  image("figures/forwarding-pipeline.jpg", width: 80%),
  caption: "Forwarding in a Pipeline",
)

=== Forwarding

If we can take the inputs to the ALU from _any_ pipeline register rather than just `ID/EX`, then we can forward the correct data. By adding multiplexers to the input of the ALU, and with the proper controls, we can run the pipeline at full speed in the presence of these data hazards.

The dependence between the pipeline registers move forward in time, so it is possible to supply the inputs to the ALU needed by the `and` instruction by forwarding the results found in the pipeline registers.

@fig:forwarding-hardware shows close-up of the ALU and pipeline register after adding forwarding. The multiplexers have been expanded to add the forwarding paths, and we show the forwarding unit.

#figure(
  image("figures/forwarding_hardware.jpg", width: 80%),
  caption: "Forwarding Hardware",
) <fig:forwarding-hardware>

There are three forwarding paths:

===== EX/EX Path
The first path is between the ALU output of the `EX` stage and the ALU input of the `EX` stage. This path is used to forward the result of the `sub` instruction to the `and` instruction.

===== MEM/EX Path
Required for load-use hazards, where the loaded value is only available after MEM. For example:
```asm
lw x1, 0(x2)
add x3, x1, x4
```

===== MEM/MEM Path
typically for `load` and `store` instructions.

#figure(
  image("figures/forwarding-path.jpg", width: 80%),
  caption: "Forwarding Unit",
)

== Control Hazards
@fig:branch-hazards-example shows a sequence of instructions and indicates when the branch would occur in this pipeline. The numbers of the left of the instruction are the addresses of the instructions.

#figure(
  image("figures/branch-hazards-example.jpg", width: 80%),
  caption: "Branch Hazards Example",
) <fig:branch-hazards-example>

An instruction must be fetched at every clock cycle to sustain the pipeline, yet in our design the decision about whether to branch doesn't occur until the *MEM* pipeline stage.

Delay in determining the proper instruction to fetch is called a _control hazard_ or _branch hazard_.

=== Assume Branch Not Taken
One improvement over branch stalling is to *predict* that the conditional branch will not be taken and thus continue execution down the sequential instruction stream.
- If the conditional branch *is taken*, the instructions that are being *fetched and decoded must be discarded*. Execution continues at the branch target.
- If conditional branches *are untaken* half the time, and if it costs little to discard the instructions, this optimization halves the cost of control hazards.

Discarding instructions, means we must be able to *flush* instructions in the `IF`, `ID`, and `EX` stages of the pipeline.

#definition("Flush")[
  To discard instructions in a pipeline, usually due to an unexpected event.
]

=== Reducing the Delay of Branches
One way to improve conditional branch performance is to *reduce the cost of the taken branch*. The next PC a brach is selected in the `MEM` stage, but if we move the conditional branch execution earlier in the pipeline, then fewer instructions need be flushed. We can move the branch adder from the `EX` stage to the `ID` stage.
\
*If the branch outcome will be taken*, it will be necessary to:
+ *Flush only one* instructions before writing its results
+ *Fetch next instruction* at the Branch Target Address
It reduces the penalty of a branch to only one instruction if the branch is taken, namely, the one currently being fetched. (*Early evaluation of branch in the `ID` stage*).

To flush instructions in the `IF` stage, we add a control line, called *IF.Flush*, that zeros the instruction field of the `IF/ID` pipeline register. Clearing the register transforms the fetched instruction into a `nop`, an instruction that has *no action and changes no state*.

One stall cycle for every branch will yield a performance loss of 10% to 30% depending on the branch frequency, so we will examine some techniques to deal with this loss.

// #example("Pipelined Branch")[
//   Consider the following sequence of instructions:
//   ```asm
//   36 sub x10, x4, x8
//   40 beq x1, x3, 16   // PC-relative branch to 40+16*2=72
//   44 and x12, x2, x5
//   48 or  x13, x2, x6
//   52 add x14, x4, x2
//   56 sub x15, x6, x7
//   ...
//   72 ld  x4, 50(x7)
//   ```
// ]

#pagebreak()
= Branch Prediction
There are two types of methods to deal with the performance loss due to branch hazards:
+ *Static Branch Prediction Techniques*: The prediction (taken/untaken) for a branch is fixed at *compile time* for each branch during the entire execution of the program.
+ *Dynamic Branch Prediction Techniques*: The prediction (taken/untaken) for a branch can change *at runtime* during the program execution.

#definition("Branch Target Address")[
  The *Branch Target Address* is the address where to branch. If the branch condition is satisfied, the branch is taken and the branch target address is stored in the *Program Counter (PC)*.
]

== Static Branch Prediction
*Static Branch Prediction* is a simple method that assumes the prediction is *fixed* at *compile time* by using some *heuristics* or compiler hints --- rather than considering the runtime execution behavior. It is typically an effective method when the branch behavior for the target application is *highly predictable* at compile time.

=== Branch Always Not Taken
It is the easiest prediction, *we assume the branch will be always not taken*, thus the instruction flow can continue sequentially as if the branch condition was not satisfied. And it is suitable for `IF-THEN-ELSE` conditional statements, when the `THEN` clause is the most probable and the program will continue sequentially.

#figure(
  image("figures/branch-not-taken.jpg", width: 80%),
  caption: "Branch Always Not Taken Prediction",
)

First, we predict the branch not taken at the end of the `IF` stage.
- If the branch outcome at the end of `ID` stage will be not taken $arrow.double.long$ the *prediction was correct* and there is *no branch penalty cycles*.
- If the branch outcome at the end of `ID` stage will be taken $arrow.double.long$ the *prediction was incorrect*. In this case, we need to *flush* the instruction already fetched (it is turned into a `nop`) and need to *fetch* the instruction at the branch target address $arrow.double.long$ *one branch penalty cycle*.

=== Branch Always Taken
Prediction taken at the end of the `IF` stage.
- If the branch outcome at the end of `ID` stage will be taken $arrow.double.long$ *the prediction was correct* $arrow.double.long$ *no branch penalty cycles*.
- If the branch outcome at the end of `ID` stage will be not taken $arrow.double.long$ *misprediction*. In this case, we need to *flush* the instruction already fetched (it is turned into a `nop`) and need to *fetch* the next instruction $arrow.double.long$ *one branch penalty cycle*.

#figure(
  image("figures/branch-always-taken.jpg", width: 80%),
  caption: "Branch Always Taken Prediction",
)

#example("Branch Probability")[
  *Backward-going branches* are mostly *taken*. Example: ranches at the end of `DO-WHILE` loops going back at the beginning of the next iteration.
  \
  *Forward-going branches* are mostly *not taken*. Example: branches of `IF-THEN-ELSE` conditional statements when the conditions associated to the `ELSE` label as less probable.
]

=== Profile-Driven Prediction
We assume to *profile* the behavior of the target application program by several early execution runs by using different data sets. The prediction is based on *profiling information* collected during earlier runs about the branch behavior. For example:
```
T  T  T  T  T  T  T  T  NT NT NT // Taken is the most probable branch outcome
```
The profile-driven prediction method requires a *compiler hint bit* encoded in the branch instruction format by the compiler:
- Set to *1* if *taken* is the most probable branch outcome.
- Set to *0* if *not taken* is the most probable branch outcome.

=== Delayed Branch Technique
Delay branch technology adjusts *instruction order* to reduce pipeline idle cycles and improve efficiency. After the branch instruction, insert one or more delay slots (*_Delay Slot_*). Regardless of whether the branch is taken, the instructions in the delay slots will be executed. The compiler needs to fill the delay slots with useful instructions as much as possible, rather than no-operation (NOP), to avoid pipeline stalls.

#example("Delayed Branch Technique")[
  Let's consider the MIPS compiler schedules a *branch independent instruction* after the branch. A previous *add* instruction with no effects on the branch condition is scheduled in the _*Branch Delay Slot*_ and it is always executed, whether or not the branch will be taken.
  #figure(
    image("figures/delayed-branch-technique.jpg", width: 80%),
    caption: "Example: Delayed Branch Technique",
  )
  *Be careful*: The instruction in the slot must be fine to be executed also when the branch goes in the unexpected direction.
]
The job of the compiler is to find a valid and useful instruction to be scheduled in the branch delay slot. There are four ways to schedule an instruction in the branch delay slot:
+ From before
+ Frome target
+ From fall-through
+ From after

#theorem("Delayed Branch Technique: From Before")[
  The branch delay slot is scheduled with an *independent* instruction from *before the branch*.Then execution will continue based on the Branch Outcome in the right direction and the add instruction in the delay slot will never be flushed.
  #figure(image("figures/from-before-branch.jpg", width: 80%))
]

#theorem("Delayed Branch Technique: From Target")[
  The branch delay slot is scheduled with one instruction from the target of the branch (branch taken). *Drawback*: Usually, the target instruction sub needs to be copied, whenever it can be reached by another path.

  #figure(image("figures/from-target.jpg", width: 80%))

  This strategy is preferred when the branch is taken with high probablity, such as `DO-WHILE` loop branches (*backward branches*).

  If the branch is *untaken*(misprediction), the *sub* instruction in the delay slot needs to be *flushed* or it must be OK to be executed also when the branch goes in the unexpected direction.
]

#theorem("Delayed Branch Technique: From Fall-Through")[
  The branch delay slot is scheduled with one instruction *from the fall-through path (branch not taken)*.

  #figure(image("figures/from-before-branch.jpg", width: 80%))
  This strategy is preferred when the branch is *not taken* with high probability, such as forwarding branches: `IF-THEN-ELSE` statement where the `ELSE` path is less probable.

  If the branch is *taken (misprediction)*, the `or` instruction in the delay slot needs to be *flushed* or it must be OK to be executed also when the branch goes in the unexpected direction.
]

#pagebreak()

== Dynamic Branch Prediction
The basic idea is to use the past branch behavior to predict at runtime the future branch behavior.
- We use the hardware to *_dynamically predict_* the outcome of a branch.
- The prediction will depend on the runtime behavior of the branch.
- The prediction will change at runtime if the branch changes its behavior during execution.

Dynamic branch prediction is based on two interacting hardware blocks:
+ *Branch Outcome Predictor* (BOP) or *Branch Prediction Buffer*: To predict the direction of a branch (Taken or Not Taken).
+ *Branch Target Predictor* or *Branch Target Buffer* (BTB): To predict the branch target address in case of taken branch
They are placed in the *Instruction Fetch stage* to predict the next instruction to read in the Instruction Cache

#figure(
  image("figures/dynamic-branch-prediction.jpg", width: 60%),
  caption: "Dynamic Branch Prediction",
)

=== Branch History Table
One implementation of that approach is a *branch prediction buffer* or *branch history table*. A branch prediction buffer is a small memory indexed by the lower portion of the address of the branch instruction. The memory contains a bit that says whether the branch was recently taken or not.

The behavior is controlled by a *Finite State Machine* with only 1-bit of history (2 states) to remember the last direction taken by the the branch to predict the next branch outcome.

*Finite State Machine* with only 1-bit of history to remember the last direction taken by the branch:
- If the prediction is correct $arrow.double.long$ remains in the current status (and branch prediction outcome)
- If the prediction is not correct $arrow.double.long$ changes the status (and branch prediction outcome)

#figure(image("figures/finite-state-machine.jpg", width: 80%))

Table containing 1 bit for each entry that says whether the branch was recently *taken* or *not taken*. *Table indexed by* the lower portion k-bit of the address of the branch instruction. (For locality reasons, we would expect that the most significant bits of the branch address are not changed.)

The table has *no tags* (every access is a hit) and the prediction bit may have been put there by another branch with the same low-order address bits: but it doesn't matter. The prediction is just a hint!

The misprediction occurs when the prediction is incorrect for that branch.

#figure(
  image("figures/1-bit-branch-history-table.jpg", width: 80%),
  caption: "1-bit Branch History Table",
)

The shortcoming of 1-bit branch history table: *In a loop branch*, a branch is almost always T and then NT once at the exit of the loop. The 1-bit BHT causes 2 mispredictions:
- At the last loop iteration, since the prediction bit is T, while we need to exit from the loop.
- *When we re-enter the loop, at the first iteration we need to take the branch to stay in the loop*, while the prediction bit was flipped to NT on previous execution of the last iteration of the loop.

#example("shortcoming of 1-bit BHT")[
  Assuming the `for loop for (int i = 0; i < 10; i++) `is within the function `foo()`, this loop will run every time `foo()` is called.

  In the first execution:
  #table(
    columns: (auto, auto, auto, auto),
    align: horizon,
    table.header(
      [*Iteration*],
      [*Actual Branch*],
      [*BTH prediction*],
      [*Result*],
    ),

    [1-9], [Taken(T)], [Taken(T)], [✅],
    [10], [Not Taken (NT)], [Taken(T)], [❌],
  )
  If `foo()` is called again, this loop starts again.
  #table(
    columns: (auto, auto, auto, auto),
    align: horizon,
    table.header(
      [*Iteration*],
      [*Actual Branch*],
      [*BTH prediction*],
      [*Result*],
    ),

    [1], [Taken(T)], [Not Taken (NT)], [❌],
    [2-9], [Taken (T)], [Taken(T)], [✅],
    [10], [Not Taken (NT)], [Taken(T)], [❌],
  )
  During the first iteration of the new cycle, BHT is still Not Taken (NT) (because it remembers the exit condition of the last cycle). But in fact, we hope to continue the loop (T), so the prediction of Not Taken (NT) occurred an error, leading to the second false prediction.
]

The solution to this problem is to use a *2-bit branch history table*---The prediction must mispredict twice before it is changed!

#figure(
  image("figures/2-bit-BHT-scheme.jpg", width: 80%),
  caption: "2-bit Branch History Table",
)

=== Branch Target Buffer
*Branch Target Buffer* (Branch Target Predictor) is a cache storing the Predicted Target Address (PTA) for the taken-branch instructions. The PTA is expressed as PC-relative. The BTB is used in combination with the Branch History Table in the *IF stage*.

Usually, it is combined with a *Branch Outcome Predictor* such as a 1-bit (or 2-bit) Branch History Table.

#figure(
  image("figures/branch-target-buffer.jpg", width: 80%),
  caption: "Branch Target Buffer",
)

#example("Dynamic branch prediction of for loop")[
  Let's consider the following `for loop`:
  ```c
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 5; j++) {
      // do something
    }
  }
  ```
  #figure(
    image("figures/dynamic-branch-prediction-for-loop.png", width: 80%),
    caption: "Dynamic Branch Prediction of For Loop",
  )
  For the outer loop1, we have 9 mispredictions. For the inner loop2, we have 1 mispredictions. The total number of mispredictions is $9 + 1 times 10 = 19$.
]

=== Correlating Branch Predictors
The 2-bit BHT uses only the recent behavior of a single branch to predict the future behavior of that branch.

*Basic Idea*: the behavior of recent branches are correlated, that is the recent behavior of *other branches* rather than just the current branch (we are trying to predict) can influence the prediction of the current branch.

We try to exploit the correlation existing among different branches: branches are partially based on the same conditions(they can generate information that can influence the behavior of other branches).

Branch predictors that use the behavior of other branches to make a prediction are called *Correlating Predictors* or *2-level Predictors*.

#figure(
  image("figures/2-level-predictors.jpg", width: 60%),
  caption: "2-level Predictors",
)

Record if the most recently executed branches have been *taken* or *not taken*. The branch is predicted based on the previous executed branch by selecting the appropriate 1-bit BHT:
- One prediction is used if the last branch executed was *taken*
- Another prediction is used if the last branch executed was *not taken*

In general, the last branch executed is not the same instruction as the branch being predicted (although this can occur in simple loops with no other branches in the loops).

#pagebreak()

= Advanced Dynamic Scheduling Techniques
A major *limitation* of simple pipelining techniques is that they use *in-order instruction issue and execution*: instructions are issued in program order, and if an instruction is stalled in the pipeline, no later instructions can proceed.

In the classic five-stage pipeline, both *structural and data hazards* could be checked during instruction decode (`ID`): when an instruction could execute without hazards, it was issued from `ID`, with the recognition that all data hazards had been resolved. Thus, if there is a dependence between two closely spaced instructions in the pipeline, it will lead to a hazard, and a stall will result. For example, consider this code:
```asm
fdiv.d f0,f2,f4
fadd.d f10,f0,f8
fsub.d f12,f8,f14
```
The `fsub.d` instruction cannot execute because the dependence of `fadd.d` on `fdiv.d` causes the pipeline to stall; yet, `fsub.d` is not data-dependent on anything in the pipeline. This hazard creates a performance limitation that can be eliminated by not requiring instructions to execute in program order.

Thus we still use in-order instruction issue (i.e., *instructions issued in program order*), but we want an instruction to begin execution as soon as its data operands are available. Such a pipeline does *out-of-order execution*, which implies out-of-order completion.

== Register Renaming
*_Out-of-order execution_* introduces the possibility of *WAR* and *WAW* hazards, which do not exist in the five-stage integer pipeline and its logical extension to an in-order floating-point pipeline. Consider the following RISC-V floating-point code sequence:
```asm
fdiv.d f0,f2,f4      ; f0 ← f2 / f4
fmul.d f6,f0,f8      ; f6 ← f0 * f8 (RAW)
fadd.d f0,f10,f14    ; f0 ← f10 + f14 (WAW + WAR)
```
Both these hazards are avoided by the use of *_register renaming_*.

== Exception Handling
Out-of-order completion also creates major complications in *handling exceptions*. Dynamic scheduling with out-of-order completion must preserve exception behavior in the sense that exactly those exceptions that would arise if the program were executed in strict program order actually do arise. Dynamically scheduled processors preserve exception behavior by delaying the notification of an associated exception until the processor knows that the instruction should be the next one completed.

Although exception behavior must be preserved, dynamically scheduled processors could generate _*imprecise exceptions*_. An exception is _imprecise_ if the processor state when an exception is raised does not look exactly as if the instructions were executed sequentially in strict program order. Imprecise exceptions can occur because of two possibilities:
+ The pipeline may have _already completed_ instructions that are later in program order than the instruction causing the exception.
+ The pipeline may have _not yet completed_ some instructions that are earlier in program order than the instruction causing the exception.

Imprecise exceptions make it difficult to restart execution after an exception.

To allow out-of-order execution, we essentially split the ID pipe stage of our simple five-stage pipeline into two stages:
+ _Issue_ --- Decode instructions, check for structural hazards.
+ _Read operands_ --- Wait until no data hazards, then read operands.
An *instruction fetch* (`IF`) stage precedes the *issue stage* and may fetch either to an instruction register or into a queue of pending instructions; instructions are then issued from the register or queue.

#pagebreak()

== Scoreboard Dynamic Scheduling Technique
=== Scoreboard basic assumptions
- We consider a *single-issue* processor.
- Instruction Fetch stage fetches and issues instructions in program order (*in-order issue*).
- Instruction execution begins *as soon as operands are ready* whenever not dependent on previous instructions (no *RAW* hazards).
- There are *multiple* pipelined Functional Units with *variable latencies*.
- Execution stage might require *multiple cycles*, depending on the operation type and latency.
- Memory stage might require *multiple cycles* access time due to data cache misses.
- *Out-of-order execution & out-of-order commit*(this introduces the possibility of *WAR & WAW* hazards).

=== Scoreboard Implications
There are multiple instructions in execution phase. Multiple execution units or pipelined execution units. No register renaming, so the Scoreboard must track the status of each instruction and its operands to avoid hazards.

==== Solutions for `WAR`
- Read registers only during Read Operands stage.
- Stall write back until previous registers have been read.

==== Solution for `WAW`:
- Detect `WAW` hazard and stall issue of new instruction until previous instruction causing `WAW` completes.

=== Scoreboard Scheme
Any hazard detection and resolution is _*centralized*_ in the Scoreboard:
- Every instruction goes through the Scoreboard, where a record of data dependences is constructed.
- The Scoreboard then determines when the instruction can read its operand and begin execution (check for `RAW`)
- If the Scoreboard decides the instruction cannot execute immediately, it monitors every change and decides when the instruction can execute.
- The scoreboard controls when the instruction can write its result into destination register (check for `WAR` & `WAW`).

=== Scoreboard Pipeline stages

#figure(
  image("figures/scoreboard-architecture.jpg", width: 80%),
  caption: "Scoreboard Architecture",
)

==== Issue
Decode instruction and check for structural hazards & *WAW hazards*. Instructions issued in program order (for hazard checking).
- If a functional unit for the instruction is available (*no structural hazard*) and no other active instruction has the same destination register (*no WAW hazard*) => the Scoreboard issues the instruction to the FU and updates its data structure.
- If either a *structural hazard* or a *WAW hazard* exists => the instruction issue stalls, and no further instructions will issue until these hazards are solved.

==== Read Operands
Wait until no *RAW hazards*, and then read operands. Check for structural hazards in reading ports of RF.

A source operand is available if:
- No earlier issued active instruction will write it or
- A functional unit is writing its value in a register

When the source operands are available, the Scoreboard tells the FU to proceed to read the operands from the RF and begin execution.

`RAW` hazards are solved dynamically in this step:
- out-of-order reading of operands
- instructions are sent into execution out-of-order.

==== Execution
The FU begins execution upon receiving operands. When the result is ready, it notifies the Scoreboard that execution has been completed.

- FUs are characterized by variable latency to complete execution.
- Load/Store latency depends on data cache HIT/MISS times.

==== Write result
Check for *WAR hazards* on destination. Check for *structural hazards* in writing RF and finish execution.

Once the Scoreboard is aware that the FU has completed execution, *the Scoreboard checks for WAR hazards*.
- If none, it writes results.
- If there is a *WAR*, the Scoreboard stalls the completing instruction.

#example("RAW/WAR/WAW")[
  ```asm
  DIVD F0, F2, F4
  ADDD F6, F0, F8   // RAW F0
  SUBD F8, F8, F14  // WAR F8
  MULD F6, F10, F8  // WAW F6
  ```

  - To avoid the *WAR* hazard on F8, the Scoreboard would: Stall *SUBD* in the WB stage, waiting for *ADDD* reads F0 and F8;
  - To avoid the *WAW* hazard on F6, the Scoreboard would: Stall *MULD* in the ISSUE stage until *ADDD* writes F6.

  Note: Any `WAR/WAW` hazard could have been solved through register renaming at compile time.
]

=== Instruction Status

#figure(
  image("figures/instruction-status.jpg", width: 80%),
  caption: "Instruction Status",
)

=== Functional unit status
state of the functional unit:
- *Busy*: indicates whether the unit is busy or not.
- *Op*: operation to perform in the unit.
- *$F_i$*: destination register
- *$F_j, F_k$*: source registers
- *$Q_j, Q_k$*: functional units producing $F_j, F_k$
- *$R_j, R_k$*: flags indicating when $F_j, F_k$ are ready and not yet read. Set to NO after operands are read.

#figure(
  image("figures/functional-unit-status.jpg", width: 80%),
  caption: "Functional Unit Status",
)

=== Register result status

#figure(
  image("figures/register-result-status.jpg", width: 80%),
  caption: "Register Result Status",
)

#pagebreak()

== Tomasulo Dynamic Scheduling Technique
_Tomasulo Algorithm_, invented by Robert Tomasulo, tracks when operands for instructions are available to minimize *RAW hazards* and introduces *register renaming* in hardware to minimize *WAW and WAR hazards*.

Although there are many variations of this scheme in recent processors, they all rely on two key principles:
- dynamically determining when an instruction is ready to execute.

To better understand how *_register renaming_* eliminates `WAR` and `WAW` hazards, consider the following example code sequence that includes potential `WAR` and `WAW` hazards:
```asm
fdiv.d f0,f2,f4
fadd.d f6,f0,f8
fsd f6,0(x1)
fsub.d f8,f10,f14  // WAR f8
fmul.d f6,f10,f8   // WAR f6, WAW f6
```
These three _name dependences_ can all be eliminated by *register renaming*. For simplicity, assume the existence of two temporary registers, `S` and `T`. Using `S` and `T`, the sequence can be rewritten without any dependences as
```asm
fdiv.d f0,f2,f4
fadd.d S,f0,f8
fsd S,0(x1)
fsub.d T,f10,f14
fmul.d f6,f10,T
```

=== Reservation Station
In Tomasulo's scheme, _register renaming_ is provided by _*reservation stations*_, which buffer the operands of instructions waiting to issue and are associated with the functional units.
- *Busy*: Indicates reservation station is busy.
- *Op*: Operation to perform in the unit.
- *$V_j$, $V_k$*: Value of source operands.
- *$Q_j$, $Q_k$*: Pointers to reservation stations producing source registers, if $Q_j, Q_k=0$, the operand ready.

=== Register File and Store Buffers
Each entry in the RF and in the Store buffers have a Value ($V_i$) and a Pointer ($Q_i$) field.
- The *Value* ($V_i$) field holds the register/buffer content;
- The *Pointer* ($Q_i$) field corresponds to the number of the RS producing the result to be stored in this register
- If the pointer is zero means that the value is available in the register/buffer content (no active instruction is computing the result);

=== Load/Store Buffers
Load/Store buffers have *Busy and Address field*. To hold info for memory address calculation for load/stores, the address field initially contains the instruction offset (immediate field); after address calculation, it stores the effective address. *They behave almost like reservation stations*.

=== Stages of Tomasulo Algorithm
==== Issue
- *Fetch instruction* from the instruction queue (FIFO), maintaining correct data flow.
- Check for *structural hazards* (if no RS is available, the instruction stalls).
- If the operand is in a register, obtain the value directly; If it is not ready, record the source of its producer.
- Put the instruction with operands or operands source into a reservation station (RS) associated with the required functional unit (FU).

Instructions are fetched from the head of a *FIFO queue*, ensuring they are issued in program order. This maintains in-order issue even if execution is out-of-order.

Each instruction requires an available RS. If none are free, the instruction stalls, preventing structural hazards due to limited hardware resources.

*Operand Readiness & Register Renaming (Q Pointers):*
- If operands are in the Register File (RF), they are read directly.
- If operands are not ready, the RS tracks the Functional Unit (FU) that will produce them via $Q$ pointers.

*WAR Hazard Resolution:* If instruction I writes to register Rx, any earlier-issued instruction K that reads Rx has either:
- Already read the value from RF, or
- Tracked the correct producer FU via Q pointers.

*WAW Hazard Resolution:* In-order issue ensures that if two instructions write to the same register, the later-issued instruction updates the RF's Q pointer to its own FU. Even if the earlier write completes later, the RF only commits the result from the last-issued (program-order) write, preventing *WAW hazards*.

==== Execution
+ *Operand Readiness Check (RAW Hazard Resolution)*:
  - An instruction begins execution only when both operands are ready (values available in Reservation Station (RS) or forwarded via Common Data Bus (CDB)).
  - *RAW hazards are resolved dynamically*: Execution is delayed until source operands are produced by prior instructions, ensuring no RAW hazards at this stage.
+ *Functional Unit (FU) Availability Check (Structural Hazard)*:
  - Even if operands are ready, execution proceeds only if the required FU is free.
  - If the FU is busy, the instruction stalls, avoiding structural hazards due to FU contention.
+ *Monitoring the Common Data Bus (CDB)*:
  - If operands are not ready, the RS tracks the CDB for incoming results from other FUs.
  - When a result matching the required operand's producer tag (Q pointer) appears on the CDB, the operand is captured and marked as ready.
+ *Handling Multiple Ready Instructions*:
  - If multiple instructions targeting the same FU become ready in the same cycle: For `Loads/Stores`, must execute in program order to preserve memory consistency; For Arithmetic/Logical Operations, Can execute out-of-order if the FU supports it.
  - The scheduler typically prioritizes older (earlier-issued) instructions to maintain fairness or program order where required.
+ *RAW Hazard Shortening via Forwarding*:
  - Operands are sourced *directly from the RS/CDB*, bypassing the Register File (RF). This mimics forwarding, eliminating the wait for RF write-back and reducing RAW resolution latency.
+ *Execution Completion & CDB Broadcast*:
  - Once execution finishes, the result is *broadcast to all RS entries and the RF via the CDB*.
  - RS entries waiting on this result update their operands, enabling dependent instructions to proceed.

==== Write result
When result is available, write it on Common Data Bus and from there into Register File and into all RSs (including store buffers) waiting for this result; Stores also write data to memory unit during this stage (when memory address and result data are available); Mark reservation station available.

#pagebreak()

== Hardware-Based Speculation
We introduce the concept of HW-based speculation, which extends the ideas of dynamic scheduling beyond branches.

HW-based speculation combines *3 key concepts*:
+ *Dynamic branch prediction*;
+ *Speculation* to enable the execution of instructions before the branches are solved by undoing the effects of mispredictions;
+ *Dynamic scheduling* beyond branches.
#figure(
  image("figures/ROB-structure.jpg", width: 80%),
  caption: "The basic structure of a FP unit using Tomasulo's algorithm and extended to handle speculation",
)

=== Reorder Buffer
To support *HW-based speculation*, we need to enable the execution of instructions *before* the control dependencies are solved. In case of mispredictions, we need to undo the effects of an incorrectly speculated sequence of instructions.

Therefore, we need to separate the process of execution completion from the commit of the instruction result in the RF or in memory.

*Solution*: We need to introduce an HW buffer, called *Reorder Buffer (ROB)*, called *ReOrderBuffer*, to hold the result of an instruction that has finished execution, but not yet committed in RF/memory.

ReOrder Buffer has been introduced to support *out-of-order execution but in-order commit*. Buffer to hold the results of instructions that have finished execution *but not yet committed*. Buffer to pass results among instructions that have started *speculatively* after a branch.

The *ROB* is also used to pass results among dependent instructions to start execution as soon as possible $arrow$ The renaming function of *Reservation Stations* is replaced by ROB entries.

Use *ReOrder Buffer numbers* instead of reservation station numbers as pointers to pass data between dependent instructions. Reservation Stations now are used only to buffer instructions and operands to FUs (to reduce structural hazards).

=== Speculative Tomasulo
==== Issue
+ *Get instruction* from instruction queue
+ Check if there is an available RS and ROB entry. If either RS or ROB is full, the instruction *stalls*.
+ *Resource Allocation*.
  - For RS: Mark the selected RS as occupied, and load the instruction opcode and operands information.
  - For ROB: Allocate a free entry, and generate a unique ROB ID (e.g., `ROB#5`). Record instruction info (destination register, status, etc.).
+ *Operand Fetch*: ROB Entry is high priority, which contains the least uncommit result.

If its operands available in RF or in ROB, they are sent to RS; Number of ROB entry allocated for result is sent to RSs (to tag the result when it will be placed on the CDB). *If RS full or/and ROB full: instruction stalls.*

==== Execution started
Start and execute on operands (EX). When both operands are ready in the RS (RAW solved), start to execute. If one or more operands are not yet ready, check for RAW solved by monitoring CDB for result. For a *store*, only base register needs to be available (at this point, only effective address is computed)

==== Execution completed & Write result in ROB
Write result on Common Data Bus to all awaiting FUs & to ROB value field; mark RS as available. For a store: the value to be stored is written in the ROB value field; otherwise monitor CDB until value is broadcast.

==== Commit
Update RF or memory with ROB result. When instr. at the head of ROB & result ready, update RF with result (or store to memory) and remove instruction from ROB entry. Mispredicted branch flushes ROB entries (sometimes called "graduation")

There are three different possible sequences:
+ *Normal commit*: instruction reaches the head of the ROB, result is present in the buffer. Result is stored in the Register File, instruction is removed from ROB;
+ *Store commit*: as above, but result is stored in memory rather than in the RF;
+ Instruction is a mispredicted branch, speculation was wrong, ROB is flushed (“graduation”) and execution restarts at correct successor of the branch.

#pagebreak()

= Very Long Instruction Word (VLIW)
== Multiple Issue Processors
For *single-issue processors*, scalar processors that fetch and issue max one operation at each clock cycle.

The *multiple-issue processors* require:
- *To fetch* multiple instructions in a cycle (higher bandwidth
from the instruction cache)
- *To issue* multiple instructions based on:
  - *Dynamic scheduling*: The hardware issues at runtime a varying number of instructions at each clock cycle.
  - *Static scheduling*: The compiler issues statically a fixed number of instructions at each clock cycle.

== VLIW Architecture
=== VLIW Processors
The following is a example of a VLIW processor, The long instruction (*bundle*) has a fixed set of operations (*slots*). A *5-issue* VLIW has a long instruction (bundle) to contain up to *5 operations* corresponding to *5 slots*.

#figure(
  image("figures/VLIW-processor.jpg", width: 80%),
  caption: "Example of a VLIW Processor",
)

The *single-issue packet (bundle)* represents a wide instruction with multiple independent operations (or *syllables*) per instruction. The *compiler* identifies statically the multiple independent operations to be executed in parallel by the multiple Functional Units. The compiler solves statically the *structural hazards* for the use of HW resources and the *data hazards*, otherwise the compiler inserts `NOP`s.

The VLIW architecture has the following assumptions:
- There is a *single PC* to fetch a long instruction (bundle).
- *Only one branch for each bundle* to modify the control flow.
- *There is a shared Multi-ported Register File*: If the bundle has 4 slots, we need $2 times 4$ read ports and 4 write ports to read 8 source registers per cycle and to write 4 destination registers per cycle.
- To keep busy the FUs, there must be enough parallelism in the source code to fill in the available 4 operation slots. Otherwise, `NOP`s are inserted.
- If each slot is assigned to a Functional Unit, the decode unit is a simple decoder and each op is passed to the corresponding FU to be executed.
- *If there are more parallel FUs than the number of issues (slots)*, the architecture must have a *dispatch network* to redirect each op and the related source operands to the target FU.

#figure(
  image("figures/5-stages-pipeline-VLIW.jpg", width: 80%),
  caption: "5 Stages Pipeline VLIW",
)

== VLIW Code Scheduling
The main goal is statically reordering instructions in object code so that they are executed in a minimum amount of time and semantically correct order.
- Execute time-critical operations efficiently.
- Try to increase the number of independent instructions fetched.

=== Dependencies Graph
A *dependence graph* captures true, anti and output dependencies between instructions. Anti and output dependencies are name dependencies due to variables/registers reuse.

#figure(
  image("figures/dependence-graph.jpg", width: 80%),
  caption: "Dependence Graph",
)

== Software Pipelining

#pagebreak()

= Advanced Memory Hierarchy
== Introduction to caches
We continue our introduction to caches by answering the four common questions
for the first level of the memory hierarchy:
- Q1: Where can a block be placed in the upper level? (*block placement*)
- Q2: How is a block found if it is in the upper level? (*block identification*)
- Q3: Which block should be replaced on a miss? (*block replacement*)
- Q4: What happens on a write? (*write strategy*)
#definition("Temporal Locality")[
  When there is a reference to one memory element, the trend is to refer again to the same memory element soon (i.e., instruction and data reused in loop bodies)
]

#definition("Spatial Locality")[
  When there is a reference to one memory element, the trend is to refer soon at other memory elements whose addresses are close by (i.e., sequence of instructions or accesses to data organized as arrays or matrices)
]

Caches exploit both types of predictability:
- Exploit *temporal locality* by keeping the contents of recently accessed memory locations.
- Exploit *spatial locality* by fetching blocks of data around recently accessed memory locations.

#pagebreak()

== Basic Concepts
- In general, the memory hierarchy is composed of several levels.
- Let us consider 2 levels: cache and main memory
- The cache (_upper level_) is smaller, faster and more expensive than the main memory (_lower level_).
- The minimum chunk of data that can be copied in the cache is the *block* or *cache line*.
- To exploit the spatial locality, the block size must be a multiple of the word size in memory, example: 128-bit block size = 4 words of 32-bit
- The number of blocks in cache is given by: *Number of cache blocks = Cache Size / Block Size*

=== Cache Hit and Miss
If the requested data is found in one of the cache blocks (upper level), there is a hit in the cache access.

If the requested data is not found in in one of the cache blocks (upper level), there is a miss in the cache access, to find the block, we need to access the lower level of the memory hierarchy

In the case of a data miss, we need to:
- To stall the CPU
- To require to block from the main memory
- To copy (write) the block in cache
- To repeat the cache access (hit)

Three major categories of cache misses:

==== Compulsory Miss
The first access to a block is not in the cache, so the block must be loaded in the cache from the main memory. Also called _cold start miss_ or _first reference miss_. There are compulsory misses even in an infinite cache: they are independent of the cache size.

==== Capacity Miss
If the cache cannot contain all the blocks needed during execution of a program, *_capacity misses_* will occur due to blocks being replaced and later retrieved. *Capacity misses decrease as capacity increases*.

==== Conflict Miss
If the block-placement strategy is *_set associative_* or _*direct mapped*_, *conflict misses* will occur because a block can be replaced and later retrieved when other blocks map to the same location in the cache.

Conflict misses decrease as associativity increases. By definition, full associative caches avoid all conflict misses, but they are consuming area.

=== Cache Structure
Each entry (cache line) in the cache includes:
- *Valid bit* to indicate if this position contains valid data or not. At the bootstrap, all the entries in the cache are marked as `INVALID`
- *Cache Tag(s)* contains the value that unique identifies the memory address corresponding to the stored data.
- *Cache Data* contains a copy of data (block or cache line)

#figure(
  image("figures/cache-structure.jpg", width: 60%),
  caption: "Cache Structure",
)

#pagebreak()

== Cache Placement
There are three categories of cache organization:
- If each block has only one place it can appear in the cache, the cache is said to be _*direct mapped*_. The mapping is usually #align(center)[(Block address) MOD (Number of blocks in cache)]
- If a block can be placed anywhere in the cache, the cache is said to be _*fully associative*_.
- If a block can be placed in a restricted set of places in the cache, the cache is *_set associative_*. A set is a group of blocks in the cache. A block is first mapped onto a set, and then the block can be placed anywhere within that set. The set is usually chosen by _bit selection_; that is, #align(center)[(Block address) MOD (Number of sets in cache)]

#figure(
  image("figures/cache-placement.jpg", width: 80%),
  caption: "Cache Placement",
)

#pagebreak()

== Cache Identification
The processor address is cleverly divided into three parts:
+ _*Tag Field*_: Used for comparison to determine if there's a cache hit
+ *_Index Field_*: Selects which cache set to look in
+ *_Block Offset_*: Selects the specific data within the found block

For *Direct Mapped Cache*, each memory location corresponds to one and only one cache location. The cache address of the block is given by:
$
  "(Block Address) cache = (Block Address)mem mod (Num. of Cache Blocks)"
$

#figure(
  image("figures/direct-mapped-cache.jpg", width: 60%),
  caption: "Direct Mapped Cache",
)

For *Fully Associative Cache*, the memory block can be placed in any position of the cache, all the cache blocks must be checked during the search of the block. The index does not exist in the memory address, there are the tag bits only

#figure(
  image("figures/fully-associative-cache.jpg", width: 60%),
  caption: "Fully Associative Cache",
)

For *n-way set associative cache*, Cache composed of sets, each set composed of n blocks: Number of sets = Cache Size / (Block Size $times$ n)

#pagebreak()

== Cache Replacement
When a cache miss occurs, the cache must decide which block to replace. The replacement policy is crucial for cache performance. Common policies include:
- *_Random_*: To spread allocation uniformly, candidate blocks are randomly selected.
- *_Least recently used (LRU)_*: The block that has not been used for the longest time is replaced.
- _*First in, first out (FIFO)*_: Because LRU can be complicated to calculate, this approximates LRU by determining the oldest block rather than the LRU.

== Cache Write Policy
There are two policies to write data in the cache:
- *Write-Through*: the information is written to both the block in the cache and to the block in the lower-level memory
- *Write-Back*: the information is written only to the block in cache. The modified cache block is written to the lower-level memory *only when it is replaced due to a miss*.

These are cache allocation policies that determine what happens when a write miss occurs (i.e., when the CPU tries to write to a memory location that is not currently in the cache).
- *Write Allocate*: When a write miss occurs, the cache block is allocated in the cache, and the data is written to the cache block. *This is often used with write-back caches*.
- *No Write Allocate*: When a write miss occurs, the data is written directly to the lower-level memory without allocating a cache block. *This is often used with write-through caches*.

#example("cache structures")[
  Let us consider a memory hierarchy (main memory + cache) given by:
  - Memory size 1 Giga words of 16 bit (word addressed);
  - Cache size 1 Mega words of 16 bit (word addressed);
  - Cache block size 256 words of 16 bit.

  1. Calculate the number of cache blocks:
  $
    "cache blocks" = "cache size" / "block size" = (1 M) / 256 = 4096
  $
  2. Calculate the structure of the addresses for the following cache structures:
  - *Direct Mapped Cache*: The block size is 256 words, so the offset is 8 bits ($256 = 2^8$). The number of cache blocks is 4096, so the index is 12 bits ($4096 = 2^12$). The tag is 30 - 12 - 8 = 10 bits.
  - *Fully Associative Cache*: The block size is 256 words, so the offset is 8 bits ($256 = 2^8$). The number of cache blocks is 4096, so the index is 0 bits. The tag is 30 - 8 = 22 bits.
  - *2-way Set-Associative Cache*: The number of sets is $4096 / 2=2048$, so the index is 11 bits ($2048 = 2^11$). The block size is 256 words, so the offset is 8 bits ($256 = 2^8$). The tag is 30 - 11 - 8 = 11 bits.
]

#pagebreak()

= Loop Unrolling
To keep a pipeline full, parallelism among instructions must be exploited by finding sequences of unrelated instructions that can be overlapped in the pipeline. Consider a simple loop:
```c
for (i=999; i>=0; i=i-1)
  x[i] = x[i] + s;
```
We can see that this loop is parallel by noticing that the body of each iteration is *independent*. The straightforward RISC-V code, not scheduled for the pipeline, looks like this:
```asm
Loop: fld f0,0(x1)    //f0=array element
      fadd.d f4,f0,f2 //add scalar in f2
      fsd f4,0(x1)    //store result
      addi x1,x1,-8   //decrement pointer
      bne x1,x2,Loop  //branch x1 not equal x2
```

A simple scheme for increasing the number of instructions relative to the branch and overhead instructions is _loop unrolling_. Unrolling simply replicates the loop body multiple times, adjusting the loop termination code.

+ Determine that unrolling the loop would be useful by finding that the loop iterations were *independent*, except for the loop maintenance code.
+ Use different registers to avoid unnecessary constraints that would be forced by using the same registers for different computations (e.g., name dependences).
+ Eliminate the extra test and branch instructions and adjust the loop termination and iteration code.
+ Determine that the loads and stores in the unrolled loop can be interchanged by observing that the loads and stores from different iterations are independent. This transformation requires analyzing the memory addresses and finding that they do not refer to the same address.
+ Schedule the code, preserving any dependences needed to yield the same result as the original code.

*Pros*:
- *Loop overhead* (number of counter increments and branches per loop) is minimized.
- Loop unrolling extends the length of the basic block, the loop exposes more instructions that can be effectively scheduled to minimize `NOP` insertions.
\
*Cons*:
- Loop unrolling increases the *register pressure* (number of allocated registers) due to the need of register renaming to avoid name dependencies.
- Loop unrolling increases the *code size and instruction cache misses*.

*Loop-level analysis* involves determining what data dependences exist among the operands across the iterations of a loop.

*Loop-carried dependence*: Whether data accesses in later iterations are dependent on data values produced in earlier iterations.

#pagebreak()

= software pipelining

#pagebreak()

= Multithreading
_*Multithreading*_ allows multiple threads to share the functional units of a single processor in an overlapping fashion. In contrast, a more general method to exploit _*thread-level parallelism (TLP)*_ is with a multiprocessor that has multiple independent threads operating at once and in parallel. Multithreading, however, does not duplicate the entire processor as a multiprocessor does. Instead, multithreading shares most of the processor core among a set of threads, duplicating only private state, such as the registers and program counter.

There are three main hardware approaches to multithreading: _fine-grained_, _coarse-grained_, and _simultaneous_.

== Fine-grained Multithreading
Fine-grained MT switches between threads on each instruction, execution of multiple thread is interleaved in a round-robin fashion, skipping any thread that is stalled at time eliminating fully empty slots.
- The processor must be able to switch threads on every cycle.
- It can *hide both short and long stalls*, since instructions from other threads are executed when one thread stalls.
- It slows down the execution of individual threads, since a thread that is ready to execute without stalls will be delayed by another threads.
- Within each clock, ILP limitations still lead to empty issue slots

== Coarse-grained Multithreading
Coarse-grained multithreading was invented as an alternative to fine-grained multithreading. Coarse-grained multithreading switches threads only on costly stalls, such as level two or three cache misses. This reduces the number of idle cycles, but:
- Within each clock, ILP limitations still lead to empty issue slots.
- When there is one stall, it is necessary to empty the pipeline before starting the new thread;
- The new thread has a pipeline start-up period with some idle cycles remaining and loss of throughput
- Because of this *start-up overhead*, coarse-grained MT is better for reducing penalty of high-cost stalls, where pipeline refill << stall time

== Simultaneous Multithreading (SMT)
The most common implementation of multithreading is called _*simultaneous multithreading (SMT)*_. Simultaneous multithreading is a variation on fine-grained multithreading that arises naturally when fine-grained multithreading is implemented on top of a *multiple-issue*, *dynamically scheduled processor*.

As with other forms of multithreading, SMT uses thread-level parallelism to hide long-latency events in a processor, thereby increasing the usage of the functional units. The key insight in SMT is that register renaming and dynamic scheduling allow multiple instructions from independent threads to be executed without regard to the dependences among them; the resolution of the dependences can be handled by the *dynamic scheduling capability*.

#pagebreak()

= Performance Evaluation
== Clock cycle
- $T_"CLK"$ = Period or clock cycle time [seconds]
- $f_"CLK"$ s= Clock frequency = Clock cycles per second

The relationship between the two is:
$
  f_"CLK" = 1 / T_"CLK"
$

Examples:
- $f_"CLK"$ = 500 MHz corresponds to $T_"CLK" = 1 / (500 * 10^6) = 2 "ns"$
- $f_"CLK"$ = 1 GHz corresponds to $T_"CLK" = 1 / (1 * 10^9) = 1 "ns"$

== CPU time
$
  "CPU time" = "Clock cycles" * T_"CLK" = "Clock cycles" / f_"CLK"
$
To optimize performance means to reduce the execution time (or CPU time):
- Reduce the number of clock cycles per program
- Reduce the clock period $T_"CLK"$
- To increase the clock frequency $f_"CLK"$

The CPU time can also be represented as:
$
  "CPU time" = "Instruction count" times "CPI" times T_"CLK"
$
where Clock Per Instruction is given by:
$
  "CPI" = "Clock cycles" / "Instruction count"
$

#example("CPU time")[
  #figure(image("figures/CPU-time-example.jpg", width: 60%))
  Evaluate the CPI and the CPU time to execute a program composed of 100 instructions mixed as in the table by using 500 MHz clock frequency:
  $
    "CPI" = 0.43 * 1 + 0.21 * 4 + 0.12 * 4 + 0.12 * 2 + 0.12 * 2 = 2.23
  $
  $
    "CPU time" = "Instruction count" * "CPI" * T_"CLK" = 100 * 2.23 * 2 "ns" = 446 "ns"
  $
]

*MIPS (Million Instructions Per Second)* is a measure used to gauge the speed of a computer processor in executing instructions, indicating how many million machine instructions it can execute per second:
$
  "MIPS" = "Instruction count" / ("CPU time" times 10^6) = f_"CLK" / ("CPI" times 10^6)
$

== Performance Issues in Pipelining
Pipelining increases the CPU instruction *throughput* (number of instructions completed per unit of time), but it does not reduce the execution time (latency) of a single instruction.

- IC = Instruction Count
- CPI = Clocks Per Instruction
- IPC = Instructions Per Cycle = 1 / CPI
- Clock Cycles = IC + Stalls + 4
- CPI = Clock cycles / IC
- MIPS = $"IC" / ("CPU time" times 10^6)$ = $f_"CLK" / ("CPI" times 10^6)$

== Performance evaluation of the memory hierarchy
In a stack of memories, the one on the lowest level is the slowest one (likely it is also the biggest, e.g., hard disk), while the one on the highest level (the topmost) is the fastest one (and also the smallest, e.g., a L1 cache, or a CPU register)
- *Hit*: data found in a block of the upper level
- *Hit Rate*: Number of memory accesses finding data in the upper level memory with respect to the total number of memory accesses:
$
  "Hit Rate" = "Number of hits" / "Total number of accesses"
$
- *Hit time*: time to access the data in the upper level of the hierarchy, including the time needed to decide if the attempt of access will result in a hit or miss
- *Miss*: the data must be taken from the lower level
- *Miss Rate*: number of memory accesses not finding data in the upper level with respect to the total number of memory accesses:
$
  "Miss Rate" = "Number of misses" / "Total number of accesses"
$
- By definition: Hit Rate + Miss Rate = 1
- *Miss Time = Hit Time + Miss Penalty*(Miss Penalty is the time needed to access the lower level and to replace the block in the upper level) Hit time << Miss Penalty

$
  "AMAT" = "Hit Rate" times "Hit Time" + "Miss Rate" times "Miss Time"
$
$
  "AMAT" = "Hit Rate" times "Hit Time" + "Miss Rate" times ("Hit Time" + "Miss Penalty")
$
$
  "AMAT" = ("Hit Rate" + "Miss Rate") times "Hit Time" + "Miss Rate" times "Miss Penalty"
$
$
  "AMAT" = "Hit Time" + "Miss Rate" times "Miss Penalty"
$

To improve cache performance:
- Reduce the hit time
- Reduce the miss rate
- Reduce the miss penalty

For separate I\$ & D\$ (Harvard architecture):
$
  "AMAT"_("harvard") =& \%"Instr". ("Hit Time" + "Miss Rate" I\$ \* "Miss Penalty") \
  +& \%"Data" ("Hit Time" + "Miss Rate" D\$ \* "Miss Penalty")
$
Usually: Miss Rate I $<<$ Miss Rate D

=== Local and global miss rates
#definition("Local miss rate")[
  misses in this cache divided by the total number of memory accesses to this cache: the Miss $"rate"_"L1"$ for L1 and the Miss $"rate"_"L2"$ for L2
]

#definition("Global miss rate")[
  misses in this cache divided by the total number of memory accesses generated by the CPU:
  - For L1, the global miss rate is still just $"Miss Rate"_"L1"$
  - For L2, it is $"Miss Rate"_"L1" times "Miss Rate"_"L2"$
]

#pagebreak()

= Multiprocessors
Multiprocessors now play a major role from embedded to high end general-purpose computing. The main goal of Multiprocessors is to achieve *high-end performance, scalability, and reliability*.

Multiprocessors refers to tightly coupled processors whose coordination and usage is controlled by a single operating system and that usually share memory through a shared address space.

Existing *shared-memory multiprocessors* fall into *two classes*, depending on the number of processors involved, which in turn dictates a memory organization and interconnect strategy.

The first group, which we call *_symmetric (shared-memory) multiprocessors (SMPs)_*, or *_centralized shared-memory multiprocessors_*, features small to moderate numbers of cores, typically 32 or fewer.

SMP architectures are also sometimes called _*uniform memory access (UMA)*_ multiprocessors, arising from the fact that all processors have a uniform latency from memory, even if the memory is organized into multiple banks.

#figure(
  image("figures/SMP.jpg", width: 80%),
  caption: "Basic structure of a centralized shared-memory multiprocessor based on a multicore chip.",
)

The alternative design approach consists of multiprocessors with physically distributed memory, called _*distributed shared memory (DSM)*_.

Distributing the memory among the nodes both increases the bandwidth and reduces the latency to local memory. A DSM multiprocessor is also called a _*NUMA (nonuniform memory access)*_ because the access time depends on the location of a data word in memory.

#figure(
  image("figures/DSM.jpg", width: 80%),
  caption: "The basic architecture of a distributed-memory multiprocessor",
)

*In both SMP and DSM architectures, communication among threads occurs through a shared address space, meaning that a memory reference can be made by any processor to any memory location, assuming it has the correct access rights*. The term shared memory associated with both SMP and DSM refers to the fact that the address space is shared.

#pagebreak()

== The connection network topologies
Processors in a multiprocessor system need to be interconnected to facilitate communication and data sharing.

=== Network Representation and Costs
Networks are represented as graphs where:
- *Nodes* (shown as black square) are processor-memory nodes
- *Switch* (shown as red circle) whose links go to processor-memory nodes and to other switches
- *Arcs* representing a link of the communication network (all links are bidirectional), which means information can flow in either direction.

Network costs include:
- Number of switches
- Number of links on a switch to connect to the network
- Width (number of bits) per link
- Length of links when the network is mapped to a physical machine

=== Network Performance Metrics
Let us consider how to measure the performance of a network, we define:
$
  P &= "Number of nodes" \
  M &= "Number of links" \
  b &= "Bandwidth of a single link" \
$
- *Total Network Bandwidth* (best case): $M times b$, number of links multiplied by the bandwidth of each link
- *Bisection Bandwidth* (worst case): This is calculated by dividing the machine into two parts, each with half the nodes. Then you sum up the bandwidth of the links that cross that imaginary dividing line.

=== Single Bus
*Single-bus* approach imposes constraints on the number of processors connected to it (up to now, 36 is the largest number of processors connected in a commercial single bus system), which is limited by the bus bandwidth and easy to reach saturation.

In *Single-Bus Multiprocessors*,the connection medium (the bus)is between the processors and memory, and the medium is used on every memory access.

#figure(
  image("figures/single-bus.jpg", width: 80%),
  caption: "Single Bus Multiprocessor",
)

#figure(
  image("figures/single-bus-topology.jpg", width: 80%),
  caption: "The topology of a single bus multiprocessor",
)

For single-bus topology, we calculate the metrics of performance:
- *Total Network Bandwidth*: $1 times b = b$
- *Bisection Bandwidth*: $1 times b = b$

=== Ring
Nodes are connected in a closed loop. It is capable of many simultaneous transfers. Some nodes are not directly connected, the communication between some nodes needs to pass through intermediate nodes to reach the final destination (multiple-hops).

For single-bus topology, we calculate the metrics of performance:
- *Total Network Bandwidth*: $P times b$
- *Bisection Bandwidth*: $2 times b$

#figure(
  image("figures/ring-topology.jpg", width: 80%),
  caption: "The topology of a ring multiprocessor",
)

=== Crossbar Network
Crossbar Network or fully connected network: every processor has a bidirectional dedicated communication link to every other processor, and it has a very high cost.

#figure(
  image("figures/crossbar-topology.jpg", width: 80%),
  caption: "The topology of a crossbar multiprocessor",
)

+ *Total Bandwidth*: $(P times (P - 1)) / 2 times b$
+ *Bisection Bandwidth*: $(P / 2)^2 times b$

=== Bidimensional Mesh
Given $P$ nodes: $N=sqrt(P)$, there are $N times (N - 1)$ *horizontal channels* and $N times (N - 1)$ *vertical channels*.
- Number of links per internal switch $=5$
- Number of links per external switch $=3$
- *Total Bandwidth*: $2 times N times (N - 1) times b$
- *Bisection Bandwidth*: $N times b$

#figure(
  image("figures/bidimensional-mesh-topology.jpg", width: 60%),
  caption: "The topology of a bidimensional mesh multiprocessor",
)

#pagebreak()

== Memory Address Space
There are two types of memory address space model:
- *Single logically shared address space (symmetric multiprocessors)*: A memory reference can be made by any processor to any memory location through loads/stores, it is also known as *shared memory architecture*. The address space is shared among processors: The same physical address on 2 processors refers to the same location in memory.
- *Multiple and private address spaces*: The processors communicate among them through send/receive primitives, it is also known as *message passing architecture*. The address space is logically disjoint and cannot be addressed by different processors: the same physical address on 2 processors refers to 2 different locations in 2 different memories.

=== Shared Addresses
The processors communicate among them through shared variables in memory. In shared memory architectures, communication among threads occurs through a shared address space.

*Implicit management* of the communication through `load/store` operations to access any memory locations.

Shared memory does not mean that there is a single centralized memory: the shared memory can be centralized or distributed over the nodes. Shared memory model imposes the cache coherence problem among processors.

=== Multiple and Private Addresses
The processors communicate among them through sending/receiving messages: *message passing protocol*.

*Explicit management* of the communication through send/receive primitives to access private memory locations. The memory of one processor cannot be accessed by another processor without the assistance of software protocols. No cache coherence problem among processors.

=== Physical Memory Organization
#figure(
  image("figures/physical-memory-organization.jpg", width: 80%),
  caption: "Physical Memory Organization",
)
==== Centralized Memory

*UMA (Uniform Memory Access)*: The access time to a memory location is *uniform* for all the processors: no matter which processor requests it and no matter which word is asked.

==== Distributed Memory

The physical memory is divided into memory modules distributed on each single processor.

*NUMA (Non Uniform Memory Access)*: The access time to a memory location is *non uniform* for all the processors: it depends on the location of the data word in memory and the processor location.

Multiprocessor systems can have single address space and distributed physical memory. The concepts of addressing space (single/multiple) and the physical memory organization *orthogonal* to each other.

=== Summary
#table(
  columns: (0.6fr, 1fr, 1fr, 1fr),
  table.header[Aspect][UMA][NUMA][DSM],
  [Memory Location], [Centralized], [Distributed (per node)], [Distributed (across machines)],
  [Latency], [Uniform (same for all CPUs)], [Non-uniform (local vs. remote)], [Highly variable (network-bound)],
  [Scalability], [Low (bus bottleneck)], [High (100s of CPUs)], [Very high (1000s of machines)],
  [Hardware/Software], [Hardware], [Hardware], [Software abstraction],
  [Complexity], [Low], [Medium (OS/data-aware apps)], [High (consistency protocols)],
  [Shared Address Space], [✅ hardware-level], [✅ hardware-level], [✅ software abstraction],
  [Use Case], [Small SMP systems], [Large servers/HPC], [Distributed compute clusters],
)

#pagebreak()

== Cache Coherence
Shared-Memory Architectures cache both *private data* (used by a single processor) and *shared data* (used by multiple processors to provide communication).

When shared data are cached, *the shared values may be replicated in multiple caches*. In addition to the reduction in access latency and required memory bandwidth, this replication provides a reduction of shared data contention read by multiple processors simultaneously. The use of multiple copies of same data introduces a new problem: *_cache coherence_*.

#definition("Coherence")[
  A memory system is coherent if
  + A read by processor P to location X that follows a write by P to X, with no writes of X by another processor occurring between the write and the read by P, always returns the value written by P.
  + A read by a processor to location X that follows a write by another processor to X returns the written value if the read and write are sufficiently separated in time and no other writes to X occur between the two accesses.
  + Writes to the same location are serialized; that is, two writes to the same location by any two processors are seen in the same order by all processors. For example, if the values 1 and then 2 are written to a location, processors can never read the value of the location as 2 and then later read it as 1.

  Make sure:
  - *_Write Propagation_*: Write operations at a certain position are eventually visible to other cores.
  - *_Write Serialization_*: If two processors write to the same memory location, all other processors see the writes in the same order.
]

#attention("Cache Coherence")[
  Notice that the coherence problem exists because we have both a *global state*, defined primarily by the main memory, and a *local state*, defined by the individual caches, which are private to each processor core. Thus, in a multi-core where some level of caching may be shared (e.g., an L3), although some levels are private (e.g., L1 and L2), the coherence problem still exists and must be solved.
]

When a processor writes to a shared data item, it must ensure that all other processors see the most recent value. If one processor writes to a shared variable, all other processors must see the new value when they read it.

Because the view of memory held by two different processors is through their individual caches, the processors could end up seeing different values for the same memory location, as the following figure shows.

#figure(
  image("figures/cache-coherence-problem.jpg", width: 100%),
  caption: "Cache Coherence",
)

Maintain coherence has two components: *read* and *write*. Actually, multiple copies are not a problem when reading, but a processor must have exclusive access to write a word. Processors must have the most recent copy when reading an object, so all processors must get new values after a write.

The *_protocols_* to maintain coherence for multiple processors are called cache _*coherence protocols*_. Key to implementing a cache coherence protocol is tracking the state of any sharing of a data block. There are two classes of protocols in use, each of which uses different techniques to track the sharing status.

Typically, the snooping protocols are used in *SMP*, while the directory protocols are used in *DSM*.

=== Snooping Protocols
All cache controllers monitor (*snoop*) on the bus to determine whether or not they have a copy of the block requested on the bus and respond accordingly. Every cache that has a copy of the shared block, also has a copy of the sharing state of the block, and no centralized state is kept. Suitable for *_Centralized Shared-Memory Architectures_*, and in particular for small scale multiprocessors with single snoopy bus.

There are two types of snooping protocols depending on what happens on a write operation:
- *Write-Invalidate Protocol*
- *Write-Update (or Write-Broadcast) Protocol*

#figure(
  image("figures/snoop.jpg", width: 100%),
  caption: "Snooping Protocol",
)

==== Write-Invalidate Protocol
The writing processor issues an invalidation signal over the bus to cause all copies in other caches to be invalidated before changing its local copy. The writing processor is then free to update the local data until another processor asks for it.

All caches on the bus check to see if they have a copy of the data and, if so, they must *invalidate* the block containing the data. This scheme allows *multiple* readers but only a *single* writer.

The scheme uses the bus only on the first write to invalidate the other copies, and subsequent writes do not result in bus activity. This protocol provides similar benefits to *_write-back_* protocols in terms of reducing demands on bus bandwidth.

==== Write-Update Protocol
The writing processor broadcasts the new data over the bus; all caches check if they have a copy of the data and, if so, all copies are *updated* with the new value.

This scheme requires the *continuous broadcast* of writes to shared data (while write-invalidate deletes all other copies so that there is only one local copy for subsequent writes). This protocol is like *_write-through_* because all writes go over the bus to update copies of the shared data.

=== MSI Protocol
The *MSI protocol* is a write-invalidate protocol that uses three states to track the status of a cache line:
- *Modified (M)*: The cache line is present in the cache and has been modified (dirty). It is the only copy of the data, and it is not present in main memory. When another CPU reads this cache line, the data must be written back to main memory, and then its state is downgraded to `Shared (S)`.
- *Shared (S)*: The cache line exists in multiple CPUs' caches. The data in the cache is *consistent* with the main memory data ("clean").
- *Invalid (I)*: The cache line does not contain valid data. When the CPU reads or writes to this cache line and experiences a miss, it needs to fetch the data from main memory or another cache, and then its state becomes Exclusive or Shared depending on the circumstances.

Let us consider the following case.
\
==== Read Miss
When CPU-A needs to read data block X, but its local cache has X in an `INVALID` state (a Read Miss occurs), CPU-A's cache controller issues a Read Request onto the bus. All other caches then snoop this request to check their own copies of X and their states.

Here's how the system responds based on the other caches' states:
+ *No other valid copies or all `INVALID`*: If no other caches hold a valid copy of X, or all existing copies are `INVALID`, then main memory is the authoritative source. CPU-A loads data block X directly from main memory, and its cache's state for X becomes `SHARED (S)`. This means CPU-A gets the data and joins a potential shared state.
+ *Other copies are `SHARED(S)`*: If other caches (e.g., CPU-B) hold X in a `SHARED (S)` state, it indicates that X in main memory is still up-to-date. CPU-A again loads data block X directly from main memory. Both CPU-A's and CPU-B's (and any other) copies of X remain in the `SHARED (S)` state. Multiple caches simply share the clean data from main memory.
+ *One other cache has X in `MODIFIED (M)` state*: If CPU-B holds X in a `MODIFIED (M)` state, it means CPU-B has the most recent, "dirty" version of X (not yet written back to main memory). CPU-B's cache controller *intercepts* CPU-A's read request. CPU-B then writes its `MODIFIED` data block X back to main memory. After this write-back, CPU-B's cache's state for X downgrades from `MODIFIED (M)` to `SHARED (S)`. Finally, CPU-A loads data block X from the now updated main memory, and its cache's state for X becomes `SHARED (S)`. This ensures that the dirty data is updated in main memory before any other processor can access it.

==== Read Hit
A "Read Hit" means the CPU wants to read a data block that is already present in its local cache and is in a valid state. CPU-A wants to read data block X, and X is currently in either `Modified` or `Shared` state in CPU-A's local cache.
+ *Cache Hit with `Shared (S)` State*. CPU-A's cache has X in `SHARED (S)`; other caches might also have X in `SHARED (S)`; main memory is up-to-date. CPU-A's cache controller finds X in its local cache in `SHARED` state. Since `SHARED` implies the data is clean and can be read by multiple caches, CPU-A directly reads data block X from its local cache. *No bus transactions occur*, and X's state in CPU-A's cache remains `SHARED (S)`. This is the most efficient read scenario.
+ *Cache Hit with `Modified (M)` State*. CPU-A's cache has X in `MODIFIED (M)`; other caches have X in `INVALID (I)` (if copies exist); main memory is stale (as M state is "dirty"). CPU-A's cache controller finds X in its local cache in `MODIFIED` state. This signifies that CPU-A has the most recent, exclusive, and modified version of X. CPU-A directly reads data block X from its local cache. No bus transactions occur, and X's state in CPU-A's cache remains `MODIFIED (M)`. Even though the data is "dirty" (inconsistent with main memory), CPU-A's exclusive ownership allows for a highly efficient local read.

==== Write Miss
A "Write Miss" occurs when CPU-A wants to write to data block X, but X is either not in its local cache or is in an INVALID (I) state. To perform the write, CPU-A's cache must first obtain a valid (and exclusive) copy of the data block.

CPU-A attempts to write to X, but its cache shows X is absent or `INVALID`. To gain exclusive write access, CPU-A's cache controller sends an *Write Invalidate Request* onto the bus. This request includes X's address and signals the intent to obtain exclusive ownership. All other caches (e.g., CPU-B, CPU-C) snoop this request, checking their own copies of X and their states. Responses Based on other caches' states:
+ *No other valid copies or all `INVALID (I)`*: If X isn't in any other cache or all copies are `INVALID`, main memory is the current, authoritative source. CPU-A loads data block X from main memory. Upon loading, X's state in CPU-A's cache becomes `MODIFIED (M)`. CPU-A then performs its write operation. CPU-A becomes the sole, "dirty" owner.
+ *At least one other cache holds `SHARED (S)` copies*: If other caches (e.g., CPU-B, CPU-C) hold X in a `SHARED (S)` state. Since CPU-A needs exclusive ownership for writing, these `SHARED` copies must be invalidated. CPU-B and CPU-C's copies of X transition to `INVALID (I)`. CPU-A loads data block X from main memory (as main memory is clean). CPU-A's cache's state for X becomes `MODIFIED (M)`, and it performs its write. Shared copies are invalidated to grant exclusive write access.
+ *One other cache (e.g., CPU-B) holds a `MODIFIED (M)` copy*: If CPU-B holds X in a `MODIFIED (M)` state, it has the most recent, "dirty" version. CPU-B *intercepts* the request. CPU-B writes its `MODIFIED` data block X back to main memory (to ensure main memory is updated). After the write-back, CPU-B's cache's state for X transitions from `MODIFIED (M)` to `INVALID (I)` (as CPU-A is taking exclusive ownership). Once main memory is updated, CPU-A loads data block X from main memory. X's state in CPU-A's cache becomes MODIFIED (M), and it performs its write. The dirty owner must write back and invalidate its copy to allow the new writer exclusive access, potentially introducing latency.

==== Write Hit
A "Write Hit" means CPU-A wants to write to data block X, and X is already present in its local cache in a valid state. In the MSI protocol, valid states are `Modified (M)` and `Shared (S)`. CPU-A's cache line for X is currently in either Modified or Shared state.
+ *Write Hit with `Shared (S)` State: CPU-A's cache has X in `SHARED (S)`*; other caches may also have X in `SHARED (S)`; main memory is up-to-date. CPU-A finds X in `SHARED` state in its local cache. Since `SHARED` implies read-only and potentially shared copies, CPU-A must gain exclusive write permission. It sends an Invalidate Request onto the bus, which broadcasts to all other caches. Any other caches with X's copy then change its state to `INVALID (I)`. CPU-A then upgrades its cache's state for X from `SHARED (S)` to `MODIFIED (M)` and performs its write operation. This transition from shared to exclusive modification requires a bus transaction to invalidate other copies.
+ *Write Hit with `Modified (M)` State:* CPU-A's cache has X in `MODIFIED (M)`; other caches have X in `INVALID (I)` (if copies exist); main memory is stale (due to the "dirty" M state). CPU-A finds X in `MODIFIED` state in its local cache. `MODIFIED` signifies that CPU-A already holds the most recent, exclusive copy of X. Therefore, CPU-A does not need to send any bus transactions (no invalidate requests are necessary as there are no other valid copies). CPU-A directly performs its write operation on the data block X in its local cache, and X's state remains `MODIFIED (M)`. This is the most efficient write scenario, occurring locally without any external bus activity.

=== MESI Protocol
The *MESI protocol* is an extension of the MSI protocol, and it's one of the most commonly used and fundamental cache coherence protocols in modern multi-core processors. It adds a new state, *Exclusive (E)*, to the three states of MSI (Modified, Shared, Invalid).
- *Exclusive (E)*: The cache line exists only in the current CPU's cache; *no other cache has a copy of this cache line*. Its state means that the data in the cache is consistent with the main memory data ("clean"). If the CPU wants to modify a cache line that is in the Exclusive state, it does not need to send an invalidate signal to the bus (because there are no other copies to invalidate). It can directly change its state to Modified and proceed with the modification. This saves bus bandwidth and reduces latency.

==== Read Miss
Responses based on X's state in other caches:
+ *No other valid copies or all `INVALID (I)`*: CPU-A loads data block X from *main memory*. X's state in CPU-A's cache becomes `EXCLUSIVE (E)`.
+ *At least one other cache has X in `SHARED (S)` state:* Data block X is present in *main memory* (and is up-to-date), and other caches (e.g., CPU-B) also hold clean, `SHARED` copies. Data block X is present in main memory (and is up-to-date), and other caches (e.g., CPU-B) also hold clean, `SHARED` copies. X's state in other caches (like CPU-B) remains `SHARED (S)`.
+ *One other cache (e.g., CPU-B) has X in `MODIFIED (M)` state:* Data block X in CPU-B's cache is the most recent version, but it's dirty. Main memory's copy is stale. CPU-B's cache controller snoops CPU-A's read request and finds its `MODIFIED` copy. CPU-B *intercepts* the read request, preventing it from going to main memory directly. CPU-B writes its `MODIFIED` data block X back to main memory (updating main memory). Simultaneously (or immediately after the write-back), CPU-B's cache's state for X downgrades from `MODIFIED (M)` to `SHARED (S)`. Once main memory is updated (or if a direct cache-to-cache transfer optimization is used, CPU-B might directly supply the data to CPU-A), CPU-A loads data block X from the now consistent *main memory (or directly from CPU-B)*.
+ *One other cache (e.g., CPU-B) has X in `EXCLUSIVE (E)` state*: CPU-B's cache controller snoops CPU-A's read request and finds its `EXCLUSIVE` copy. Since CPU-A also wants a copy, CPU-B is no longer the exclusive owner. CPU-B directly transfers data block X to CPU-A (often cache-to-cache via the bus). Crucially, no write-back to main memory is needed because the data is already clean. CPU-B's cache's state for X downgrades from `EXCLUSIVE (E)` to `SHARED (S)`.

==== Read Hit
+ *X is in `SHARED (S)` state*: CPU-A simply reads data block X directly from its local cache. The state of X in CPU-A's cache remains `SHARED (S)`. No bus activity occurs.
+ *X is in `EXCLUSIVE (E)` state:* CPU-A directly reads data block X from its local cache. The state of X in CPU-A's cache remains `EXCLUSIVE (E)`. No bus activity occurs.
+ *X is in `MODIFIED (M)` state:* CPU-A directly reads data block X from its local cache. The state of X in CPU-A's cache remains `MODIFIED (M)`. No bus activity occurs.

==== Write Miss
+ *No other valid copies or all `INVALID (I)`*: Main memory is the definitive source for X (if it exists), and the data in main memory is up-to-date (as no cache has modified it). CPU-A loads data block X from main memory. X's state in CPU-A's cache becomes `MODIFIED (M)`. CPU-A then performs its write operation on the data block.
+ *At least one other cache has X in `SHARED (S)` state*: CPU-B and CPU-C's cache controllers snoop the RFO request. They recognize that CPU-A needs exclusive write access. Their copies of X transition from `SHARED (S)` to `INVALID (I)`. This is the "invalidate" part of the write-invalidate protocol. CPU-A loads data block X from *main memory* (as main memory is clean). X's state in CPU-A's cache becomes `MODIFIED (M)`. CPU-A then performs its write operation.
+ *One other cache (e.g., CPU-B) has X in `EXCLUSIVE (E)` state:* CPU-B's cache controller snoops the RFO request and finds its `EXCLUSIVE` copy. Since CPU-A needs write access (and thus exclusive ownership), CPU-B's copy must become invalid. CPU-B's cache's state for X transitions from `EXCLUSIVE (E)` to `INVALID (I)`. CPU-A loads data block X from main memory (or in some optimized implementations, directly from CPU-B's cache, even though the state becomes invalid).
+ *One other cache (e.g., CPU-B) has X in `MODIFIED (M)` state:* CPU-B's cache controller snoops the RFO request and finds its `MODIFIED` copy. CPU-B *intercepts* the RFO request. It's responsible for providing the latest data. CPU-B writes its `MODIFIED` data block X back to main memory (updating main memory). CPU-B's cache's state for X transitions from `MODIFIED (M)` to `INVALID (I)` (as CPU-A is taking exclusive ownership).
+ Once main memory is updated (or if a direct cache-to-cache transfer optimization is used, CPU-B might directly supply the data to CPU-A while simultaneously writing back to memory), CPU-A loads data block X from the now consistent *main memory* (or directly from CPU-B). X's state in CPU-A's cache becomes `MODIFIED (M)`. CPU-A then performs its write operation.

==== Write Hit
+ *X is in `SHARED (S)` state*: CPU-A finds X in `SHARED` state in its local cache. Since SHARED implies the data is clean but read-only and potentially shared, CPU-A must gain exclusive write permission. CPU-A sends an "*Invalidate Request*" onto the bus. This request broadcasts to all other caches. All other caches that have a copy of data block X snoop this invalidate request and immediately change their copy's state to `INVALID (I)`. CPU-A upgrades its own cache's state for X from `SHARED (S)` to `MODIFIED (M)`. CPU-A then performs its write operation, modifying the data in its cache.
+ *X is in `EXCLUSIVE (E)` state:* CPU-A finds X in `EXCLUSIVE` state in its local cache. Since `EXCLUSIVE` implies CPU-A is already the sole owner of this data block, and the data is clean, CPU-A does not need to send any bus transactions (no invalidate requests are necessary as there are no other copies to invalidate). CPU-A directly upgrades its own cache's state for X from `EXCLUSIVE (E)` to `MODIFIED (M)`. CPU-A then performs its write operation on the data block in its local cache.
+ *X is in `MODIFIED (M)` state*: CPU-A finds X in `MODIFIED` state in its local cache. `MODIFIED` signifies that CPU-A already holds the most recent, exclusive, and dirty copy of X. Therefore, CPU-A does not need to send any bus transactions. It already has full and exclusive control over the latest data. CPU-A directly performs its write operation on data block X in its local cache. The state of X in CPU-A's cache remains `MODIFIED (M)`.

=== Directory Protocols
A directory protocol is a cache coherence protocol that uses a centralized directory to track the state of each cache line and its copies across multiple caches.

Each entry in the directory is associated to each block in the main memory (directory size is proportional to the number of memory blocks times the number of processors).

In *_Centralized Shared-Memory architectures_* (such as Symmetric Multiprocessors), there is a single directory associated to the main memory.

For _*Distributed Shared-Memory architectures*_, the directory is distributed on the nodes (one directory for each memory module) to avoid bottlenecks. Even if the entries of the directory are distributed, the sharing state of a block is stored in a single location in the directory.

The physical address space is statically distributed to the nodes. There is an overall mapping of each memory block address to each node: given a memory block address, it is known its home node (i.e. the node where reside the memory block and the directory). To avoid broadcast, send point-to-point messages to the home node of the block, leading to a *Message Passing Protocol*. Directory-based protocols are _*better scalable*_ than snooping protocols.

#figure(
  image("figures/distributed-directory.jpg", width: 80%),
  caption: "A directory is added to each node to implement cache coherence in a distributed-memory multi-processor.",
)

The directory maintains info regarding:
- The coherence state of each block
- Which processor(s) has (have) a copy of the block (usually bit vector, 1 if processor has copy).
- Which processor is the *owner* of the block (when the block is in the exclusive state, 1 if processor is owner).

#definition("Local, Home and Remote Nodes")[
  - *Home node* where the memory address (and directory entry) resides
  - *Local node* where a request originates
  - *Remote node* where there is a cached copy of the block, whether dirty or shared
]

Directory-based protocol must implement two primary operations:
- *Handle* a read miss.
- *Handle* a write to a shared, clean cache block.

To implement these operations, the directory must *track* the *state* of each cache block (Uncached, Shared, Modified).

In a simple protocol, these states could be the following:
- _*Shared*_ --- One or more nodes have the block cached, and the value in memory is up to date (as well as in all the caches).
- _*Uncached*_ --- No node has a copy of the cache block.
- _*Modified*_ --- Exactly one node has a copy of the cache block, and it has written the block, so the memory copy is out of date. The processor is called the owner of the block.

#figure(
  image("figures/the-message-to-maintain-coherence.jpg", width: 80%),
  caption: "The possible messages sent among nodes to maintain coherence",
)

Three possible coherence states for each cache block in the directory:
- *Uncached*: no processor has a copy of the cache block; block not valid in any cache;
- *Shared*: one or more processors have cache block, and memory is up-to-date; sharer set of proc. IDs;
- *Modified*: only one processor (the *owner*) has data that has been modified so the memory is out-of-date;

=== Uncached State
When a block is in the uncached state, the copy in memory is the current value, so the only possible requests for that block are
- *Read Miss from local cache (ex. N1):* Requested data are sent by Data Value Reply from home memory N0 to local cache C1 and requestor N1 is made the only sharing node. The state of the block is made S. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Shared], [0 1 0 0],
  )

When a block is in the shared state, the copy in memory is up to date, so the possible requests are
- *Write Miss from local cache (ex. N1):* Requested data are sent by Data Value Reply from home memory N0 to local cache C1 and N1 becomes the owner node. The block is made M to indicate that the only valid copy is cached. Sharer bits indicate the identity of the owner of the block. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Modified], [0 1 0 0],
  )

=== Shared State
When a directory block B0 in home N0 is in the *shared state*, the memory value is up to date, we can have: #table(
  columns: (0.4fr, 1fr, 1fr),
  table.header[Block][Coherence State][Sharer / Owner Bits],
  [B0], [Modified], [0 1 0 0],
)
- *Read Miss from local cache (ex. N2):* Requested data are sent by *Data Value Reply* from home memory N0 to local cache C2 and the requestor (ex. N2) is added to the Sharer bits. The state of the block stays *S*. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Shared], [0 1 1 0],
  )
- *Write Miss from local cache (ex. N2):* Requested data are sent by *Data Value Reply* from home memory N0 to local cache C2. Invalidate messages are sent from home N0 to remote sharer(s) (P1) and bits are set to the identity of requestor (P2 owner). The state of the block becomes *M*. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Modified], [0 0 1 0],
  )

=== Modified State
When a directory block B0 in home N0 is in the *M state*, the current value of the block is held *in the cache* of the *owner* processor (ex. P1) identified by the sharer bits, so 3 possible requests can occur: #table(
  columns: (0.4fr, 1fr, 1fr),
  table.header[Block][Coherence State][Sharer / Owner Bits],
  [B0], [Modified], [0 1 0 0],
)
- *Read Miss from local cache (ex. N2):* To the owner node P1 is sent a *Fetch* message, causing state of the block in the owner's cache to transition to S and the owner send data to the home directory (through *Data Write Back*); data written to home memory are sent to requesting cache N2 by *Data Value Reply*. The identity of the requesting processor (P2) is added to the Sharers set, which still contains the identity of the processor that was the owner (since it still has a readable copy). Block state in directory is set to S. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Shared], [0 1 1 0],
  )
- *Data Write-Back from remote owner:* The owner cache is replacing the block and therefore must write it back to home. This make the memory copy up to date (the home dir. becomes the *owner*), the block becomes U, and the Sharer set is empty. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Uncached], [],
  )
- *Write Miss local cache (ex. N2)*: A *Fetch/Inv*. msg is sent to the *old owner* (ex. N1) causing to *invalidate* the cache block and the cache C1 to send data to the home directory (*Data Write Back*), from which the data are sent to the requesting node N2 (*Data Value Reply*), which becomes the new owner. Sharer is set to the identity of the new owner, and the state of the block remain M (but owner changed) #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Modified], [0 0 1 0],
  )

#pagebreak()

= Data Parallelism
SIMD architectures can exploit significant data-level parallelism for:
- Matrix-oriented scientific computing, machine learning and deep learning;
- Multimedia such as image and sound processors;
SIMD allows programmer to continue to think sequentially and achieve parallel speedups (compared to MIMD that require parallel programming).

== Vector Architectures
Vector architectures grab sets of data elements scattered about memory, place them into _*large sequential register files*_, operate on data in those register files, and then disperse the results back into memory. A single instruction works on vectors of data, which results in dozens of register-register operations on independent data elements.

=== Components of Vector Architectures

=== Execution of Vector Instructions
We can best understand a vector processor by looking at a vector loop for RV64V. Let's take a typical vector problem, which we use throughout this section:
$
  Y = a times X + Y
$
X and Y are vectors, initially resident in memory, and a is a scalar. This problem is the SAXPY or DAXPY loop. (SAXPY stands for *single-precision* $a times X plus Y$, and DAXPY for *double precision* $a times X plus Y$.)

=== Vector Execution Time
Execution time depends on three factors:
- Length of the operand vectors
- Structure hazards
- Data dependences
Functional units consume one element per clock cycle, so the execution time is approximately given by the vector length.

#pagebreak()

#bibliography("references.bib")

