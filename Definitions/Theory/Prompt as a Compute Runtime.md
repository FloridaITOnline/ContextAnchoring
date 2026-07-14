# Prompt as a Compute Runtime

**Justin Rodriguez**  
**July 13, 2026**  
**Version 1.0 - GPL v3 Open Framework**

## Abstract

When a model session begins, it does not begin with the task-specific operational state required to perform specialized work. It has a model, a context window, instructions, and whatever information is provided to it. The model must use that context to decide how to approach the task.

This means the prompt is more than a request. It is part of the compute runtime.

The prompt initializes the working state of the session, supplies logic, establishes constraints, and defines how results should be tested. Context Anchoring gives us a way to design this runtime using **Anchors**, **Gates**, and **Loops**. Equivalence Partitioning and Boundary Theory give us a way to test it using plain-language logic rather than only code and variables.

This becomes especially useful when working with agents and subagents. A subagent can be given a smaller, more specific runtime for the work it is expected to conduct. This can reduce unnecessary context, save tokens, improve output quality, and make failures easier to troubleshoot.

---

## 1. The Session Has to Start Somewhere

Every model session has to begin with some amount of context.

The underlying model may contain broad learned capabilities, but the session does not automatically contain the specific objective, state, rules, boundaries, or testing logic required for the current task. Those things must be established inside the session.

The model then has to make decisions based on what it has been given.

This is why prompt construction matters. If the session begins with incomplete state, unclear logic, or competing instructions, the model may still produce an answer, but it may not operate in the state we intended.

The prompt is how we initialize that state.

In simple tasks, one instruction may be enough. In complex tasks, the session may need:

- A defined objective
- Domain knowledge
- Constraints
- Current state
- Decision logic
- Output contracts
- Validation rules
- Stop conditions

Together, these elements form a temporary execution environment inside the model's context window.

---

## 2. Defining the Prompt Compute Runtime

A **Prompt Compute Runtime** is the active context in which a model interprets instructions, applies reasoning logic, maintains task state, and produces outputs.

It can be understood through the following comparison:

| Traditional Computing Concept | Prompt Runtime Equivalent |
|---|---|
| Runtime environment | Active model session and context window |
| Program state | Anchored context |
| Variables or registers | Anchors |
| Functions | Gates |
| Control flow | Gate order and orchestration |
| Iteration | Loops |
| Assertions and unit tests | Audits, Equivalence Partitions, and Boundary Tests |
| Program output | Generated artifact or updated anchored state |

This is not a claim that natural language executes with the same determinism as compiled code. A language model remains stochastic. The purpose of the comparison is to give us a practical way to design and troubleshoot the environment in which the model is making decisions.

The language is the logic. The context is the working space. Inference is the execution process.

---

## 3. Context Anchoring Object Hierarchy

The Prompt Compute Runtime is organized around three core primitives:

```text
ANCHOR(S) -> GATE(S) -> LOOP (optional) -> UPDATED ANCHOR(S)
```

These objects do not have equal rank.

The **Anchor** is the highest-ranking object because it defines the state that the associated logic depends on. A **Gate** reads, tests, transforms, or updates that state. A **Loop** controls when the Gate must be tested or reapplied.

### 3.1 Anchors: The Highest-Ranking Objects

An Anchor is a named context object that identifies what must remain stable or available during execution.

An Anchor may contain:

- The main objective
- A behavioral contract
- Domain knowledge
- Input data
- Constraints
- Current progress
- A previously validated result
- State returned from another agent

Anchors can be static, dynamic, or derived.

- **Static Anchors** define information that should not change during the task.
- **Dynamic Anchors** track information that changes as work progresses.
- **Derived Anchors** contain validated outputs produced by Gates.

Because the Anchor defines the state, the logic should reference it directly. If a Gate cannot identify the Anchor it reads or updates, the logic may be too broad or insufficiently defined.

### 3.2 Gates: Logic Associated with Anchors

A Gate is a bounded section of logic associated with one or more Anchors.

A Gate may:

- Make a decision
- Transform data
- Generate an artifact
- Validate a result
- Compare output against a contract
- Update an Anchor
- Reject invalid input

The basic form is:

