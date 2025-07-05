#import "@local/simple-note:0.0.1": *

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
  image("../figures/basic-implementation-risc-datapath.jpg", width: 80%),
  caption: "Basic Implementation of a RISC-V data path",
)

#figure(
  image("../figures/implementation-risc-datapath.jpg", width: 80%),
  caption: "A complete implementation of RISC-V data path",
)

#pagebreak()

== Five-Stage Pipeline
Sequential is slower than pipeline. The following figure shows the difference (in terms of clock cycles) between sequential and pipeline.

#figure(
  image("../figures/sequential-vs-pipelining-1.jpg", width: 70%),
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

#figure(image("../figures/pipeline_execution.jpg", width: 80%), caption: [ Pipeline Execution of RISC-V Instructions ])

Resources used during the pipeline execution
*IM* is Instruction Memory, *REG* is Register File and *DM* is Data Memory:

#figure(
  image("../figures/resource_used_pipeline.jpg", width: 80%),
  caption: [Resources used during the pipeline execution ],
)

#pagebreak()

== Pipeline Performance Metrics
=== Clocks Per Instruction (CPI)
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

#example("Speedup of Pipeline")[
  Consider the unpipelined processor in the previous section. Assume that it has a *4 GHz* clock (or a 0.5 ns clock cycle) and that it uses *four cycles* for ALU operations and branches and *five cycles* for memory operations.

  Assume that the relative frequencies of these operations are 40%, 20%, and 40%, respectively.

  Suppose that due to clock skew and setup, *pipelining the processor adds 0.1 ns* of overhead to the clock. Ignoring any latency impact, how much speedup in the instruction execution rate will we gain from a pipeline?


  The average instruction execution time on the unpipelined processor is:
  $
    "Average instruction execution time" = & "Clock cycle" times "Average CPI"                \
                                         = & 0.5 "ns" times [(40%+20%) times 4 + 40% times 5] \
                                         = & 0.5 "ns" times 4.4                               \
                                         = & 2.2 "ns"
  $
  In the pipelined implementation, the clock must run at the speed of the slowest stage plus overhead, which will be $0.5 + 0.1$ or $0.6 "ns"$; this is the average instruction execution time. Thus, the speedup from pipelining is:
  $
    "Speedup" = & "Unpipelined execution time" / "Pipelined execution time" \
              = & (2.2 "ns") / (0.6 "ns")                                   \
              = & 3.67 "times"
  $
]

#pagebreak()

== Pipeline Hazards
There are situations, called *_hazards_*, that prevent the next instruction in the instruction stream from executing during its designated clock cycle. Hazards reduce the performance from the ideal speedup gained by pipelining. There are *three classes of hazards*.

=== Structural Hazards
*Structural hazards* occur when we attempt to use the same resource from different instructions simultaneously.

The RISC-V architecture avoids *structural hazards* by two key design decisions:
+ *Separate Instruction and Data Memories (_Harvard-Style Architecture_)*: The *fetch stage (IF)* of the pipeline accesses the *Instruction Memory* to read the next instruction. The *memory stage (MEM)* of the pipeline accesses the *Data Memory* to read/write operands. Since the *IM* and *DM* are separate, fetching an instruction and accessing data can happen in parallel without resource competition.
+ *Multiple-Ported Register File Design*: Read ports allow instructions in the decode stage (`ID`) to read operands. Write ports allow instructions in the write-back stage (`WB`) to update registers. Register file read/write operations can occur in the same clock cycle without conflict.

=== Data Hazards
If the instructions executed in the pipeline are *dependent to each other*, data hazards can arise when instructions are too close. There are three types of data hazards:
+ *Read After Write (RAW) hazard*: Instruction $n+1$ tries to read a source operand before the previous instruction $n$ has written its value in the Register File.
+ *Write After Read (WAR) hazard*: This hazard occurs when read of register x by instruction $n+1$ occurs after a write of register x by instruction $n$.
+ *Write After Write (WAW) hazard:* This hazard occurs when write of register x by instruction $n+1$ occurs after a write of register x by instruction $n$.

#tip("Data Hazards in Five Stages Pipeline")[
  In a classic 5-stage pipeline, only *RAW* hazards naturally occur, while *WAW* and *WAR* hazards do not occur.
  - No *WAW* hazards because all instructions write their results in the `WB` stage, and they reach `WB` in program order.
  - No *WAR* hazards because the `ID` stage reads registers in program order, and the `WB` stage writes registers in program order.
]

=== Summary of Data Dependencies
Data dependency does not directly determine the *number of pipeline stalls*, whether true hazards occur, and how to eliminate them; it depends on how the pipeline handles these dependencies. In other words, the architectural characteristics of the pipeline determine:
- wether there is a hazard
- If there is a hazard, how to eliminate it(hardware or compiler)
- If it cannot be optimized, the pipeline needs to stop several times

When the pipeline executes instructions, the dependency relationships between instructions may lead to the following three types of data hazards:
- *RAW hazards* correspond to *true data dependencies*
- *WAR hazards* correspond to *anti-dependencies*
- *WAW hazards* correspond to *output dependencies*

The *RAW hazards* can be solved with a simple hardware technique called _*forwarding*_.

#figure(
  image("../figures/forwarding-pipeline.jpg", width: 80%),
  caption: "Forwarding in a Pipeline",
)

=== Forwarding

If we can take the inputs to the ALU from _any_ pipeline register rather than just `ID/EX`, then we can forward the correct data. By adding multiplexers to the input of the ALU, and with the proper controls, we can run the pipeline at full speed in the presence of these data hazards.

The dependence between the pipeline registers move forward in time, so it is possible to supply the inputs to the ALU needed by the `and` instruction by forwarding the results found in the pipeline registers.

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
  image("../figures/forwarding-path.jpg", width: 80%),
  caption: "Forwarding Unit",
)

== Control Hazards
@fig:branch-hazards-example shows a sequence of instructions and indicates when the branch would occur in this pipeline. The numbers of the left of the instruction are the addresses of the instructions.

#figure(
  image("../figures/branch-hazards-example.jpg", width: 80%),
  caption: "Branch Hazards Example",
) <branch-hazards-example>

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

#pagebreak()
