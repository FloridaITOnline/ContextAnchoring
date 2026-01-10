# Prompt-to-ContextAnchor - Prompt Orchestrator

*Version 1.2 - GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)

**Purpose:** To conceptually design a Context Anchoring (CA) orchestrator that transforms an unstructured prompt into a structured, Context Anchor Approved Prompt, while explicitly modeling uncertainty, confidence, ambiguity, and partial success.

**Design Philosophy (New):**
- Treat ambiguity as data, not failure
- Distinguish inferred vs confirmed structures
- Allow partial convergence, not only binary success
- Preserve human-in-the-loop control without collapsing the system

**Disclaimer:** This document outlines the *design* of such an orchestrator using the Context Anchoring framework. Implementing a fully functional version would require significant iterative development, testing, and refinement within an LLM environment, likely involving multiple turns and human oversight due to the inherent complexity of inferring intent from unstructured input.

---

### ANCHOR: A0_Objective
- **Purpose:** Core objective of the orchestrator.
- **Type:** Static
- **Initial Value:** "Convert an unstructured prompt into a structured, Context Anchor Approved Prompt using the Context Anchoring framework, while explicitly tracking uncertainty and ambiguity."

### ANCHOR: A1_Input_Prompt
- **Purpose:** Stores the raw user-provided prompt.
- **Type:** Dynamic
- **Schema:** String (arbitrary natural-language prompt)

### ANCHOR: A2_CA_Framework_Definition
- **Purpose:** Authoritative reference for CA primitives and best practices.
- **Type:** Static
- **Initial Value:**
    References to:
    - ContextAnchoring.md
    - Anchor_Definition.md
    - Gate_Definition.md
    - Core Primitives of Context Anchoring.md

### ANCHOR: A3_Anchor_Candidates
- **Purpose:** Stores tentative Anchors inferred from the input prompt.
- **Type:** Dynamic
- **Schema:**
    List of:
    - Name
    - Proposed Purpose
    - Proposed Type (Static/Dynamic)
    - Confidence Score (0-1)
    - Provenance (text fragment or rationale)

### ANCHOR: A4_Identified_Anchors
- **Purpose:** Stores Anchors promoted from candidates to confirmed Anchors.
- **Type:** Dynamic
- **Schema:**
    Anchor definition + confidence + provenance

### ANCHOR: A5_Gate_Candidates
- **Purpose:** Stores tentative Gates inferred from action phrases.
- **Type:** Dynamic
- **Schema:**
    Gate definition + confidence + provenance

### ANCHOR: A6_Identified_Gates
- **Purpose:** Stores confirmed Gates.
- **Type:** Dynamic
- **Schema:**
    Gate definition + inputs + outputs + confidence + provenance

### ANCHOR: A7_Identified_Loops
- **Purpose:** Stores inferred Loops.
- **Type:** Dynamic
- **Schema:**
    Loop definition + confidence + termination clarity score

### ANCHOR: A8_Inference_Confidence_Report
- **Purpose:** Aggregated confidence metrics for the conversion.
- **Type:** Dynamic
- **Schema:**
    - Anchor confidence summary
    - Gate confidence summary
    - Loop confidence summary
    - Overall conversion confidence (0-1)

### ANCHOR: A9_Inferred_Orchestration_Flow
- **Purpose:** Stores inferred execution flow.
- **Type:** Dynamic
- **Schema:** Structured text or DAG-like description

### ANCHOR: A10_CA_Approved_Prompt_Output
- **Purpose:** Final structured CA prompt.
- **Type:** Dynamic
- **Schema:** Markdown

### ANCHOR: A11_Conversion_Issues
- **Purpose:** Stores errors, warnings, and ambiguities.
- **Type:** Dynamic
- **Schema:**
    List of:
    - Issue Type (Error / Warning / Ambiguity)
    - Severity (High / Medium / Low)
    - Related Anchor/Gate/Loop
    - Suggested Resolution

### ANCHOR: A12_User_Clarification_Request
- **Purpose:** Stores clarification questions.
- **Type:** Dynamic
- **Schema:** Ordered list of questions, ranked by impact

---

## ?? Gates (Conversion Logic)

