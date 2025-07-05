#import "@local/simple-note:0.0.1": *
#import "@preview/cetz:0.3.4": *
#import "@preview/muchpdf:0.1.0": muchpdf
#show: zebraw

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
#set math.mat(delim: "[")
#set math.vec(delim: "[")
#set math.equation(supplement: [Eq.])

#let nonum(eq) = math.equation(block: true, numbering: none, eq)
#let firebrick(body) = text(fill: rgb("#b22222"), body)




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

= Thread-Level Parallelism (TLP)
_*Thread-level parallelism (TLP)*_ is a form of parallelism that allows multiple threads to be executed simultaneously, either on a single processor or across multiple processors. TLP can be exploited in various ways, including through multithreading and multiprocessor systems.
- *Multithreading:* Exploiting Thread-Level Parallelism to Improve Uniprocessor Throughput
- *Multiprocessor:* Multiple independent threads operating at once and in parallel

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
  "AMAT"_("harvard") = & \%"Instr". ("Hit Time" + "Miss Rate" I\$ \* "Miss Penalty") \
                     + & \%"Data" ("Hit Time" + "Miss Rate" D\$ \* "Miss Penalty")
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

#figure(
  image("figures/big-picture-multiprocessor.png", width: 100%),
  caption: "Big picture of multiprocessors",
)

Multiprocessors now play a major role from embedded to high end general-purpose computing. The main goal of Multiprocessors is to achieve *high-end performance, scalability, and reliability*. Multiprocessors focus on exploiting *thread-level parallelism (TLP)*, which is the parallelism that arises from having multiple threads of execution in a program.

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
  P & = "Number of nodes"            \
  M & = "Number of links"            \
  b & = "Bandwidth of a single link" \
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

#figure(
  image("figures/MESI-status-transformation.png", width: 80%),
  caption: "MESI Protocol State Transitions",
)

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
A _*directory protocol*_ is a cache coherence protocol that uses a centralized directory to track the state of each cache line and its copies across multiple caches.

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
    table.header()[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Shared], [0 1 0 0],
  )

When a block is in the shared state, the copy in memory is up to date, so the possible requests are
- *Write Miss from local cache (ex. N1):* Requested data are sent by Data Value Reply from home memory N0 to local cache C1 and N1 becomes the owner node. The block is made M to indicate that the only valid copy is cached. Sharer bits indicate the identity of the owner of the block. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header()[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Modified], [0 1 0 0],
  )

=== Shared State
When a directory block B0 in home N0 is in the *shared state*, the memory value is up to date, we can have: #table(
  columns: (0.4fr, 1fr, 1fr),
  table.header()[Block][Coherence State][Sharer / Owner Bits],
  [B0], [Modified], [0 1 0 0],
)
- *Read Miss from local cache (ex. N2):* Requested data are sent by *Data Value Reply* from home memory N0 to local cache C2 and the requestor (ex. N2) is added to the Sharer bits. The state of the block stays *S*. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header()[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Shared], [0 1 1 0],
  )
- *Write Miss from local cache (ex. N2):* Requested data are sent by *Data Value Reply* from home memory N0 to local cache C2. Invalidate messages are sent from home N0 to remote sharer(s) (P1) and bits are set to the identity of requestor (P2 owner). The state of the block becomes *M*. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header()[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Modified], [0 0 1 0],
  )

=== Modified State
When a directory block B0 in home N0 is in the *M state*, the current value of the block is held *in the cache* of the *owner* processor (ex. P1) identified by the sharer bits, so 3 possible requests can occur: #table(
  columns: (0.4fr, 1fr, 1fr),
  table.header()[Block][Coherence State][Sharer / Owner Bits],
  [B0], [Modified], [0 1 0 0],
)
- *Read Miss from local cache (ex. N2):* To the owner node P1 is sent a *Fetch* message, causing state of the block in the owner's cache to transition to S and the owner send data to the home directory (through *Data Write Back*); data written to home memory are sent to requesting cache N2 by *Data Value Reply*. The identity of the requesting processor (P2) is added to the Sharers set, which still contains the identity of the processor that was the owner (since it still has a readable copy). Block state in directory is set to S. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header()[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Shared], [0 1 1 0],
  )
- *Data Write-Back from remote owner:* The owner cache is replacing the block and therefore must write it back to home. This make the memory copy up to date (the home dir. becomes the *owner*), the block becomes U, and the Sharer set is empty. #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header()[Block][Coherence State][Sharer / Owner Bits],
    [B0], [Uncached], [],
  )
- *Write Miss local cache (ex. N2)*: A *Fetch/Inv*. msg is sent to the *old owner* (ex. N1) causing to *invalidate* the cache block and the cache C1 to send data to the home directory (*Data Write Back*), from which the data are sent to the requesting node N2 (*Data Value Reply*), which becomes the new owner. Sharer is set to the identity of the new owner, and the state of the block remain M (but owner changed) #table(
    columns: (0.4fr, 1fr, 1fr),
    table.header()[Block][Coherence State][Sharer / Owner Bits],
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

