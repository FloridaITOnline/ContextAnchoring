# CSRCQTOV: How I Accidentally Built a Programming Model Out of Prompts

**Justin Rodriguez — 2026**  
*Context Anchoring Research Notes*  

*Version 1.1 — GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)

---

## Why I Stopped Treating Prompts Like Messages

Most people talk to LLMs like they’re chatting with a smart person.  
That works—until it doesn’t.

Once you try to build anything repeatable—analysis, pipelines, orchestrators, QA flows, documentation generators—you run into the same problem:

- The model kind of remembers  
- It usually follows rules  
- It mostly keeps structure  

That’s not engineering. That’s vibes.

At the end of the day, where is the consistency?
Ever use the same prompt and get a different answer?

There’s math behind that.
The bot is the same bot every time, but it can take a different path to “true” based on many factors. That’s why asking the same question twice can give slightly different answers. It’s sampling from probability distributions influenced by:

Randomness (temperature, sampling)

Context differences

Hidden state interactions

Token-level probabilities

This gets dangerous when you’re trying to predict the right answer—like in agentic AI. Small differences in reasoning paths can cause big inconsistencies.

Context Anchoring tries to fix that by adding explicit structure—named variables, rules, and flow—so the model has a configurable “state” instead of just vibes.

---

## Treating Prompts Like Programs

So I started treating prompts like programs:

- With memory  
- With functions  
- With validation  
- With retry logic  

That eventually became **Context Anchoring (CA).**

And when I looked at what I’d built, I realized something weird:

I hadn’t just made a prompt framework.  
I had accidentally recreated a full software architecture—inside language.

That architecture compresses into one stupid-sounding mnemonic:

**CSRCQTOV — Computer Science Really Costs Q T Oranges Validation.**

Absurd on purpose. Because you remember absurd.  
“Cuties” were the little oranges we got as kids. I still remember how they sprayed when you peeled them and how good they smelled. Q, T, and Cutie aren’t the same thing—but if you go with it, it sticks.

---

## The Core Mapping

Here’s the table that started it all:

Traditional Software | Context Anchoring Equivalent | What It Means  
Code | Gates & Reasoning Chains | Gates are functions written in language  
State | Anchored Context | Anchors are named semantic variables  
Runtime | Attention Window | The model’s context window is the CPU + RAM  
Compiler | Prompt Parser | Language gets parsed into reasoning ops  
QA | Gate Tests & Reasoning Shape | Did the reasoning process look right?  
Testing | Iterative Loops | Re-run logic until it works or stops  
Output | Self-Audit Section | Output validates itself  
Validation | Assertions | Runtime checks for correctness  

That’s CSRCQTOV:

- Code  
- State  
- Runtime  
- Compiler  
- QA / Testing <> Output  
- Validation  

This isn’t metaphor poetry.  
This is literal structure.

| **Layer** | **Traditional Software** | **Context Anchoring Equivalent** | **Explanation** |
|------------|---------------------------|----------------------------------|-----------------|
| **Code** | Functions, APIs | **Gates & Reasoning Chains** | Each Gate acts as a callable function executing logic through controlled reasoning rather than compiled instructions. |
| **State** | Variables | **Anchored Context** | Stable reference points (anchors) preserve semantic state between iterations, simulating variable memory in natural language. |
| **Runtime** | CPU / Memory | **Model Attention Window** | Computation occurs within the model’s attention window where prompts, anchors, and reasoning coexist as transient state. |
| **Compiler** | Syntax Parser | **Prompt Parser** | The model interprets linguistic syntax and semantics, effectively parsing natural language into reasoning operations. |
| **QA / Testing** | Unit Tests | **Gate Tests & Equivalence Classes** | Controlled tests validate reasoning pathways using canonical, boundary, and negative cases to confirm stability. |
| **Output Validation** | Assertions | **Self-Audit Section** | Embedded audit prompts act as runtime assertions verifying schema, logic, and compliance within the model’s output. |

---

## What CSRCQTOV Is Really Claiming

CSRCQTOV says:

- Prompts can behave like programs  
- Language can carry executable logic  
- Reasoning can be modular  
- Memory can be simulated with names  
- Validation can live inside text  

By “executable,” I don’t mean “runs on a CPU.”

I mean:

> Reproducible reasoning steps, under declared constraints, with auditable outcomes.

If you can re-run it, inspect it, validate it, and loop it—that’s computation, regardless of medium.

Language just happens to be the runtime now.

---

## How My Prompt-to-ContextAnchor Orchestrator Fits CSRCQTOV

### Code — Gates

My system defines Gates like:

