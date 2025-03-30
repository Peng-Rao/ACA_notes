#import "@local/simple-note:0.0.1": *
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
  background-color: "#FAF9DE",
)
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

== Registers in RISC-V
RISC-V defines a set of *registers* that are part of the core ISA. RISC-V base ISA consists of 32 *_general-purpose registers_* `x0-x31` which hold integer values. The register `x0` is *hardwired* to the constant `0`. There is an additional user-visible *program counter* `pc` register which holds the address of the current instruction.

As shown in the @fig:risc-v-registers, the width of these registers is defined by the RISC-V base variant used. For RV32, the registers are 32 bits wide; for RV64, they are 64 bits wide; and for RV128, the registers are 128 bits wide.

#figure(
  image("figures/risc-v-registers.jpg", width: 80%),
  caption: [ RISC-V Registers @RegistersRISCVWikiChip],
) <fig:risc-v-registers>

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
  "CPU clock cycles" = "Instructions fora program" times "Average cycles per instruction"
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

#pagebreak()

= Pipelining
*Pipelining* is an implementation technique whereby multiple instructions are *overlapped* in execution; it takes advantage of *parallelism* that exists among the actions needed to execute an instruction.

A pipeline is like an *assembly line*. In a computer pipeline, each step in the pipeline completes a part of an instruction. Like the assembly line, different steps are completing different parts of different instructions in parallel. Each of these steps is called a _pipe stage_ or a _pipe segment_.

The _*throughput*_ of an instruction pipeline is determined by how often an instruction exits the pipeline. The time required between moving an instruction one step down the pipeline is a *processor cycle*.

Pipelining yields a reduction in the average execution time per instruction. If the starting point is a processor that takes multiple clock cycles per instruction, then pipelining reduces the CPI. Pipelining is an implementation technique that exploits *parallelism* among the instructions in a sequential instruction stream.

== The Basics of the RISC V Instruction Set
All RISC architectures(*RISC V, MIPS, ARM*) are characterized by a few key properties:
1. *All operations on data apply to data in registers* and typically change the entire register(32 or 64 bits).
2. The only operations that affect memory are *load* and *store* operations that move data from memory to a register or to memory from a register, respectively.
3. The instruction formats are few in number, with all instructions typically being one size. In RISC V, the register specifiers: *rs1*, *rs2*, and *rd* are always in the same place simplifying the control.

#example("RISC-V Instruction Set")[
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
]


== A Simple Implementation of a RISC Instruction Set
Every instruction in this RISC subset can be implemented in, at most, *5 clock cycles*. The 5 clock cycles are as follows.
+ _Instruction Fetch(IF)_: Send the program counter (PC) to memory and fetch the current instruction from memory. Update the PC to the next *sequential instruction* by adding 4 (because each instruction is 4 bytes) to the PC.
+ _Instruction decode/register fetch cycle (ID)_: Decode the instruction and read the registers corresponding to register source specifiers from the register file. Do the equality test on the registers as they are read, for a possible branch. Sign-extend the offset field of the instruction in case it is needed. Compute the possible branch target address by adding the sign-extended offset to the incremented PC.
+ _Execution/effective address cycle (EX)_: The ALU operates on the operands prepared in the prior cycle, performing one of three functions, depending on the instruction type.
+ _Memory access (MEM)_: If the instruction is a load, the memory does a read using the effective address computed in the previous cycle. If it is a store, then the memory writes the data from the second register read from the register file using the effective address.
+ _Write-back cycle (WB)_: Write the result into the *register file*, whether it comes from the memory system (for a load) or from the ALU (for an ALU instruction).

== Implementation of RISC-V processor
The *Instruction Memory*(read-only memory) is separated from *Data Memory*. 32 General-Purpose Registers organized in a *Register File(RF)* with 2 read ports and 1 write port.

For every instruction, the first two steps are identical:
+ Send the *_program counter (PC)_* to the memory that contains the code and fetch the instruction from that memory.
+ *Read one or two registers*, using fields of the instruction to select the registers to read. For the `ld` instruction, we need to read only one register, but most other instructions require reading two registers.