### GATE: G1_Parse_Input_Prompt
- **Purpose:** Initial semantic analysis.
- **Outputs:** Populates A3_Anchor_Candidates, A5_Gate_Candidates
- **Operation:**
    1.  Read A1_Input_Prompt
    2.  Identify intents, constraints, entities, actions
    3.  Extract provenance for each candidate

### GATE: G2_Evaluate_Anchor_Candidates
- **Purpose:** Promote or discard anchor candidates.
- **Inputs:** A3_Anchor_Candidates
- **Outputs:** A4_Identified_Anchors, A11_Conversion_Issues
- **Operation:**
    1.  Promote candidates above confidence threshold
    2.  Flag low-confidence anchors as ambiguous

### GATE: G3_Evaluate_Gate_Candidates
- **Purpose:** Promote or discard gate candidates.
- **Inputs:** A5_Gate_Candidates, A4_Identified_Anchors
- **Outputs:** A6_Identified_Gates, A11_Conversion_Issues
- **Operation:**
    1.  Promote candidates above confidence threshold.
    2.  Validate that each Gate has a purpose and references known Anchors for inputs/outputs.
    3.  Flag low-confidence or orphaned Gates as ambiguous in `A11_Conversion_Issues`.
- **Verification (Audit):**
    - Ensure promoted Gates include name, purpose, inputs, and outputs.
    - Check for Gates that reference Anchors not present in `A4_Identified_Anchors`.

### GATE: G4_Infer_Gates
- **Purpose:** Extracts and formalizes potential Gates (operations, transformations, reasoning steps) from the input prompt.
- **Inputs:** `A1_Input_Prompt`, `A2_CA_Framework_Definition`, `A4_Identified_Anchors`.
- **Outputs:** Updates `A6_Identified_Gates`, `A11_Conversion_Issues`.
- **Operation:**
    1.  Analyze `A1_Input_Prompt` for verbs, action phrases, and explicit instructions that represent distinct operations.
    2.  Propose names, purposes, inputs (referencing `A4_Identified_Anchors`), outputs (referencing `A4_Identified_Anchors`), and a high-level operation description for each potential Gate.
    3.  If ambiguity, add a note to `A11_Conversion_Issues`.
- **Verification (Audit):**
    - Ensure all identified Gates have a proposed name and purpose.
    - Check for Gates with no apparent inputs or outputs.

### GATE: G5_Infer_Loops
- **Purpose:** Identify iteration or refinement.
- **Enhancement:**
    Assign termination clarity score
- **Inputs:** `A1_Input_Prompt`, `A2_CA_Framework_Definition`, `A6_Identified_Gates`.
- **Outputs:** Updates `A7_Identified_Loops`, `A11_Conversion_Issues`.
- **Operation:**
    1.  Analyze `A1_Input_Prompt` for phrases indicating repetition, refinement, or conditional execution until a goal is met.
    2.  Propose names, purposes, Gates involved, and termination conditions for each potential Loop.
    3.  If ambiguity, add a note to `A11_Conversion_Issues`.
- **Verification (Audit):**
    - Ensure all identified Loops have a proposed name and purpose.
    - Check for Loops with no apparent termination condition.

### GATE: G6_Infer_Orchestration
- **Purpose:** Build execution flow.
- **Enhancement:**
    Explicitly mark:
    - Linear flows
    - Conditional branches
    - Unresolved ordering
- **Inputs:** `A4_Identified_Anchors`, `A6_Identified_Gates`, `A7_Identified_Loops`.
- **Outputs:** Updates `A9_Inferred_Orchestration_Flow`, `A11_Conversion_Issues`.
- **Operation:**
    1.  Construct a directed graph based on the inputs/outputs of Gates and the flow of Loops.
    2.  Propose a sequential orchestration flow, including error handling and conditional branches.
    3.  If circular dependencies or unresolvable ambiguities, add a note to `A11_Conversion_Issues`.
- **Verification (Audit):**
    - Ensure the proposed flow is logical and covers all identified primitives.
    - Check for any unreferenced Anchors or Gates.

### GATE: G7_Format_CA_Prompt
- **Purpose:** Generate structured CA prompt.
- **Enhancement:**
    Annotate sections with:
    - Confidence notes (optional)
    - Ambiguity markers where unresolved