```text
GATE(ANCHOR INPUT) -> OUTPUT OR UPDATED ANCHOR
```

Keeping Gates bounded makes the runtime easier to understand. If a result is wrong, we can inspect the Anchor that supplied the state and the Gate that applied the logic. We do not have to troubleshoot one large block of instructions as if every part failed at once.

### 3.3 Loops: Testing and Reapplying Logic

A Loop determines when one or more Gates should run again.

Loops are useful when:

- Output fails validation
- Required state is missing
- A boundary condition is detected
- The result does not meet the output contract
- Refinement is required
- The session must reapply an Anchor after drift

A Loop needs a clear stop condition. Without one, the model may continue refining without meaningfully improving the result, consume unnecessary tokens, or drift away from the original objective.

A useful Loop answers four questions:

1. What result is being tested?
2. Which Gate performs the test?
3. What logic is reapplied when the test fails?
4. What condition stops the Loop?

---

## 4. Initializing the Intended Operational State

The model is stateless with respect to the new task at the beginning of a fresh session. The purpose of runtime initialization is to place the session into the operational state needed for the work.

This does not train or permanently change the model. It conditions the current session.

An initialized runtime should provide enough context for the model to answer:

- What am I trying to accomplish?
- What information must remain true?
- What logic should I apply?
- What am I allowed to change?
- What should the output look like?
- How do I know whether the result is acceptable?
- What should happen when validation fails?

The objective is not to include every piece of available information. The objective is to include the **minimum sufficient context** needed to conduct the task reliably.

Too little context creates ambiguity. Too much context consumes runtime capacity and can make the important instructions harder to maintain. Runtime design is therefore a problem of both sufficiency and constraint.

---

## 5. Subagents as Specialized Compute Runtimes

Subagents make this model easier to see.

When a parent agent delegates work, the subagent begins a separate task-specific session. It must receive enough information to understand the work, make the correct decisions, and return a useful result. It does not need every detail available to the parent.

This creates an opportunity to build a specialized Prompt Compute Runtime for each subagent.

For example, a research subagent may need:

- An Objective Anchor
- A Source Quality Anchor
- A Scope Anchor
- A Research Gate
- A Citation Validation Gate
- A Boundary Loop for missing or conflicting evidence

A review subagent may need a different runtime:

- A Requirements Anchor
- An Artifact Anchor
- A Defect Classification Anchor
- A Comparison Gate
- A Severity Gate
- A Loop for rechecking high-risk findings

The prompts can be smaller because each runtime is designed for one bounded class of work. This can save tokens while increasing specificity. It can also improve output because the subagent has less irrelevant context competing with the state and logic that matter.

The parent agent remains the orchestrator. It decides what state to transfer, which runtime to initialize, and how the returned result should be incorporated into the larger workflow.

---

## 6. State Transfer Between Agent Sessions

Subagents do not automatically share one active context. Required state must be transferred intentionally.

State transfer should identify:

- Which Anchors are required by the receiving agent
- Which Anchors are read-only
- Which Anchors the agent may update
- What result schema must be returned
- What validation must occur before the result is accepted

This can be represented as:

```text
PARENT ANCHORS
    -> SELECT REQUIRED STATE
    -> INITIALIZE SUBAGENT RUNTIME
    -> EXECUTE SUBAGENT GATES
    -> VALIDATE RESULT
    -> RETURN DERIVED ANCHOR
    -> UPDATE PARENT STATE
```

This is a form of distributed prompt computation. The total task is divided across multiple bounded sessions, with state transferred between them as structured context and artifacts.

The quality of the result depends on the quality of the transfer. If an important Anchor is omitted, the subagent may perform its local task correctly while still producing a result that is wrong for the larger objective.

---

## 7. Prompt-Native Unit Testing

Traditional unit tests express logic through code, inputs, variables, assertions, and expected outputs.

Prompt-native unit testing can express the same testing intent through plain language and structured syntax.

The goal is not to test whether the model always produces identical wording. The goal is to test whether it applies the intended reasoning behavior across known classes of input and near the boundaries where that behavior may fail.

Two theories are especially useful when writing these tests:

- **Equivalence Partitioning**
- **Boundary Theory**

### 7.1 Equivalence Partitioning

