# Loop: Detailed Definition (Context Anchoring)

**Justin Rodriguez**  
**2026**  
**Specification Version 2.0**  
**GPL v3 Open Framework**  
[License: GNU General Public License v3.0 or later](../../LICENSE)

## 📌 What Is a Loop?

> **A Loop is an optional control structure that tests the result of a Gate, confirms whether the required state has been reached, and determines whether logic should continue, be reapplied, be rerouted, or stop.**

A Loop is not repetition by itself.

A Loop contains two essential parts:

1. **Test:** Evaluate output or state against a defined condition.
2. **Confirmation:** Record whether the condition was satisfied and provide the result used to determine the next action.

Loops are the control and correction mechanisms of Context Anchoring.

---

## 🧩 Core Properties

1) **Optional**  
   Not every Gate requires a Loop.

2) **Test-Bound**  
   A Loop evaluates a specific Gate result or Anchor state.

3) **Confirmable**  
   A Loop produces a Confirmation that can be inspected or used by later logic.

4) **Conditional**  
   The next action depends on the result of the Test.

5) **Bounded**  
   A Loop has a stop condition, retry limit, or escalation path.

6) **State-Aware**  
   A Loop preserves validated state and identifies the state that may be changed.

7) **Corrective**  
   On failure, a Loop can reapply a Gate, reload required context, request missing state, or choose another route.

8) **Auditable**  
   The Test, Confirmation, and resulting transition should be visible.

---

## 🎯 Why Loops Exist

Loops help a prompt-native system:

- Test whether a Gate completed successfully
- Confirm that required state is present
- Detect malformed or incomplete output
- Reapply logic after a recoverable failure
- Reload an Anchor or skill when required
- Refine a result without restarting the entire runtime
- Stop execution when continuing would be invalid or unsafe
- Escalate a failure that cannot be corrected inside the session

Loops turn **Gate Results into Controlled Transitions**.

---

## 🚫 What Loops Are Not

Loops are **not**:

- Unrestricted repetition
- A vague instruction to "try again"
- A replacement for an Anchor
- The reasoning transformation performed by a Gate
- Guaranteed proof that an answer is correct
- Permission to continue forever
- A requirement for every Gate

Loops must be:

- **Testable**
- **Confirmable**
- **Bounded**
- **Associated with defined state and logic**

---

## 🏗️ Core Structure

```text
ANCHOR -> GATE -> LOOP TEST -> CONFIRMATION
                         |
                         |-> PASS: Continue or stop successfully
                         |
                         `-> FAIL: Reapply, reroute, escalate, or stop
```

The Anchor defines the required state. The Gate performs the bounded logic. The Loop tests the result and uses the Confirmation to determine what happens next.

---

## 1. The Test

The Test evaluates a Gate result or updated Anchor state against an expected condition.

A Test should identify:

- Which Anchor contains the required state
- Which Gate produced or changed the result
- What condition is expected
- What evidence is required
- What counts as failure
- Which failure class occurred

A Test should not ask only whether the result "looks good." It should define the behavior, structure, fact, state, or boundary being checked.

Example:

```text
TEST:
Confirm that the output contains every required JSON field, that each field
uses the expected data type, and that the values satisfy Anchor A1.
```

---

## 2. The Confirmation

The Confirmation records the result of the Test. The Loop uses that Confirmation to control the next transition.

A Confirmation may be simple:

```text
CONFIRMED = TRUE
```

It may also return structured evidence:

```text
CONFIRMATION
Status: PASS
Gate: G2
Anchor: A1
Schema: VALID
Missing_Fields: NONE
Next_Action: CONTINUE_TO_G3
```

The strength of a Confirmation depends on how it was produced.

From weakest to strongest:

1. The model states `TRUE`.
2. The model explains why the condition passed.
3. The model returns structured evidence.
4. A separate Gate validates the result.
5. An external tool validates the result.
6. A human or authoritative system confirms the result.

A simple Boolean may be sufficient for a low-risk checklist. Higher-risk work should use stronger and more observable evidence.

---

## 🔁 Loop Lifecycle

1) **Gate Execution**  
   A Gate produces output or updates Anchor state.

2) **Test**  
   The Loop reads the result and evaluates a defined condition.

3) **Confirmation**  
   The Loop records PASS, FAIL, or another defined status.

4) **Transition**  
   The runtime continues, retries, reroutes, escalates, or stops.

5) **State Update**  
   Validated results may become updated or derived Anchors.

6) **Termination**  
   The Loop ends when its success, failure, retry, or escalation condition is reached.

---

## 🔠 Typical Loop Types

| Loop Type | Function | Example |
|---|---|---|
| **Validation Loop** | Tests output against a contract | Validate JSON schema |
| **Confirmation Loop** | Confirms required state or capability | Confirm a skill is loaded |
| **Refinement Loop** | Improves a result using defined feedback | Revise one failed section |
| **Retrieval Loop** | Requests missing data or another source | Retrieve a missing record |
| **Recovery Loop** | Restores state after a recoverable failure | Reload an Anchor or Gate |
| **Interactive Loop** | Waits for external input | Continue after user response |
| **Boundary Loop** | Tests behavior near a defined limit | Reject excessive or invalid input |
| **Orchestration Loop** | Controls work across nodes | Poll for a READY handoff state |

---

## 🧱 Loop Contract

A well-defined Loop should answer the following:

```text
Name/ID:
Controlling Anchor:
Gate Being Tested:
Reads:
Test:
Expected Condition:
Confirmation:
On Pass:
On Failure:
Retry Limit:
Preserves:
Returns:
```

Not every Loop needs every field, but the Test, Confirmation, and stop behavior must be clear.

---

## 🔠 Canonical Naming and Association

A Loop should be visibly associated with the Anchor and Gate it controls.

The canonical notation is:

```text
A1       Controlling Anchor
A1.G01   Gate 01 associated with Anchor A1
A1.L01   Loop 01 associated with Anchor A1 and testing Gate A1.G01
```

A compact notation such as the following may appear in older or implementation-specific documents:

```text
A        Controlling Anchor
A01      Gate 01 associated with Anchor A
A01-L    Loop associated with Gate A01
```

The canonical dotted notation should be used in new primitive specifications. If a compact notation is used by an implementation, that implementation must declare the mapping explicitly and use it consistently. A reader should always be able to determine which Anchor supplies the state, which Gate performs the logic, and which Loop tests the result.

---

## 🧪 Plain-Language Unit Testing

Loop Tests can use software engineering testing theory expressed through plain language and structured syntax.

### Equivalence Partitioning

Equivalence Partitioning groups inputs into classes that should activate the same Gate behavior.

A Loop may test representative cases such as:

- Normal valid input
- Valid input with different surface wording
- Invalid input
- Ambiguous input
- Adversarial input

The Loop does not need to test every possible input. It tests representative members of the reasoning classes that matter to the Gate.

### Boundary Theory

Boundary Theory tests the edges where the Gate or Anchor is most likely to fail.

Boundary Tests may include:

- Missing state
- Contradictory state
- Empty input
- Maximum useful input size
- Retry limit reached
- Context boundary approached
- Required skill unavailable
- External tool unavailable
- Valid structure with incorrect meaning
- Handoff state not ready

Equivalence Partitioning identifies the stable center. Boundary Theory identifies the edge of failure. Together, they help the Loop decide when to continue and when to stop.

---

## 🛑 Stop Conditions

Every repeating Loop requires a stop condition.

A Loop may stop when:

- The Test passes
- The objective is reached
- The retry limit is reached
- Required state is unavailable
- A dependency cannot be accessed
- The Computation Boundary is approached
- The failure requires another agent or tool
- Human confirmation is required
- Continuing would overwrite validated state
- Continuing would create unacceptable risk

If a Loop has no stop condition, it is not a controlled Loop.

---

## ⚠️ Loop Anti-Patterns

Avoid Loops that:

- Say only "keep trying until correct"
- Have no retry or termination condition
- Test output without defining the expected state
- Repeat the same Gate without changing input, state, or logic
- Overwrite previously validated Anchors
- Treat model confidence as proof
- Continue after an unrecoverable failure
- Consume more context than the task justifies
- Confirm success without observable evidence when evidence is available

More repetition does not automatically create more reliability. A Loop should make a controlled decision, not create motion without progress.

---

## 🧠 Example: Skills Registry Confirmation

```text
ANCHOR A1 - REQUIRED SKILLS REGISTRY
The data retrieval skill must be available before task execution.