Fortunately,for each of the three instruction classes(memory-reference,arithmetic-logical, and branches), the actions are largely the same, independent of the exact instruction:

For example, all instruction classes use the *arithmetic-logical unit* (ALU) after reading the registers.
- For the *memory-reference* instructions, the ALU computes the effective address by adding the offset to the base register.
- For the *arithmetic-logical* instructions, the ALU performs the operation specified by the instruction.
- For the *branch* instructions, the ALU compares the two registers to determine if the branch should be taken(*equality test*).

#figure(
  image("figures/basic-implementation-risc-datapath.jpg", width: 80%),
  caption: "Basic Implementation of a RISC Instruction Set",
)

#figure(
  image("figures/implementation-risc-datapath.jpg", width: 80%),
  caption: "A complete implementation of RISC-V data path",
)

== Building a data path
looking at which *datapath elements* each instruction needs, and then work our way down through the levels of abstraction.

@fig:first-datapath-component shows the first element we need: a memory unit to store the instructions of a program and *supply instructions* given an address.
- *Program Counter (PC)* is a register that holds the address of the current instruction.
- *Adder* is used to increment the PC by 4 to get the address of the next instruction and it is permanently made an adder and cannot perform the other ALU functions.
- The *instruction memory* need only provide read access because the datapath does not write instructions.

#figure(
  image("figures/first-datapath-component.jpg", width: 80%),
  caption: [First datapath component: Instruction Memory],
) <fig:first-datapath-component>

== RISC-V Pipelining
Pipelining is a performance optimization technique based on the *overlap* of the execution of multiple instructions deriving from a sequential execution flow. Pipelining exploits *instruction parallelism* in a sequential instruction stream.

Sequential is slower than pipeline. The following figure shows the difference (in terms of clock cycles) between sequential and pipeline.

#figure(
  image("figures/sequential-vs-pipelining-1.jpg", width: 70%),
  caption: "Sequential vs Pipeline",
)

The time to advance the instruction of one stage in the pipeline corresponds to a *clock cycle*. The total cost is: 9 clock cycles.

The pipeline stages must be synchronized, the duration of a clock cycle is defined by the time requested by the *slower stage* of the pipeline. The goal is to balance the length of each pipeline stage. If the stages are perfectly balanced, the *ideal speedup* due to pipelining is equal to the number of pipeline stages.

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

== Resources used during the pipeline execution
*IM* is Instruction Memory, *REG* is Register File and *DM* is Data Memory.

#figure(
  image("figures/resource_used_pipeline.jpg", width: 80%),
  caption: [Resources used during the pipeline execution ],
)

== Performance Metrics
IC = Instruction Count, CPI = Clocks Per Instruction, IPC = Instructions Per Clock Cycle = 1 / CPI, MIPS = $f_("clock") slash ("CPI" times 10^6)$.

*Clock Cycles = IC + Stall Cycles + 4*. 4 is clocks to conclude the pipeline.

#example("Speedup of Pipeline")[
  Consider the unpipelined processor in the previous section. Assume that it has a *4 GHz* clock (or a 0.5 ns clock cycle) and that it uses *four cycles* for ALU oper-ations and branches and *five cycles* for memory operations.

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

== Pipeline Hazards
There are situations, called *_hazards_*, that prevent the next instruction in the instruc-
tion stream from executing during its designated clock cycle. Hazards reduce the performance from the ideal speedup gained by pipelining. There are *three classes of hazards*.

=== Structural Hazards
*Structural hazards* occur when we attempt to use the same resource from different instructions simutaneously.

The RISC-V architecture avoids *structural hazards* by two key design decisions:
+ *Separate Instruction and Data Memories (_Harvard-Style Architecture_)*: The *fetch stage (IF)* of the pipeline accesses the *Instruction Memory* to read the next instruction. The *memory stage (MEM)* of the pipeline accesses the *Data Memory* to read/write operands. Since the *IM* and *DM* are separate, fetching an instruction and accessing data can happen in parallel without resource competition.
+ *Multiple-Ported Register File Design*: Read ports allow instructions in the decode stage (ID) to read operands. Write ports allow instructions in the write-back stage (WB) to update registers. #firebrick[Register file read/write operations can occur in the same clock cycle without conflict.]

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
  image("figures/data-hazards-example.jpg", width: 80%),
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