Equivalence Partitioning groups inputs into classes that should activate the same Gate logic.

Instead of testing every possible input, we select representative cases such as:

- A normal valid input
- A valid input with different surface wording
- An invalid input
- An ambiguous input
- An adversarial input

If the same Gate behaves consistently across representative members of the class, we gain evidence that the runtime is stable for that class.

This evidence is not mathematical proof. It is a practical testing method for a stochastic system.

### 7.2 Boundary Theory

Boundary Theory tests the edges where the intended state or logic is most likely to break.

These boundaries may include:

- **Contextual Boundaries:** The amount of context the session can use while retaining stable Anchors
- **Semantic Boundaries:** The line between concepts that are inside and outside the task domain
- **Instructional Boundaries:** The point where instructions become ambiguous, conflicting, or difficult to prioritize
- **Validation Boundaries:** The point where a Gate fails to detect a malformed or incorrect result

Equivalence Partitioning helps identify the stable center of the behavior. Boundary Theory helps identify the edge of failure.

Together, they give us better information for writing Loops.

### 7.3 Writing Better Loop Sections

A Loop should not simply tell the model to try again. It should identify the failure class and reapply the relevant logic.

For example:

```text
ANCHOR A1: Output must match the required JSON schema.

GATE G1: Validate the generated output against A1.

BOUNDARY TESTS:
- Missing required field
- Additional unsupported field
- Invalid value type
- Valid structure with semantically incorrect content

LOOP L1:
If G1 fails, classify the failure, return to the Gate responsible for that
field, regenerate only the failed section, and run G1 again.

STOP CONDITION:
Stop when all required fields pass or when the retry limit is reached.
```

This Loop is useful because it contains a test, a correction path, and a stop condition. It does not depend on a vague request for the model to improve its answer.

---

## 8. The Computation Boundary

There is a limit to how much prompt-native computation can be performed reliably in one session or one section.

The hard limit is the model's context window, but the practical limit may be reached earlier.

The session context must hold some combination of:

- System and developer instructions
- Anchors
- Gate logic
- Loop logic
- Task inputs
- Conversation history
- Tool results
- Intermediate outputs
- Final outputs

All of these consume runtime capacity.

As the session grows, earlier state may become harder for the model to apply consistently. Dense logic may compete for attention. Loops may generate additional intermediate state. A section can therefore become unreliable before the context window is completely full.

This creates a **Computation Boundary**:

> The Computation Boundary is the practical limit at which a session can continue applying its Anchors, Gates, and Loops with acceptable stability.

The boundary is not one fixed token number. It depends on:

- The model
- The complexity of the task
- The density of the instructions
- The number of active Anchors
- The number and depth of Gates
- The amount of task data
- The length of generated outputs
- The number of Loop iterations

Runtime limit is therefore also a design limit.

When a section approaches this boundary, the system can respond by:

- Dividing the work into smaller Gates
- Moving a bounded task to a subagent
- Compressing validated state into a smaller Anchor
- Writing durable state to an external artifact
- Removing irrelevant context
- Starting a new runtime with only the required state

---

## 9. Troubleshooting the Runtime

One benefit of the Anchor, Gate, and Loop hierarchy is that failures can be inspected as logic sections.

When output is wrong, ask:

### Anchor Questions

- Was the required state present?
- Was the Anchor clear?
- Did two Anchors conflict?
- Was the Anchor transferred to the correct agent?
- Did the Anchor remain visible within the computation boundary?

### Gate Questions

- Did the Gate identify its input Anchor?
- Was the Gate responsible for too many transformations?
- Was its output contract testable?
- Did it update state that should have remained read-only?

### Loop Questions

- Did the Loop test a specific failure condition?
- Did it reapply the correct Gate?
- Did it preserve validated state?
- Did it have a clear retry limit or stop condition?
- Did the Loop consume more context than the task justified?

This turns prompt troubleshooting into logic troubleshooting. A developer can adjust one Anchor, Gate, test, or Loop rather than rewriting the entire prompt without knowing what changed.

---

## 10. Reliability Does Not Mean Absolute Determinism

A Prompt Compute Runtime does not make a stochastic model fully deterministic.