GATE A1.G01 - LOAD DATA RETRIEVAL SKILL
Locate and load the required skill instructions.

LOOP A1.L01

TEST:
Confirm that the skill is discoverable, its instructions have been loaded,
and its required source location can be accessed.

CONFIRMATION:
Return the skill identifier, expected input, expected output, source location,
and A1.G01_STATUS = TRUE.

ON PASS:
Continue to the data retrieval Gate.

ON FAILURE:
Reload A1.G01 once. If the second Test fails, return A1.G01_STATUS = FALSE and stop
all dependent Gates.

RETRY LIMIT:
1

PRESERVES:
All previously validated Anchors.
```

This Loop does more than ask whether the skill loaded. It defines the evidence, corrective action, retry limit, and safe-stop behavior.

---

## 🧠 Example: Producer and Consumer Handoff

```text
ANCHOR A1 - HANDOFF STATE
Expected State: READY

GATE A1.G01 - READ HANDOFF STATUS
Read the assigned PostgreSQL record or Markdown state file.

LOOP A1.L01

TEST:
Confirm that the producer completed the write, the handoff status is READY,
and the stored result matches the expected task identifier and schema.

CONFIRMATION:
Return the task identifier, producer, status, schema result, and record version.

ON PASS:
Load the validated result into the consumer runtime.

ON FAILURE:
Do not consume the result. Retry only if the handoff is still PENDING. Stop if
the state is invalid, expired, or associated with another task.
```

The Loop protects the consumer from reading incomplete, stale, or incorrectly scoped state.

---

## 🖥️ Relationship to the Prompt Compute Runtime

Loops provide control inside and between Prompt Compute Runtimes.

Inside one session, a Loop may test a Gate and update an Anchor. Across multiple sessions, a Loop may inspect durable state, confirm a handoff, reload a skill, or start another node.

Every Loop consumes runtime capacity. Tests, confirmations, tool results, retries, and updated state all use context and tokens. A Loop must therefore remain within the practical Computation Boundary of the session.

When a Loop becomes too large, it may be better to:

- Divide the Test into smaller Gates
- Use an external validation tool
- Save validated state outside the context window
- Transfer the work to a specialized subagent
- Stop the session and initialize a new runtime with only the required Anchors

---

## 🧠 Role in Context Anchoring

Context Anchoring uses three core primitives:

```text
ANCHOR -> GATE -> LOOP (optional) -> UPDATED ANCHOR
```

- Anchors store or define state.
- Gates perform bounded logic.
- Loops test results and control transitions.

The Loop does not replace the Gate. It determines whether the Gate result is acceptable and what the runtime should do next.

---

## ✅ Minimal Definition

> **A Loop is an optional Context Anchoring control structure that tests the result of a Gate, records a Confirmation, and controls whether the runtime continues, retries, reroutes, escalates, or stops.**

---

**Written by Justin Rodriguez**  
**Context Anchoring Framework**  
**Specification Version 2.0**  
**License:** GNU General Public License v3.0 or later
