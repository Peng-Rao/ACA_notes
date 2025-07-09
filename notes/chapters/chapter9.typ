#import "@local/simple-note:0.0.1": *
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
The first access to a block is not in the cache, so the block must be loaded in the cache from the main memory. Also called *_cold start miss_* or _first reference miss_. There are compulsory misses even in an infinite cache: they are independent of the cache size.

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
  image("../figures/cache-structure.jpg"),
  caption: "Cache Structure",
)

#pagebreak()

== Cache Placement
There are three categories of cache organization:
- If each block has only one place it can appear in the cache, the cache is said to be _*direct mapped*_. The mapping is usually #align(center)[(Block address) MOD (Number of blocks in cache)]
- If a block can be placed anywhere in the cache, the cache is said to be _*fully associative*_.
- If a block can be placed in a restricted set of places in the cache, the cache is *_set associative_*. A set is a group of blocks in the cache. A block is first mapped onto a set, and then the block can be placed anywhere within that set. The set is usually chosen by _bit selection_; that is, #align(center)[(Block address) MOD (Number of sets in cache)]

#figure(
  image("../figures/cache-placement.jpg", width: 80%),
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
  image("../figures/direct-mapped-cache.jpg", width: 60%),
  caption: "Direct Mapped Cache",
)

For *Fully Associative Cache*, the memory block can be placed in any position of the cache, all the cache blocks must be checked during the search of the block. The index does not exist in the memory address, there are the tag bits only

#figure(
  image("../figures/fully-associative-cache.jpg", width: 60%),
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
*Local Miss rate:* Misses in this cache divided by the total number of memory accesses to this cache: the Miss $"rate"_"L1"$ for L1 and the Miss $"rate"_"L2"$ for L2

*Global Miss rate:* Misses in this cache divided by the total number of memory accesses generated by the CPU:
- For L1, the global miss rate is still just $"Miss Rate"_"L1"$
- For L2, it is $"Miss Rate"_"L1" times "Miss Rate"_"L2"$

#pagebreak()
