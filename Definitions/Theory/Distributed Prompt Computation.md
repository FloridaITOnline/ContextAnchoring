# Distributed Prompt Computation

**Justin Rodriguez**  
**2026**  
**Version 1.1**
**GPL v3 Open Framework**

## License

This work is licensed under the GNU General Public License v3.0 (`GPL-3.0`).

You are free to:

- Use
- Share
- Modify
- Distribute

Under the condition that all derivative works:

- Remain open source
- Retain attribution
- Preserve the same GPL v3 license

Full license text: <https://www.gnu.org/licenses/gpl-3.0.en.html>

## Overview

As prompt-native systems grow in complexity, computation must extend beyond a single context window. Distributed Prompt Computation enables reasoning to scale across multiple isolated contexts while preserving structure, validation, and control.

Traditional Context Anchoring operates within a single context window, where Anchors, Gates, and Audits define a self-contained runtime.

Distributed Prompt Computation extends this model:

- Each prompt becomes an execution node
- The orchestrator becomes the scheduler
- Anchors become the message bus

This enables complex systems to scale beyond the limits of a single attention window while maintaining structured reasoning.

## Core Concept

Distributed Prompt Computation is a model in which:

- Independent context windows act as isolated execution nodes
- A central orchestrator coordinates execution
- Structured outputs (anchors) are passed between nodes as state

Unlike traditional distributed computing:

- Nodes do not share memory
- Nodes do not execute identical code
- Nodes perform independent reasoning tasks

Instead, this system distributes reasoning itself, not just data.

## System Model

### Components

| Component | Role |
|---|---|
| Node (Prompt) | Independent execution unit with its own context window |
| Anchor | Structured state passed between nodes |
| Gate | Reasoning function executed within a node |
| Orchestrator | Controls flow, routing, and decision-making |
| Loop | Iterative refinement and feedback mechanism |

### Execution Model

1. The orchestrator sends structured input to a node.
2. The node executes Gates within its context.
3. The node produces structured output (anchors).
4. Output is returned to the orchestrator.
5. The orchestrator evaluates, routes, or transforms state.
6. The process repeats across nodes.

## Example: Orchestrated Multi-Context Execution

### Scenario

A system processes input using multiple context windows:

- PowerShell invokes an LLM
- The LLM executes a prompt and produces output
- The orchestrator reads output
- The orchestrator spawns another prompt
- The loop continues

### Interpretation

| Step | System Behavior |
|---|---|
| Invoke | New context window created |
| Execute | Prompt runs as isolated node |
| Output | Structured result returned |
| Route | Orchestrator decides next action |
| Loop | System continues refinement |

## Key Insight

The orchestrator does not need to retain full state. It externalizes state across nodes and reassembles it through structured outputs.

This allows systems to:

- Avoid context window limits
- Distribute reasoning workload
- Maintain modular execution

## State Distribution Model

In traditional systems:

- State is centralized in memory or a database

In Distributed Prompt Computation:

- State is fragmented and externalized

Each node:

- Receives only relevant anchors
- Produces partial state
- Does not retain global memory

The orchestrator:

- Aggregates state
- Selects relevant context
- Re-injects state into future nodes

## Moving State Between Prompts

Prompts do not share a context window. If one prompt produces information that another prompt needs, that information must be written somewhere the next node can access and then intentionally loaded into its runtime.

There are two practical ways to do this:

1. Store structured state in a database such as PostgreSQL.
2. Store structured state as files in a known directory.

These methods can also be used together. A database is useful for larger collections, metadata, filtering, retrieval, and semantic search. A directory of Markdown files is useful for visible state, small registries, flags, dynamic variables, task handoffs, and instructions that an operator may want to inspect directly.

The storage layer does not become active state by itself. The orchestrator or skill must retrieve the required data and inject it into the next prompt.

The complete state-transfer path is:

```text
NODE OUTPUT
    -> VALIDATE
    -> SERIALIZE
    -> STORE
    -> LOCATE
    -> LOAD
    -> VALIDATE AGAIN
    -> INJECT INTO NEXT NODE
```

Each transition is a possible failure boundary. The state may be malformed, stored in the wrong location, retrieved with the wrong scope, or omitted from the next prompt. For that reason, state transfer should be controlled by Anchors, Gates, and optional Loops.

### PostgreSQL as Durable Anchor Storage

PostgreSQL can store durable Anchor data and the metadata needed to retrieve it. With `pgvector`, the system can also perform semantic retrieval when exact names or identifiers are not enough.

A stored Anchor record may include:

- Anchor identifier
- Anchor type
- Content
- Source node
- Destination or permitted consumers
- Created and updated timestamps
- Version
- Validation status
- Task or session identifier
- Retrieval metadata
- Optional embedding

