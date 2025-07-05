#import "@local/simple-note:0.0.1": *

= Branch Prediction
There are two types of methods to deal with the performance loss due to branch hazards:
+ *Static Branch Prediction Techniques*: The prediction (taken/untaken) for a branch is fixed at *compile time* for each branch during the entire execution of the program.
+ *Dynamic Branch Prediction Techniques*: The prediction (taken/untaken) for a branch can change *at runtime* during the program execution.

#definition("Branch Target Address")[
  The *Branch Target Address* is the address where to branch. If the branch condition is satisfied, the branch is taken and the branch target address is stored in the *Program Counter (PC)*.
]

== Static Branch Prediction
*Static Branch Prediction* is a simple method that assumes the prediction is *fixed* at *compile time* by using some *heuristics* or compiler hints --- rather than considering the runtime execution behavior. It is typically an effective method when the branch behavior for the target application is *highly predictable* at compile time.

=== Branch Always Not Taken
It is the easiest prediction, *we assume the branch will be always not taken*, thus the instruction flow can continue sequentially as if the branch condition was not satisfied. And it is suitable for `IF-THEN-ELSE` conditional statements, when the `THEN` clause is the most probable and the program will continue sequentially.

#figure(
  image("../figures/branch-not-taken.jpg", width: 80%),
  caption: "Branch Always Not Taken Prediction",
)

First, we predict the branch not taken at the end of the `IF` stage.
- If the branch outcome at the end of `ID` stage will be not taken $arrow.double.long$ the *prediction was correct* and there is *no branch penalty cycles*.
- If the branch outcome at the end of `ID` stage will be taken $arrow.double.long$ the *prediction was incorrect*. In this case, we need to *flush* the instruction already fetched (it is turned into a `nop`) and need to *fetch* the instruction at the branch target address $arrow.double.long$ *one branch penalty cycle*.

=== Branch Always Taken
Prediction taken at the end of the `IF` stage.
- If the branch outcome at the end of `ID` stage will be taken $arrow.double.long$ *the prediction was correct* $arrow.double.long$ *no branch penalty cycles*.
- If the branch outcome at the end of `ID` stage will be not taken $arrow.double.long$ *misprediction*. In this case, we need to *flush* the instruction already fetched (it is turned into a `nop`) and need to *fetch* the next instruction $arrow.double.long$ *one branch penalty cycle*.

#figure(
  image("../figures/branch-always-taken.jpg", width: 80%),
  caption: "Branch Always Taken Prediction",
)

#example("Branch Probability")[
  *Backward-going branches* are mostly *taken*. Example: ranches at the end of `DO-WHILE` loops going back at the beginning of the next iteration.
  \
  *Forward-going branches* are mostly *not taken*. Example: branches of `IF-THEN-ELSE` conditional statements when the conditions associated to the `ELSE` label as less probable.
]

#pagebreak()

== Dynamic Branch Prediction
The basic idea is to use the past branch behavior to predict at runtime the future branch behavior.
- We use the hardware to *_dynamically predict_* the outcome of a branch.
- The prediction will depend on the runtime behavior of the branch.
- The prediction will change at runtime if the branch changes its behavior during execution.

Dynamic branch prediction is based on two interacting hardware blocks:
+ *Branch Outcome Predictor* (BOP) or *Branch Prediction Buffer*: To predict the direction of a branch (Taken or Not Taken).
+ *Branch Target Predictor* or *Branch Target Buffer* (BTB): To predict the branch target address in case of taken branch
They are placed in the *Instruction Fetch stage* to predict the next instruction to read in the Instruction Cache

#figure(
  image("../figures/dynamic-branch-prediction.jpg", width: 60%),
  caption: "Dynamic Branch Prediction",
)

=== Branch History Table
One implementation of that approach is a *branch prediction buffer* or *branch history table*. A branch prediction buffer is a small memory indexed by the lower portion of the address of the branch instruction. The memory contains a bit that says whether the branch was recently taken or not.

The behavior is controlled by a *Finite State Machine* with only 1-bit of history (2 states) to remember the last direction taken by the the branch to predict the next branch outcome.

*Finite State Machine* with only 1-bit of history to remember the last direction taken by the branch:
- If the prediction is correct $arrow.double.long$ remains in the current status (and branch prediction outcome)
- If the prediction is not correct $arrow.double.long$ changes the status (and branch prediction outcome)

#figure(image("../figures/finite-state-machine.jpg", width: 80%))

