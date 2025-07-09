= Multiprocessors

#figure(
  image("../figures/big-picture-multiprocessor.png", width: 100%),
  caption: "Big picture of multiprocessors",
)

Multiprocessors now play a major role from embedded to high end general-purpose computing. The main goal of Multiprocessors is to achieve *high-end performance, scalability, and reliability*. Multiprocessors focus on exploiting *thread-level parallelism (TLP)*, which is the parallelism that arises from having multiple threads of execution in a program.

Multiprocessors refers to tightly coupled processors whose coordination and usage is controlled by a single operating system and that usually share memory through a shared address space.

Existing *shared-memory multiprocessors* fall into *two classes*, depending on the number of processors involved, which in turn dictates a memory organization and interconnect strategy.

The first group, which we call *_symmetric (shared-memory) multiprocessors (SMPs)_*, or *_centralized shared-memory multiprocessors_*, features small to moderate numbers of cores, typically 32 or fewer.

SMP architectures are also sometimes called _*uniform memory access (UMA)*_ multiprocessors, arising from the fact that all processors have a uniform latency from memory, even if the memory is organized into multiple banks.

The alternative design approach consists of multiprocessors with physically distributed memory, called _*distributed shared memory (DSM)*_.

Distributing the memory among the nodes both increases the bandwidth and reduces the latency to local memory. A DSM multiprocessor is also called a _*NUMA (nonuniform memory access)*_ because the access time depends on the location of a data word in memory.

*In both SMP and DSM architectures, communication among threads occurs through a shared address space, meaning that a memory reference can be made by any processor to any memory location, assuming it has the correct access rights*.

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
  image("../figures/single-bus.jpg", width: 80%),
  caption: "Single Bus Multiprocessor",
)

#figure(
  image("../figures/single-bus-topology.jpg", width: 80%),
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
  image("../figures/ring-topology.jpg", width: 80%),
  caption: "The topology of a ring multiprocessor",
)

=== Crossbar Network
Crossbar Network or fully connected network: every processor has a bidirectional dedicated communication link to every other processor, and it has a very high cost.

#figure(
  image("../figures/crossbar-topology.jpg", width: 80%),
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
  image("../figures/bidimensional-mesh-topology.jpg", width: 60%),
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
*UMA (Uniform Memory Access)*: The access time to a memory location is *uniform* for all the processors: no matter which processor requests it and no matter which word is asked.

*NUMA (Non Uniform Memory Access)*: The access time to a memory location is *non uniform* for all the processors: it depends on the location of the data word in memory and the processor location.

Multiprocessor systems can have single address space and distributed physical memory. The concepts of addressing space (single/multiple) and the physical memory organization *orthogonal* to each other.

#pagebreak()