PostgreSQL does not decide what should become an Anchor or when it should be loaded. The agentic application must decide what to store, what to retrieve, and how much retrieved state should be injected into the next runtime.

### Markdown Files as Flags and Dynamic Variables

A simpler implementation can use a known directory containing Markdown files.

For example:

```text
runtime_state/
|-- skills_registry.md
|-- current_task.md
|-- source_location.md
|-- analysis_complete.md
`-- handoff.md
```

These files can act as:

- Runtime flags
- Dynamic variables
- Validated Anchor state
- Agent handoff messages
- Skill registries
- Paths to durable artifacts
- Instructions for retrieving other data

A node can write a Markdown file agentically. A skill loaded by the next node can tell the agent where the file is located, how to interpret it, and whether it may update the file.

The file should use a predictable structure. At minimum, it should identify:

- What the state represents
- Which node wrote it
- Which task or session it belongs to
- Whether it is read-only or writable
- When it was updated
- Whether it passed validation

Markdown is useful because it is readable by both the agent and the operator. It should not be used to store secret values. Secret identifiers and retrieval instructions may be referenced in Markdown, but secret values should remain in a secret manager and be retrieved only when required.

## Skills as Runtime Anchors

Skills can be ingested as part of the state required by an agentic node.

A skill contains specialized instructions, tools, or procedures that help place an agent into the correct operational state for a task. Because a new session may not have the required task-specific capabilities loaded, the runtime should not assume that every needed skill is present.

A **Skills Registry Anchor** can define which skills must be available before work begins.

The root Anchor can be labeled `A`:

```text
ANCHOR A - REQUIRED SKILLS REGISTRY

Objective:
Load and confirm the skills required for this node before executing task logic.

Required State:
- Every required skill is discoverable.
- Every required skill has been loaded or made available to the session.
- The agent understands the purpose and operating boundary of each skill.
```

The Gates associated with Anchor `A` can be labeled `A01`, `A02`, and `A03`. In this notation, `A01` means Gate 01 for Anchor A. It does not represent a separate Anchor.

For example:

```text
A01 - DATA RETRIEVAL SKILL GATE
Description:
Load the skill that retrieves the required source data and returns it in the
expected handoff format.

A02 - DATA VALIDATION SKILL GATE
Description:
Load the skill that checks source completeness, schema, and retrieval errors.

A03 - DATA ANALYSIS SKILL GATE
Description:
Load the skill that performs the higher-reasoning analysis after the retrieved
data has passed validation.
```

This numbering keeps the Gate visibly associated with its controlling Anchor. Additional Anchors can use their own prefixes and Gate sequences.

### Skill Implementation

The skill should define:

- What it does
- When it should be used
- What input it requires
- Which tools or APIs it may call
- Where it reads or writes state
- What output it returns
- How failure is reported

Python is a practical default for many agentic skills because it works well with APIs, structured data, validation libraries, and automation. It should not be treated as a fixed requirement. The implementation language should match the task, environment, security requirements, and available tooling.

The important part is not the language. The important part is that the skill exposes a bounded and testable capability to the runtime.

## Skill Confirmation Loops

Each Skills Registry Gate may have an optional Loop. This is especially useful when the agent will make decisions without an operator checking every step.

For skill initialization, the Loop has two parts:

1. **Test:** Determine whether the required skill and its instructions are available and understood.
2. **Confirmation:** Return evidence that the Gate completed successfully.

The confirmation may be simple or complex.

A simple confirmation may be:

```text
A01_STATUS = TRUE
```

A stronger confirmation may require the agent to:

- Return the discovered skill name and version
- Identify the expected input and output
- Locate the required Markdown state file
- Confirm access to the required tool or API
- Answer a small task-specific validation question
- Execute a harmless connectivity or schema test

Example:

```text
LOOP A01-L

TEST:
Confirm that the data retrieval skill is discoverable, its instructions have
been loaded, and the required source location is available.

CONFIRMATION:
Return the skill identifier, source location, expected output schema, and
A01_STATUS = TRUE.

ON FAILURE:
Reload Gate A01 and its referenced skill instructions. If the skill is still
unavailable, return A01_STATUS = FALSE and stop dependent Gates.
```

The Loop should not claim success only because the agent says that it understands the skill. When possible, the confirmation should test something observable.

For advanced skills, the Test section can use software engineering testing theory:

- **Equivalence Partitioning** tests a representative member from each expected input or behavior class.
- **Boundary Theory** tests missing data, invalid state, maximum useful context, unavailable tools, conflicting instructions, and other edges where the skill may fail.

These tests make the Loop behave more like a plain-language unit test. The Confirmation becomes the assertion result. If the assertion fails, the runtime can reload the Gate, reload the skill, request missing state, choose another route, or stop safely.

## Skills Registry Initialization Flow

The Skills Registry Anchor should be initialized before task-specific compute begins.

```text
START NEW NODE
    -> LOAD ANCHOR A: REQUIRED SKILLS REGISTRY
    -> RUN A01: LOAD DATA RETRIEVAL SKILL
    -> RUN A01-L: TEST AND CONFIRM
    -> RUN A02: LOAD DATA VALIDATION SKILL
    -> RUN A02-L: TEST AND CONFIRM
    -> RUN A03: LOAD DATA ANALYSIS SKILL
    -> RUN A03-L: TEST AND CONFIRM
    -> CONFIRM ANCHOR A
    -> BEGIN TASK GATES
