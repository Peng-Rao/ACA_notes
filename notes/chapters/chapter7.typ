= Multithreading
_*Multithreading*_ allows multiple threads to share the functional units of a single processor in an overlapping fashion. In contrast, a more general method to exploit _*thread-level parallelism (TLP)*_ is with a multiprocessor that has multiple independent threads operating at once and in parallel. Multithreading, however, does not duplicate the entire processor as a multiprocessor does. Instead, multithreading shares most of the processor core among a set of threads, duplicating only private state, such as the registers and program counter.

There are three main hardware approaches to multithreading: _fine-grained_, _coarse-grained_, and _simultaneous multithreading (SMT)_.

#figure(image("../figures/multithreading.jpg"))

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
