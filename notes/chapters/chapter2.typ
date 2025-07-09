#import "@local/simple-note:0.0.1": *

= Instruction-Level Parallelism
_*Instruction-Level Parallelism (ILP)*_ is a key concept in computer architecture that aims to improve the performance of uni-processor by executing multiple instructions simultaneously or overlapping their execution.

There are two largely separable approaches to exploiting *ILP*:
- An approach that relies on hardware to help discover and exploit the parallelism dynamically
- An approach that relies on software technology to find parallelism statically at *compile time*.

== Dependences and Hazards
There are three different types of dependences: _data dependences_ (also called true data dependences), _name dependences_, and _control dependences_.

#figure(
  image("../figures/Big-picture-dependences-hazards.png", width: 100%),
  caption: "Big picture of dependences and hazards",
)

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

=== Control Dependences
A control dependence determines the ordering of instructions and it is preserved by two properties:
- Instructions execution in program order to ensure that an instruction that occurs before a branch is executed before the branch.
- Detection of control hazards to ensure that an instruction (that is control-dependent on a branch) is not executed until the branch direction is known.

Although preserving control dependence is a simple way to preserve program order, control dependence is not the critical property that must be preserved(as seen when we've studied scheduling techniques to fill in the branch delay slot).

*Two properties* are critical to preserve program correctness (and normally preserved by maintaining both data and control dependencies during scheduling):
- *Data flow*: Actual flow of data values among instructions that produces the correct results and consumes them.
- *Exception behavior*: Preserving exception behavior means that any changes in the ordering of instruction execution must not change how exceptions are raised in the program.

#tip("The difference between dependences and hazards")[
  - *Dependences* are a property of the program, and they are determined by the data flow of the program.
  - *Hazards* are a property of the pipeline architecture, and they are determined by the pipeline structure and how it handles hazards (`stall`, `forwarding`).
]

== Multiple Issue Processors
For *single-issue processors*, scalar processors that fetch and issue max one operation at each clock cycle. For *multiple-issue processors*, scalar processors that fetch and issue multiple operations at each clock cycle.

The *multiple-issue processors* require:
- *To fetch* multiple instructions in a cycle (higher bandwidth from the instruction cache)
- *To issue* multiple instructions based on:
  - *Dynamic scheduling*: The hardware issues at runtime a varying number of instructions at each clock cycle.
  - *Static scheduling*: The compiler issues statically a fixed number of instructions at each clock cycle.

There are two main types of multiple-issue processors:
- _*Very Long Instruction Word (VLIW)*_: The compiler statically schedules a fixed number of instructions at each clock cycle, and the hardware executes them in parallel.
- _*Superscalar*_: The hardware dynamically schedules a varying number of instructions at each clock cycle, based on the available resources and the data dependencies.

#figure(table(
  columns: 4,
  stroke: 0.5pt,
  align: left,

  [*Type*], [*Instruction Scheduling*], [*Complexity*], [*Performance*],

  [VLIW (Static)], [At compile time], [Lower], [Medium],

  [Superscalar (Dynamic)], [At runtime], [Higher], [High],
))



#pagebreak()
