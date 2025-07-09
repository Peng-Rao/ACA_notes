= Vector Architectures
Vector architectures grab sets of data elements scattered about memory, place them into _*large sequential register files*_, operate on data in those register files, and then disperse the results back into memory. A single instruction works on vectors of data, which results in dozens of register-register operations on independent data elements.

== Components of Vector Architectures
- *Vector Registers File: * Each register holds a vector of 64-elements with 64 bits/element. There are (at least) 16 read ports and 8 write ports (to enable up to 8 simultaneous accesses)
- *Vector functional units: * Fully pipelined so they can start a new operation every cycle
- *Vector load-store unit:* Fully pipelined, one word per clock cycle after initial memory latency
- *Scalar registers:* Used for scalar operations and holding temporary values

== Execution of Vector Instructions
We can best understand a vector processor by looking at a vector loop for RV64V. Let's take a typical vector problem, which we use throughout this section:
$
  Y = a times X + Y
$
X and Y are vectors, initially resident in memory, and a is a scalar. This problem is the SAXPY or DAXPY loop. (SAXPY stands for *single-precision* $a times X plus Y$, and DAXPY for *double precision* $a times X plus Y$.)

== Vector Execution Time
Execution time depends on three factors:
- Length of the operand vectors
- Structure hazards
- Data dependences
Functional units consume one element per clock cycle, so the execution time is approximately given by the vector length.

== Operation Chaining
Operation chaining is a technique allows each functional unit (FU) to forward its output to the next FU in the chain. Even though a pair of operations depend on one another, chaining allows the operations to proceed in parallel on separate elements of the vector.

- *Without chaining:* must wait for last element of one instruction to be written before starting the next dependent instruction
- *With chaining:* a dependent operation can start as soon as each element of its vector source operand become available

#pagebreak()
