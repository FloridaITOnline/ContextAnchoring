# Anchor: Detailed Definition (Context Anchoring)

**Justin Rodriguez**  
**2026**  
**Specification Version 2.0**  
**GPL v3 Open Framework**  
[License: GNU General Public License v3.0 or later](../../LICENSE)

## What Is an Anchor?

> **An Anchor is the highest-ranking Context Anchoring primitive. It is a stable, named state object that preserves essential context across the steps of a task and provides bounded scope for Gates and Loops.**

An Anchor acts like a register of meaning. It identifies the state that the runtime is expected to preserve, reference, validate, or explicitly update.

An Anchor may define:

- What matters
- What must remain true
- What may change
- What must be remembered and respected
- Which Gates and Loops operate on the state
- Where externalized state may be retrieved

Anchors are the core state objects of Context Anchoring.

---

## Core Properties

1. **Named**  
   Every Anchor has an identifier such as `A0`, `A1`, or a semantic name.

2. **Stable**  
   An Anchor remains authoritative within its declared scope until it is explicitly updated, replaced, deactivated, or superseded by a higher-priority instruction.

3. **Scope-Defining**  
   An Anchor declares what is in bounds, what is out of bounds, and where its state applies.

4. **Minimal and Essential**  
   An Anchor should contain only the state required for continuity and correct execution.

5. **Invariant-Aware**  
   An Anchor may define conditions that Gates and Loops are expected to preserve and reapply when drift is detected.

6. **Explicitly Referenceable**  
   Gates, Loops, orchestrators, and other Anchors can refer to it by name.

7. **Composable**  
   Multiple Anchors can be combined to define a larger runtime.

8. **Transferable**  
   Anchor state may be serialized, stored, and loaded into another runtime when its identity, scope, and validation status are preserved.

---

## Why Anchors Exist

Anchors help reduce:

- Context drift
- Forgotten constraints
- Unnecessary re-explanation
- Stepwise loss of intent
- Ambiguity about current state
- Failure risk in long-form reasoning
- Missing state during agent handoffs

Anchors help provide:

- More consistent model behavior
- Bounded scope
- State continuity
- Traceable state updates
- A stable reference for Gates and Loops

Anchors improve repeatability, but they do not make stochastic model inference deterministic.

---

## What Anchors Are Not

Anchors are **not**:

- A full transcript
- A vague preference
- A one-time instruction
- A passive hint
- Unnamed or implicit memory
- Guaranteed protection against hallucination
- Higher in authority than system, developer, safety, or platform instructions
- Automatically persistent across independent sessions

Anchors must be:

- **Explicit**
- **Named**
- **Scoped**
- **Referenceable**

---

## Anchor Types

| Type | Definition | Examples |
|---|---|---|
| **Static** | State expected to remain unchanged during its active scope | Objective, domain, safety rule |
| **Dynamic** | State that may be explicitly updated as work progresses | Score, progress, workflow status |
| **Derived** | Validated state produced by a Gate | Parsed record, approved summary |
| **Externalized** | Serialized Anchor state stored outside the active session | PostgreSQL record, Markdown handoff |
| **Transferred** | Externalized state loaded into another runtime | Subagent task package, consumer handoff |

---

## Anchor Lifecycle

1. **Declaration**  
   Define the Anchor name, content, scope, and mutability.

2. **Activation**  
   Load the Anchor into the active Prompt Compute Runtime.

3. **Reference**  
   Gates and Loops read the Anchor by name.

4. **Validation**  
   Confirm that the Anchor is present, correctly scoped, and suitable for the current task.

5. **Update, Optional**  
   A permitted Gate explicitly changes dynamic state or creates a derived Anchor.

6. **Externalization, Optional**  
   Serialize and store the Anchor outside the session with enough metadata to preserve its identity and scope.

7. **Transfer, Optional**  
   Load validated Anchor state into another Prompt Compute Runtime.

8. **Deactivation**  
   Remove the Anchor from active use when the session ends, its scope expires, or the runtime explicitly deactivates it.

Externalized state may survive session termination. It becomes active Anchor state again only when a later runtime intentionally retrieves, validates, and loads it.

---

## Typical Anchor Categories

| Category | Function | Examples |
|---|---|---|
| **Objective** | Defines the task goal | Draft onboarding email, analyze chess game |
| **Scope or Domain** | Limits content and authority | UI only, finance domain, read-only access |
| **Role** | Defines responsibility and permitted behavior | Producer, consumer, analyst |
| **Difficulty** | Sets complexity | Easy, medium, hard |
| **Format or Structure** | Defines an output contract | JSON schema, Markdown table |
| **State** | Stores evolving information | Score: 2-1, status: READY |
| **Safety Constraint** | Defines required safeguards | No PII, human approval required |
| **Configuration** | Identifies tools, skills, or state locations | Skills registry, database table, file path |

---

## Anchor Structure

Each Anchor should identify:

```text
Name/ID:
Purpose:
Content:
Scope:
Mutability:
Authority:
Associated Gates:
Associated Loops:
Validation Status:
External Location, if any:
```

Not every Anchor requires every field. The name, content, scope, and mutability should always be clear.

---

## Example

```text
ANCHOR A1 - SOURCE DATA HANDOFF

Purpose:
Provide validated source data to the analysis runtime.

Content:
Task_ID: TASK-001
Status: READY
Schema_Version: 1
State_Location: postgresql://openclaw/results/TASK-001

Scope:
Readable by the assigned analysis agent only.

Mutability:
Read-only in the consumer runtime.

Associated Gates:
A1.G01 - Load handoff state
A1.G02 - Validate task identity and schema

Associated Loops:
A1.L01 - Confirm that the handoff is READY before analysis begins
```

This Anchor provides named, bounded, and transferable state. It does not become active in the consumer runtime until its Gates load and validate it.

---

## Relationship to Gates and Loops

```text
ANCHOR -> GATE -> LOOP (optional) -> UPDATED OR DERIVED ANCHOR
```

- The Anchor defines the state.
- The Gate reads, transforms, validates, or updates that state.
- The Loop tests the result and controls the next transition.

---

## Minimal Definition

> **An Anchor is the highest-ranking Context Anchoring primitive: a named, scoped state object that Gates and Loops reference, preserve, validate, or explicitly update.**

---

**Written by Justin Rodriguez**  
**Context Anchoring Framework**  
**Specification Version 2.0**  
**License:** GNU General Public License v3.0 or later