- G1_Parse_Input_Prompt  
- G2_Evaluate_Anchor_Candidates  
- G3_Evaluate_Gate_Candidates  
- G4_Infer_Gates  
- G5_Infer_Loops  
- G6_Infer_Orchestration  
- G7_Format_CA_Prompt  
- G8_Assess_Conversion_Confidence  
- G9_Validate_CA_Prompt  
- G10_Request_Clarification  

Each Gate has:

- Purpose  
- Inputs  
- Outputs  
- Operation  
- Verification  

That’s a function signature, written in English.

---

### State — Anchors

Anchors A0 through A12 are my memory model:

- Typed (Static / Dynamic)  
- Have schemas  
- Track provenance  
- Track confidence  

They behave exactly like variables—except semantic instead of numeric.

---

### Runtime — Attention Window

Everything runs inside the model’s attention window:

- Anchors  
- Gates  
- Orchestration  
- Issues  
- Audits  

That window is the runtime.

When I re-feed structured output, I’m simulating state persistence across executions.

---

### Compiler — Prompt Parser

Compiler behavior shows up as:

- G1_Parse_Input_Prompt → front-end  
- G9_Validate_CA_Prompt → back-end  

Syntax = labels, headers, schemas  
Semantics = inferred intent, goals, constraints  

That’s a real parse + validate pipeline—just in language.

---

## QA vs Validation (They Are Not the Same)

People mix these up, so here’s the split:

**QA asks:**  
Did the reasoning process follow the expected shape?

**Validation asks:**  
Does the final artifact satisfy required constraints?

So:

- QA audits how you reasoned  
- Validation audits what you produced  

Both matter. They are not interchangeable.

---

## Testing vs Iteration

Also different:

**Testing** tries known paths:

- Canonical  
- Boundary  
- Negative  

**Iteration** re-runs logic until:

- Errors are gone  
- Confidence is high  
- Or you hit a stop condition  

Testing finds errors.  
Iteration fixes them.

---

## Output — Self-Audit

My outputs don’t just give answers.  
They explain whether they obeyed the rules. This is known as '**Obeying the Behavioral Contract**' in Context Anchoring. We set a Behavioral Contract with the Anchors and Gates with the LLM. The Testing Primitive ensures the LLM is adhering to the Behavioral Contract it agreed to. This Output is what we use to test in the Validation Step.

Self-audit includes:

- Schema checks  
- Missing references  
- Constraint violations  
- Confidence summaries  

The output tells you whether to trust it. 

---

## Validation — Assertions

Assertions show up as:

- Orphan detection  
- Schema enforcement  
- Reference checks  
- Confidence thresholds  

That’s runtime safety, written in words.

A useful troubleshooting move during the Validation step is to ask the LLM *why* it reached a specific conclusion. Then:

1. Make a small correction  
2. Ask it to reread the relevant Anchors and Gates  
3. Ask the same question again  
4. Repeat until the answer is stable and close to what you expect  

When you run this prompt in an automation later, you can reuse that same idea:

- Loop through your Anchors and Gates  
- Ask a sample question that you already know the answer to  
- If the bot gives the same answer consistently, the “state” is behaving as expected  

You can do this loop for every new set of Anchors and Gates you add.

Just remember:

> Increasing the number of Anchors and Gates also increases the runtime required for the prompt.

More structure means more reliability—but it also means more work for the runtime to carry.

---

## Mini Example

**Raw input:**

“Summarize this doc and cite sources. Don’t mention draft sections.”

**Anchors:**

- A0_Task = Summarize doc  
- A1_Constraints = Cite sources; exclude drafts  
- A2_Sources = Intro, Methods, Results; Draft: Appendix-D  

**Gates:**

- Parse prompt → extract task + constraints  
- Scan doc → confirm sources  
- Format CA prompt  
- Validate output  

**Output self-audit:**

- Citations present: Pass  
- Draft excluded: Pass  
- Anchors complete: Pass  

That’s CSRCQTOV in motion.

---

## Known Limits

- Attention window = hard ceiling  
- Long chains can drift  
- Non-determinism is real  
- Anchors reduce chaos, not eliminate it  
- Humans still matter in high-stakes systems  

Context Anchoring doesn’t remove uncertainty.  
It makes uncertainty visible and manageable.

---

## What This Actually Means

I didn’t set out to build a prompt programming model.  
I just got tired of unreliable systems.

CSRCQTOV is what appears when you:

- Stop chatting  
- Start engineering  
- And treat language like a runtime  

So the real thesis is simple:

> When reasoning gets complex enough, it organizes itself like software—no matter what medium you use.

Silicon, text, or smoke signals—  
structure always wins.

**Language just happens to be the newest machine.**