If we can take the inputs to the ALU from _any_ pipeline register rather than just `ID/EX`, then we can forward the correct data. By adding multiplexors to the input of the ALU, and with the proper controls, we can run the pipeline at full speed in the presence of these data hazards.

The dependences between the pipeline registers move forward in time, so it is possible to supply the inputs to the ALU needed by the `and` instruction by forwarding the results found in the pipeline registers.

@fig:forwarding-hardware shows close-up of the ALU and pipeline register after adding forwarding. The multiplexors have been expanded to add the forwarding paths, and we show the forwarding unit.

#figure(
  image("figures/forwarding_hardware.jpg", width: 80%),
  caption: "Forwarding Hardware",
) <fig:forwarding-hardware>

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
It reduces the penalty of a branch to only one instruction if the branch is taken, namely, the one currently being fetched.

To flush instructions in the `IF` stage, we add a control line, called *IF.Flush*, that zeros the instruction field of the `IF/ID` pipeline register. Clearing the register transforms the fetched instruction into a `nop`, an instruction that has *no action and changes no state*.

One stall cycle for every branch will yield a performance loss of 10% to 30% depending on the branch frequency, so we will examine some techniques to deal with this loss.

#example("Pipelined Branch")[
  Consider the following sequence of instructions:
  ```asm
  36 sub x10, x4, x8
  40 beq x1, x3, 16   // PC-relative branch to 40+16*2=72
  44 and x12, x2, x5
  48 or  x13, x2, x6
  52 add x14, x4, x2
  56 sub x15, x6, x7
  ...
  72 ld  x4, 50(x7)
  ```
]

#pagebreak()
= Branch Prediction
There are two types of methods to deal with the performace loss due to branch hazards:
+ *Static Branch Predition Techniques*: The prediction (taken/untaken) for a branch is fixed at *compile time* for each branch during the entire execution of the program.
+ *Dynamic Branch Prediction Techniques*: The prediction (taken/untaken) for a branch can change *at runtime* during the program execution.

== Static Branch Prediction
*Static Branch Prediction* is a simple method that assumes the prediction is *fixed* at *compile time* by using some *heuristics* or compiler hints --- rather than considering the runtime execution behavior. It is typically an effective method when the branch behavior for the target application is *highly predictable* at compile time.

=== Branch Always Not Taken
It is the easiest predition, *we assume the branch will be always not taken*, thus the instruction flow can continue sequentially as if the branch condition was not satisfied. And it is suitable for `IF-THEN-ELSE` conditional statements, when the `THEN` clause is the most probable and the program will continue sequentially.

#figure(
  image("figures/branch-not-taken.jpg", width: 80%),
  caption: "Branch Always Not Taken Prediction",
)

First, we predict the branch not taken at the end of the `IF` stage.
- If the branch outcome at the end of `ID` stage will be not taken $arrow.double.long$ the *prediction was correct* and there is *no branch penalty cycles*.
- If the branch outcome at the end of `ID` stage will be taken $arrow.double.long$ the *prediction was incorrect*. In this case, we need to *flush* the instruction already fetched (it is turned into a `nop`) and need to *fetch* the instruction at the branch target address $arrow.double.long$ *one branch penalty cycle*.

=== Branch Always Taken
Predition taken at the end of the `IF` stage.
- If the branch outcome at the end of `ID` stage will be taken $arrow.double.long$ *the predition was correct* $arrow.double.long$ *no branch penalty cycles*.
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

== Dynamic Branch Prediction
The basic idea is to use the past branch behavior to predict at runtime the future branch behavior.
- We use the hardware to dynamically predict the outcome of a branch.
- The prediction will depend on the runtime behavior of the branch.
- The prediction will change at runtime if the branch changes its behavior during execution.

