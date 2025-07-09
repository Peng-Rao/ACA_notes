#import "@local/simple-note:0.0.1": *
= Cache Coherence
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
  image("../figures/cache-coherence-problem.jpg", width: 100%),
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
  image("../figures/snoop.jpg", width: 100%),
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
  image("../figures/MESI-status-transformation.png", width: 80%),
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
  image("../figures/distributed-directory.jpg", width: 80%),
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
  image("../figures/the-message-to-maintain-coherence.jpg", width: 80%),
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
- *Read Miss from local cache (ex. N2):* To the owner node P1 is sent a *Fetch* message, causing state of the block in the owner's cache to transition to S and the owner send data to the home directory (through *Data Write Back*); data written to home memory are sent to the requesting cache N2 by *Data Value Reply*. The identity of the requesting processor (P2) is added to the Sharers set, which still contains the identity of the processor that was the owner (since it still has a readable copy). Block state in directory is set to S. #table(
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
