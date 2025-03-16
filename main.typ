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

#pagebreak()
#bibliography("references.bib")