Anchors condition state. Gates constrain reasoning. Loops test and reapply logic. Equivalence Partitions and Boundary Tests provide evidence about behavior. These techniques improve repeatability, but they do not create the same guarantees as deterministic code.

A self-audit performed by the same model is useful, but it is not independent proof of correctness.

When a result can be checked externally, stronger runtimes should use:

- JSON schema validation
- Programmatic calculations
- Database constraints
- Source verification
- Tool-based checks
- Separate evaluator sessions
- Human review for high-impact decisions

The prompt-native layer should control the reasoning that language is good at. Deterministic tools should validate the parts that can be tested deterministically.

The practical objective is not perfect determinism. It is a system whose state, logic, tests, and failures are visible enough to improve.

---

## 11. Reference Architecture

```text
PARENT AGENT RUNTIME
|
|-- A0: Overall Objective
|-- A1: Shared Constraints
|-- A2: Current Workflow State
|-- G1: Decompose Work
|-- G2: Select Required State
|
|-- SUBAGENT RUNTIME A
|   |-- Specialized Anchors
|   |-- Task Gates
|   |-- Equivalence Tests
|   |-- Boundary Tests
|   |-- Corrective Loop
|   `-- Structured Result
|
|-- SUBAGENT RUNTIME B
|   |-- Specialized Anchors
|   |-- Task Gates
|   |-- Equivalence Tests
|   |-- Boundary Tests
|   |-- Corrective Loop
|   `-- Structured Result
|
|-- G3: Validate Returned Results
|-- G4: Merge Derived Anchors
`-- FINAL OUTPUT OR DURABLE ARTIFACT
```

Each subagent receives enough context to perform its work, but not necessarily the entire parent runtime. The parent validates the returned state before using it.

This architecture supports token efficiency, specialization, parallel work, and clearer failure isolation.

---

## 12. Worked Example: Documentation Review Subagent

Assume a parent agent needs a subagent to review one technical document.

### Anchors

```text
A0 - Objective: Identify contradictions and missing implementation details.
A1 - Scope: Review only the supplied document and referenced requirements.
A2 - Evidence Rule: Every finding must identify supporting text.
A3 - Output Contract: Return severity, finding, evidence, and recommendation.
```

### Gates

```text
G1 - Parse the document into claims and requirements.
G2 - Compare claims against requirements and internal statements.
G3 - Classify supported findings by severity.
G4 - Validate every finding against A2 and format it using A3.
```

### Equivalence Partitions

```text
EP1 - Requirement is fully addressed.
EP2 - Requirement is partially addressed.
EP3 - Requirement is missing.
EP4 - Two statements contradict each other.
EP5 - Claim cannot be verified from the supplied context.
```

### Boundary Tests

```text
B1 - Requirement is implied but not stated.
B2 - Similar terms are used with different meanings.
B3 - Evidence exists outside the assigned scope.
B4 - Finding appears important but lacks direct support.
```

### Corrective Loop

```text
L1 - Run G4 against every finding.
If evidence is missing, return the finding to G2.
If the finding cannot be supported within A1, classify it under EP5 or remove it.
Stop when all returned findings satisfy A2 and A3.
```

This creates a small runtime for one class of work. The subagent does not need the full history of the parent session. It needs the state, logic, and tests required to conduct the review.

---

## 13. Conclusion

A model session begins without the task-specific operational state needed for specialized work. The prompt initializes that state.

Context Anchoring structures the runtime:

- **Anchors** define and preserve state.
- **Gates** apply bounded logic to that state.
- **Loops** test and reapply logic when required.
- **Equivalence Partitioning** tests representative reasoning classes.
- **Boundary Theory** tests the edges where state and logic may fail.

This is particularly useful for agent and subagent systems. Each subagent can receive a smaller, specific runtime containing only the context needed for its task. This can reduce token usage, improve specialization, and make the system easier to troubleshoot.

The amount of work a runtime can perform is limited by its usable context. Instructions, state, task data, tests, intermediate results, and outputs all compete for the same space. That creates a practical Computation Boundary for every session.

The prompt is not only the question being asked.

It is the temporary runtime in which the model decides how to answer it.

---

**Written by Justin Rodriguez**  
**Context Anchoring Framework**  
**July 13, 2026**  
**License:** GNU General Public License v3.0 or later