=== Branch History Table
One implementation of that approach is a *branch prediction buffer* or *branch history table*. A branch prediction buffer is a small memory indexed by the lower portion of the address of the branch instruction. The memory contains a bit that says whether the branch was recently taken or not.

The behavior is controlled by a *Finite State Machine* with only 1-bit of history (2 states) to remember the last direction taken by the the branch to predict the next branch outcome.

*Finite State Machine* with only 1-bit of history to remember the last direction taken by the branch:
- If the prediction is correct $arrow.double.long$ remains in the current status (and branch prediction outcome)
- If the prediction is not correct $arrow.double.long$ changes the status (and branch prediction outcome)

#figure(image("figures/finite-state-machine.jpg", width: 80%))

Table containing 1 bit for each entry that says whether the branch was recently *taken* or *not taken*. Table indexed by the lower portion k-bit of the address of the branch instruction. (For locality reasons, we would expect that the most significant bits of the branch address are not changed.)

The table has *no tags* (every access is a hit) and the prediction bit may have been put there by another branch with the same low-order address bits: but it doesn' matter. The prediction is just a hint!

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
      [*Interation*],
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
      [*Interation*],
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

#pagebreak()

= Introduction to Instruction Level Parallelism
This potential overlap among instructions is called _instruction-level parallelism (ILP)_, because the instructions can be evaluated in parallel.

The value of the CPI (cycles per instruction) for a pipelined processor is the sum of the base CPI and all contributions from stalls:

#nonum($
  "Pipeline CPI" = "Ideal pipeline CPI" + "Structural stalls" + "Data hazard stalls" + "Control stalls"
$)

#attention[
  Remind that pipeling improves *instruction throughput*, but not the latency of the single instruction.
]

== The problem of Dependences
Determining dependences among instructions is critical to define the amount of parallelism existing in a program. If two instructions are *dependent* to each other, they cannot be executed in parallel, they must be executed in a sequential order or only partially overlapped.

There are *three* different types of dependences in a code:
- *True Data Dependences*: an instruction $j$ is dependent on a data produced by a previous instruction $i$
- *Name Dependences*: two instructions use the same register or memory location;
- *Control Dependences*: they impose the ordering of instructions

== Name Dependences
A *name dependence* occurs when two instructions use the same register or memory location (called name), but there is no flow of data between the instructions associated with that name.

#attention[
  Name dependences are *not true data dependences*, since there is no value (no data flow) being transmitted between the two instructions => this is just a *register reuse*!
]

There are two types of name dependences:
- Anti-dependences
- Output Dependences

Let's consider Ii that precedes instruction Ij in program order:
+ *Anti-dependences*: When *Ij* writes a register or memory location that instruction *Ii* read, it can generate a *Write After Read (WAR) hazard*.
+ *Output dependences*: When *Ij* writes a register or memory location that instruction *Ii* also writes, it can generate a *Write After Write (WAW) hazard*.

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

== Summary
Data dependency does not directly determine the *number of pipeline stalls*, whether true hazards occur, and how to eliminate them; it depends on how the pipeline handles these dependencies. In other words, the architectural characteristics of the pipeline determine:
- wether there is a hazard
- If there is a hazard, how to eliminate it(hardware or compiler)
- If it cannot be optimized, the pipeline needs to stop several times

When the pipeline executes instructions, the dependency relationships between instructions may lead to the following three types of data hazards:
- *RAW hazards* correspond to *true data dependences*
- *WAR hazards* correspond to *anti-dependences*
- *WAW hazards* correspond to *output dependences*

Dependences are a property of the program, while hazards are a property of the pipeline architecture.

#pagebreak()

= Advanced Dynamic Scheduling Techniques
== Tomasulo Algorithm
_Tomasulo Algorithm_, invented by Robert Tomasulo, tracks when operands for instructions are available to minimize *RAW hazards* and introduces *register renaming* in hardware to minimize *WAW and WAR hazards*.

Although there are many variations of this scheme in recent processors, they all rely on two key principles:
- dynamically determining when an instruction is ready to execute.
- renaming registers to avoid unnecessary hazards.


#pagebreak()
#bibliography("references.bib")

