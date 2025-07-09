= VLIW and static scheduling
== VLIW Processors
Very Long Instruction Word (VLIW) is a processor architecture that allows multiple operations to be executed in parallel by issuing a long instruction (bundle) that contains multiple independent operations. VLIW processors are designed to exploit instruction-level parallelism (ILP) by allowing the compiler to schedule instructions statically, rather than relying on dynamic scheduling *at runtime*.

The following is a example of a VLIW processor, The long instruction (*bundle*) has a fixed set of operations (*slots*). A *5-issue* VLIW has a long instruction (bundle) to contain up to *5 operations* corresponding to *5 slots*.

#figure(
  image("../figures/VLIW-processor.jpg", width: 80%),
  caption: "Example of a VLIW Processor",
)

The *single-issue packet (bundle)* represents a wide instruction with multiple independent operations (or *syllables*) per instruction. The *compiler* identifies statically the multiple independent operations to be executed in parallel by the multiple Functional Units. The compiler solves statically the *structural hazards* for the use of HW resources and the *data hazards*, otherwise the compiler inserts `NOPs`.

== VLIW Architecture
The VLIW architecture has the following assumptions:
- There is a *single PC* to fetch a long instruction (bundle).
- *Only one branch for each bundle* to modify the control flow.
- *There is a shared Multi-ported Register File*: If the bundle has 4 slots, we need $2 times 4$ read ports and 4 write ports to read 8 source registers per cycle and to write 4 destination registers per cycle.
- To keep busy the FUs, there must be enough parallelism in the source code to fill in the available 4 operation slots. Otherwise, `NOP`s are inserted.
- If each slot is assigned to a Functional Unit, the decode unit is a simple decoder and each op is passed to the corresponding FU to be executed.
- *If there are more parallel FUs than the number of issues (slots)*, the architecture must have a *dispatch network* to redirect each op and the related source operands to the target FU.

To solve *RAW* hazards, the compiler performs dependency analysis to detect *RAW* hazards, it reorders statically instructions (not involved in the dependences). Otherwise, the compiler inserts `NOP`s to avoid *RAW* hazards.

*WAR* and *WAW* hazards are statically solved by *the compiler* by correctly selecting temporal slots for the operations or by using *Register Renaming*.

*However*, a *mispredicted branch* must be solved dynamically by the hardware by *flushing* the execution of the speculative instructions in the pipeline.

== VLIW Code Scheduling
The main goal is statically reordering instructions in object code so that they are executed in a minimum amount of time and semantically correct order.
- Execute time-critical operations efficiently.
- Try to increase the number of independent instructions fetched.

=== Dependencies Graph
A *dependence graph* captures true, anti and output dependencies between instructions. Anti and output dependencies are name dependencies due to variables/registers reuse.

#figure(
  image("../figures/dependence-graph.jpg", width: 80%),
  caption: "Dependence Graph",
)

- Each node represents an operation in the basic block.
- There is an edge from a node $i$ to another node $j$ in the graph if the results of the operation $i$ are used by the operation $j$: node $i$ is a direct predecessor of node $j$.
- Each node is annotated with: the *longest path* to reach it / the node latency.

=== List-based Scheduling Algorithm
List-based scheduling algorithm is a resource-constrained scheduling algorithm. Before scheduling begins, operations on top of the graph are inserted in the ready set. Starting from the first cycle, for each cycle try to schedule operations (nodes) from the ready set that can fill the available resource slots. When more nodes are in the ready set, select the node with the highest priority (longest path to the end of the graph).

== Loop Unrolling
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

*Cons*:
- Loop unrolling increases the *register pressure* (number of allocated registers) due to the need of register renaming to avoid name dependencies.
- Loop unrolling increases the *code size and instruction cache misses*.

*Loop-level analysis* involves determining what data dependences exist among the operands across the iterations of a loop.

*Loop-carried dependence*: Whether data accesses in later iterations are dependent on data values produced in earlier iterations.

#pagebreak()

== Software Pipelining
Software pipelining is a scheduling technique that allows the compiler to schedule instructions across multiple iterations of a loop, effectively overlapping the execution of different iterations. This technique is particularly useful for loops with a fixed number of iterations and can significantly improve performance by *keeping the pipeline full*.

```c
for(i=0; i<5; i++)
{
  A[i]=B[i];   // stage X
  A[i]=A[i]+1; // stage Y
  C[i]=A[i];   // stage Z
}
```

#figure(
  image("../figures/software-pipelining-example.jpg"),
  caption: "Software Pipelining Example",
)

#pagebreak()
