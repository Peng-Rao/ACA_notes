#import "@local/simple-note:0.0.1": *

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
*_Out-of-order execution_* introduces the possibility of *WAR* and *WAW* hazards, which do not exist in the five-stage integer pipeline and its logical extension to an in-order floating-point pipeline. Both these hazards are avoided by the use of *_register renaming_*.

To better understand how *_register renaming_* eliminates *WAR* and *WAW* hazards, consider the following example code sequence that includes potential *WAR* and *WAW* hazards:
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
  image("../figures/scoreboard-architecture.jpg"),
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
  image("../figures/instruction-status.jpg", width: 80%),
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
  image("../figures/functional-unit-status.jpg", width: 80%),
  caption: "Functional Unit Status",
)

=== Register result status

#figure(
  image("../figures/register-result-status.jpg", width: 80%),
  caption: "Register Result Status",
)

#pagebreak()

== Tomasulo Dynamic Scheduling Technique
_Tomasulo Algorithm_, invented by Robert Tomasulo, tracks when operands for instructions are available to minimize *RAW hazards* and introduces *register renaming* in hardware to minimize *WAW and WAR hazards*.

Although there are many variations of this scheme in recent processors, they all rely on two key principles:
- dynamically determining when an instruction is ready to execute.



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
- *Fetch instruction* from the *instruction queue* (FIFO), maintaining correct data flow.
- Check for *structural hazards* (if no RS is available, the instruction stalls).
- If the *operand* is in a register, obtain the value directly; If it is not ready, record the source of its producer.
- Put the instruction with operands or operands source into a reservation station (RS) associated with the required functional unit (FU).

Instructions are fetched from the head of a *FIFO queue*, ensuring they are issued in program order. *This maintains in-order issue even if execution is out-of-order.*

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
  - Operands are sourced *directly from the RS/CDB*, bypassing the Register File (RF). This mimics forwarding, eliminating the wait for RF write-back and reducing *RAW* resolution latency.
+ *Execution Completion & CDB Broadcast*:
  - Once execution finishes, the result is *broadcast to all RS entries and the RF via the CDB*.
  - RS entries waiting on this result update their operands, enabling dependent instructions to proceed.

==== Write result
When result is available, write it on *Common Data Bus* and from there into *Register File* and into all RSs (including store buffers) waiting for this result; Stores also write data to memory unit during this stage (when memory address and result data are available); Mark reservation station available.

#pagebreak()

== Hardware-Based Speculation
We introduce the concept of HW-based speculation, which extends the ideas of dynamic scheduling beyond branches.

HW-based speculation combines *3 key concepts*:
+ *Dynamic branch prediction*;
+ *Speculation* to enable the execution of instructions before the branches are solved by undoing the effects of mispredictions;
+ *Dynamic scheduling* beyond branches.
#figure(
  image("../figures/ROB-structure.jpg"),
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
+ *Check if there is an available RS and ROB entry.* If either RS or ROB is full, the instruction *stalls*.
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