```

If one required Gate fails its confirmation, Anchor A has not loaded successfully. The node should not continue into dependent task logic unless the runtime defines a safe fallback.

This matters because a session can be stateless with respect to the required skill configuration. Without an explicit registry and confirmation process, a skill may be missed even when the task depends on it.

## Model Selection and Specialized Nodes

Distributed Prompt Computation allows each node to use a model appropriate for its specific work.

For example:

- A data retrieval node may use a smaller model because its work is bounded by a specific skill, API, and output schema.
- A validation node may use deterministic tools with a smaller model coordinating the checks.
- An analysis node may use a more capable model because it must compare evidence, resolve ambiguity, or perform complex reasoning.

More capable models may have higher token or execution costs. Sending every stage to the largest model can waste compute without improving every result.

Specialized nodes make it possible to:

- Choose the right model for the task
- Reduce unnecessary token use
- Improve stability through narrower context
- Isolate failures to one runtime
- Scale beyond one session's context boundary
- Reuse the same skills across different agent workflows

Each prompt becomes a Compute Runtime dedicated to a specific task. The orchestrator selects the model, Anchors, Gates, Loops, skills, and stored state required to initialize that runtime.

## Anchor Transfer Envelope

Whether state is stored in PostgreSQL or Markdown, a receiving node should get a predictable transfer envelope.

```text
ANCHOR_TRANSFER

Anchor_ID: A-SKILLS-001
Anchor_Type: Skills Registry
Source_Node: Parent Orchestrator
Destination_Node: Analysis Agent
Task_ID: TASK-001
Version: 1
Access: Read Only
Validation_Status: Passed
State_Location: runtime_state/skills_registry.md
Required_Gates: A01, A02, A03
Required_Confirmations: A01-L, A02-L, A03-L
On_Failure: Stop dependent task Gates and report the failed confirmation
```

The exact syntax may be Markdown, JSON, YAML, or a database record. The important requirement is that the receiving node can determine what it received, where it came from, what it may do with it, and how to confirm that the state loaded correctly.

## Control Flow and Orchestration

Control flow is not implicit; it is explicitly managed.

The orchestrator defines:

- Execution order
- Conditional routing
- Loop termination
- Error handling

This creates a system where control flow exists outside individual prompts and is instead enforced at the orchestration layer.

## Boundaries and Constraints

Distributed Prompt Computation operates within several constraints:

### Context Stability Envelope (CSE)

Each node must operate within a stable portion of its context window.

### Serialization Requirement

State must be:

- Structured
- Interpretable
- Reusable

### Latency Tradeoff

More nodes increase:

- Latency
- Orchestration complexity

### Drift Risk

Each node introduces:

- Interpretation variance
- Reasoning divergence

Boundary Theory applies across nodes: failure can occur at any transition point.

## Relation to Existing Models

Distributed Prompt Computation shares characteristics with:

| Model | Similarity |
|---|---|
| Actor Model | Independent agents passing messages |
| Microservices | Isolated services with defined interfaces |
| MapReduce | Distributed processing with aggregation |
| Agent Systems | Autonomous reasoning units |

However, it differs fundamentally:

- Language is the runtime
- Reasoning is the computation

## Applied Example: Context Anchored Chess System

A single-node system:

`PGN -> JSON -> CSV -> Commentary -> UX`

Distributed version:

- Node 1: PGN parsing
- Node 2: JSON validation
- Node 3: CSV transformation
- Node 4: Commentary generation
- Node 5: UX interaction

Each node:

- Receives anchors
- Executes gates
- Returns structured output

The orchestrator:

- Coordinates flow
- Maintains system coherence

## Why It Matters

Distributed Prompt Computation enables:

- Scaling beyond context window limits
- Modular reasoning systems
- Separation of concerns across prompts
- Reusable reasoning components

It transforms prompt engineering into system orchestration across language-based execution nodes.

## Key Principle

> Computation no longer resides in a single prompt, but emerges from the coordination of multiple reasoning contexts.

## Final Interpretation

Context Anchoring proved that prompts can behave like programs.

Distributed Prompt Computation proves that prompts can behave like distributed systems.

## Author

**Justin Rodriguez**  
**Context Anchoring Framework**  
**Florida IT Online LLC**  
**GPL v3 Open Framework**