- **Inputs:** `A4_Identified_Anchors`, `A6_Identified_Gates`, `A7_Identified_Loops`, `A9_Inferred_Orchestration_Flow`.
- **Outputs:** Updates `A10_CA_Approved_Prompt_Output`.
- **Operation:**
    1.  Generate Markdown sections for Anchors, Gates, Loops, and Orchestration Flow.
    2.  Populate these sections using the data from `A4` through `A9`, adhering to the structured format.
- **Verification (Audit):**
    - Ensure output is valid Markdown.
    - Check for correct primitive syntax.

### GATE: G8_Assess_Conversion_Confidence
- **Purpose:** Produce overall confidence report.
- **Inputs:** A3_Anchor_Candidates, A4_Identified_Anchors, A5_Gate_Candidates, A6_Identified_Gates, A7_Identified_Loops, A11_Conversion_Issues
- **Outputs:** A8_Inference_Confidence_Report

### GATE: G9_Validate_CA_Prompt
- **Purpose:** Framework compliance check.
- **Inputs:** `A10_CA_Approved_Prompt_Output`, `A2_CA_Framework_Definition`.
- **Outputs:** Updates `A11_Conversion_Issues`.
- **Operation:**
    1.  Parse `A10_CA_Approved_Prompt_Output`.
    2.  Check for adherence to `A2_CA_Framework_Definition` (e.g., correct primitive structure, explicit inputs/outputs, verification sections).
    3.  Identify any remaining ambiguities or potential inefficiencies.
- **Verification (Audit):**
    - Ensure `A11_Conversion_Issues` accurately reflects any issues.

### GATE: G10_Request_Clarification
- **Purpose:** Ask minimal, high-impact questions.
- **Enhancement:**
    Rank questions by how much they would increase confidence.
- **Inputs:** `A1_Input_Prompt`, `A11_Conversion_Issues`.
- **Outputs:** Updates `A12_User_Clarification_Request`.
- **Operation:**
    1.  Review `A11_Conversion_Issues`.
    2.  Formulate concise, targeted questions to the user to resolve the most critical ambiguities in `A1_Input_Prompt`.
- **Verification (Audit):**
    - Ensure questions are clear and actionable.

---

## ?? Loops (Iterative Refinement)

### LOOP: L1_Refinement_Loop
- **Purpose:** Manages the iterative process of converting and refining the CA prompt until it's approved or clarified.
- **Gates in Loop:** `G9_Validate_CA_Prompt`, `G10_Request_Clarification`, and potentially re-execution of `G2` through `G6`.
- **Termination Condition:**
    - No high-severity issues remain
    - Confidence exceeds acceptable threshold
    - User declines further clarification
    - Iteration limit reached
- **Operation:**
    1.  Execute `G9_Validate_CA_Prompt`.
    2.  If `A11_Conversion_Issues` is not empty:
        -   Execute `G10_Request_Clarification`.
        -   Present `A12_User_Clarification_Request` to the user.
        -   Wait for user input (which would update `A1_Input_Prompt` or provide specific answers).
        -   Re-execute `G1` through `G6` based on user clarification.
    3.  If `A11_Conversion_Issues` is empty, exit loop.

---

## ?? Orchestration Flow (V2)

1.  Initialize static anchors
2.  Parse input - generate candidates (`G1_Parse_Input_Prompt`)
3.  Evaluate & promote anchors and gates (`G2_Evaluate_Anchor_Candidates`, `G3_Evaluate_Gate_Candidates`, `G4_Infer_Gates`)
4.  Infer loops and orchestration (`G5_Infer_Loops`, `G6_Infer_Orchestration`)
5.  Format CA prompt (`G7_Format_CA_Prompt`)
6.  Assess confidence (`G8_Assess_Conversion_Confidence`)
7.  Validate (`G9_Validate_CA_Prompt`)
8.  Enter refinement loop if needed (`L1_Refinement_Loop`, `G10_Request_Clarification`)
9.  Output:
    - CA Prompt
    - Confidence Report
    - Outstanding ambiguities (if any)

  ---
  **Written by:** Justin Rodriguez