Table containing 1 bit for each entry that says whether the branch was recently *taken* or *not taken*. *Table indexed by* the lower portion k-bit of the address of the branch instruction. (For locality reasons, we would expect that the most significant bits of the branch address are not changed.)

The table has *no tags* (every access is a hit) and the prediction bit may have been put there by another branch with the same low-order address bits: but it doesn't matter. The prediction is just a hint!

The misprediction occurs when the prediction is incorrect for that branch.

#figure(
  image("../figures/1-bit-branch-history-table.jpg", width: 80%),
  caption: "1-bit Branch History Table",
)

The shortcoming of 1-bit branch history table: *In a loop branch*, a branch is almost always T and then NT once at the exit of the loop. The 1-bit BHT causes 2 mispredictions:
- At the last loop iteration, since the prediction bit is T, while we need to exit from the loop.
- *When we re-enter the loop, at the first iteration we need to take the branch to stay in the loop*, while the prediction bit was flipped to NT on previous execution of the last iteration of the loop.

#example("shortcoming of 1-bit BHT")[
  Assuming the `for loop for (int i = 0; i < 10; i++) `is within the function `foo()`, this loop will run every time `foo()` is called.

  In the first execution:
  #table(
    columns: (auto, auto, auto, auto),
    align: horizon,
    table.header([*Iteration*], [*Actual Branch*], [*BTH prediction*], [*Result*]),

    [1-9], [Taken(T)], [Taken(T)], [✅],
    [10], [Not Taken (NT)], [Taken(T)], [❌],
  )
  If `foo()` is called again, this loop starts again.
  #table(
    columns: (auto, auto, auto, auto),
    align: horizon,
    table.header([*Iteration*], [*Actual Branch*], [*BTH prediction*], [*Result*]),

    [1], [Taken(T)], [Not Taken (NT)], [❌],
    [2-9], [Taken (T)], [Taken(T)], [✅],
    [10], [Not Taken (NT)], [Taken(T)], [❌],
  )
  During the first iteration of the new cycle, BHT is still Not Taken (NT) (because it remembers the exit condition of the last cycle). But in fact, we hope to continue the loop (T), so the prediction of Not Taken (NT) occurred an error, leading to the second false prediction.
]

The solution to this problem is to use a *2-bit branch history table*---The prediction must mispredict twice before it is changed!

#figure(
  image("../figures/2-bit-BHT-scheme.jpg", width: 80%),
  caption: "2-bit Branch History Table",
)

=== Branch Target Buffer
*Branch Target Buffer* (Branch Target Predictor) is a cache storing the Predicted Target Address (PTA) for the taken-branch instructions. The PTA is expressed as PC-relative. The BTB is used in combination with the Branch History Table in the *IF stage*.

Usually, it is combined with a *Branch Outcome Predictor* such as a 1-bit (or 2-bit) Branch History Table.

#figure(
  image("../figures/branch-target-buffer.jpg", width: 80%),
  caption: "Branch Target Buffer",
)

#example("Dynamic branch prediction of for loop")[
  Let's consider the following `for loop`:
  ```c
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 5; j++) {
      // do something
    }
  }
  ```
  #figure(
    image("../figures/dynamic-branch-prediction-for-loop.png", width: 80%),
    caption: "Dynamic Branch Prediction of For Loop",
  )
  For the outer loop1, we have 9 mispredictions. For the inner loop2, we have 1 mispredictions. The total number of mispredictions is $9 + 1 times 10 = 19$.
]

=== Correlating Branch Predictors
The 2-bit BHT uses only the recent behavior of a single branch to predict the future behavior of that branch.

*Basic Idea*: the behavior of recent branches are correlated, that is the recent behavior of *other branches* rather than just the current branch (we are trying to predict) can influence the prediction of the current branch.

We try to exploit the correlation existing among different branches: branches are partially based on the same conditions(they can generate information that can influence the behavior of other branches).

Branch predictors that use the behavior of other branches to make a prediction are called *Correlating Predictors* or *2-level Predictors*.

#figure(
  image("../figures/2-level-predictors.jpg", width: 60%),
  caption: "2-level Predictors",
)

Record if the most recently executed branches have been *taken* or *not taken*. The branch is predicted based on the previous executed branch by selecting the appropriate 1-bit BHT:
- One prediction is used if the last branch executed was *taken*
- Another prediction is used if the last branch executed was *not taken*

In general, the last branch executed is not the same instruction as the branch being predicted (although this can occur in simple loops with no other branches in the loops).

#pagebreak()
