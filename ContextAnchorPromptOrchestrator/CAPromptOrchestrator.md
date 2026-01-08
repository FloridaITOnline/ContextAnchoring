# Prompt-to-CA-Prompt Orchestrator — Conceptual Design

*Version 1.0 — GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)

**Purpose:** To conceptually design a Context Anchoring orchestrator that takes an unstructured prompt as input and transforms it into a structured, Context Anchor Approved Prompt.

**Disclaimer:** This document outlines the *design* of such an orchestrator using the Context Anchoring framework. Implementing a fully functional version would require significant iterative development, testing, and refinement within an LLM environment, likely involving multiple turns and human oversight due to the inherent complexity of inferring intent from unstructured input.

---

## ⚙️ Global Anchors (Persistent State & Configuration for the Conversion Process)

### ANCHOR: A0_Objective
- **Purpose:** Core objective of this meta-orchestrator.
- **Type:** Static
- **Initial Value:** "Convert an unstructured prompt into a structured, Context Anchor Approved Prompt using the defined framework."

### ANCHOR: A1_Input_Prompt
- **Purpose:** Stores the raw, unstructured prompt provided by the user for conversion.
- **Type:** Dynamic
- **Initial Value:** N/A (User provided)
- **Schema:** String, representing an arbitrary LLM prompt.

### ANCHOR: A2_CA_Framework_Definition
- **Purpose:** Stores the formal definitions of Context Anchoring primitives and best practices.
- **Type:** Static
- **Initial Value:** (Reference to `ContextAnchoring.MD`, `Anchor_Definition.md`, `Gate_Definition.md`, `Core Primitives of Context Anchoring.md`, and best practices for CA prompt structure).

### ANCHOR: A3_Identified_Anchors
- **Purpose:** Stores the list of Anchors inferred from the `A1_Input_Prompt`.
- **Type:** Dynamic
- **Initial Value:** Empty List
- **Schema:** List of Anchor definitions (Name, Purpose, Type, Initial Value, Schema).

### ANCHOR: A4_Identified_Gates
- **Purpose:** Stores the list of Gates inferred from the `A1_Input_Prompt`.
- **Type:** Dynamic
- **Initial Value:** Empty List
- **Schema:** List of Gate definitions (Name, Purpose, Inputs, Outputs, Operation, Verification).

### ANCHOR: A5_Identified_Loops
- **Purpose:** Stores the list of Loops inferred from the `A1_Input_Prompt`.
- **Type:** Dynamic
- **Initial Value:** Empty List
- **Schema:** List of Loop definitions (Name, Purpose, Gates in Loop, Termination Condition).

### ANCHOR: A6_Inferred_Orchestration_Flow
- **Purpose:** Stores the inferred sequence and relationships between the identified primitives.
- **Type:** Dynamic
- **Initial Value:** Empty String
- **Schema:** Structured text describing the execution flow.

### ANCHOR: A7_CA_Approved_Prompt_Output
- **Purpose:** Stores the final, structured Context Anchor Approved Prompt.
- **Type:** Dynamic
- **Initial Value:** Empty String
- **Schema:** Markdown string adhering to the Context Anchoring prompt structure.

### ANCHOR: A8_Conversion_Errors
- **Purpose:** Stores any issues, ambiguities, or warnings encountered during the conversion process.
- **Type:** Dynamic
- **Initial Value:** Empty List
- **Schema:** List of strings, each describing an error or warning.

### ANCHOR: A9_User_Clarification_Request
- **Purpose:** Stores questions to the user for clarification on ambiguous parts of the input prompt.
- **Type:** Dynamic
- **Initial Value:** Empty String
- **Schema:** String, a question to the user.

---

## 🧩 Gates (Conversion Logic)

### GATE: G1_Parse_Input_Prompt
- **Purpose:** Initial analysis of the unstructured input prompt to identify explicit instructions and implicit intent.
- **Inputs:** `A1_Input_Prompt`.
- **Outputs:** Initial updates to `A3_Identified_Anchors`, `A4_Identified_Gates`, `A5_Identified_Loops`.
- **Operation:**
    1.  Read `A1_Input_Prompt`.
    2.  Identify explicit statements of intent, constraints, and desired outputs.
    3.  Perform initial tokenization and semantic analysis.
- **Verification (Audit):**
    - Ensure `A1_Input_Prompt` is not empty.

### GATE: G2_Infer_Anchors
- **Purpose:** Extracts and formalizes potential Anchors (state, constraints, objectives) from the input prompt.
- **Inputs:** `A1_Input_Prompt`, `A2_CA_Framework_Definition`.
- **Outputs:** Updates `A3_Identified_Anchors`, `A8_Conversion_Errors`.
- **Operation:**
    1.  Analyze `A1_Input_Prompt` for nouns, key phrases, and explicit constraints that represent persistent state or configuration.
    2.  Propose names, purposes, types (Static/Dynamic), and initial values/schemas for each potential Anchor.
    3.  If ambiguity, add a note to `A8_Conversion_Errors`.
- **Verification (Audit):**
    - Ensure all identified Anchors have a proposed name and purpose.
    - Check for potential duplicate Anchors.

### GATE: G3_Infer_Gates
- **Purpose:** Extracts and formalizes potential Gates (operations, transformations, reasoning steps) from the input prompt.
- **Inputs:** `A1_Input_Prompt`, `A2_CA_Framework_Definition`, `A3_Identified_Anchors`.
- **Outputs:** Updates `A4_Identified_Gates`, `A8_Conversion_Errors`.
- **Operation:**
    1.  Analyze `A1_Input_Prompt` for verbs, action phrases, and explicit instructions that represent distinct operations.
    2.  Propose names, purposes, inputs (referencing `A3_Identified_Anchors`), outputs (referencing `A3_Identified_Anchors`), and a high-level operation description for each potential Gate.
    3.  If ambiguity, add a note to `A8_Conversion_Errors`.
- **Verification (Audit):**
    - Ensure all identified Gates have a proposed name and purpose.
    - Check for Gates with no apparent inputs or outputs.

### GATE: G4_Infer_Loops
- **Purpose:** Extracts and formalizes potential Loops (iterative processes, repeated actions) from the input prompt.
- **Inputs:** `A1_Input_Prompt`, `A2_CA_Framework_Definition`, `A4_Identified_Gates`.
- **Outputs:** Updates `A5_Identified_Loops`, `A8_Conversion_Errors`.
- **Operation:**
    1.  Analyze `A1_Input_Prompt` for phrases indicating repetition, refinement, or conditional execution until a goal is met.
    2.  Propose names, purposes, Gates involved, and termination conditions for each potential Loop.
    3.  If ambiguity, add a note to `A8_Conversion_Errors`.
- **Verification (Audit):
    - Ensure all identified Loops have a proposed name and purpose.
    - Check for Loops with no apparent termination condition.

### GATE: G5_Infer_Orchestration
- **Purpose:** Determines the sequence and relationships between the identified primitives.
- **Inputs:** `A3_Identified_Anchors`, `A4_Identified_Gates`, `A5_Identified_Loops`.
- **Outputs:** Updates `A6_Inferred_Orchestration_Flow`, `A8_Conversion_Errors`.
- **Operation:**
    1.  Construct a directed graph based on the inputs/outputs of Gates and the flow of Loops.
    2.  Propose a sequential orchestration flow, including error handling and conditional branches.
    3.  If circular dependencies or unresolvable ambiguities, add a note to `A8_Conversion_Errors`.
- **Verification (Audit):**
    - Ensure the proposed flow is logical and covers all identified primitives.
    - Check for any unreferenced Anchors or Gates.

### GATE: G6_Format_CA_Prompt
- **Purpose:** Formats the inferred primitives and orchestration into the structured Context Anchor Approved Prompt.
- **Inputs:** `A3_Identified_Anchors`, `A4_Identified_Gates`, `A5_Identified_Loops`, `A6_Inferred_Orchestration_Flow`.
- **Outputs:** Updates `A7_CA_Approved_Prompt_Output`.
- **Operation:**
    1.  Generate Markdown sections for Anchors, Gates, Loops, and Orchestration Flow.
    2.  Populate these sections using the data from `A3` through `A6`, adhering to the structured format.
- **Verification (Audit):**
    - Ensure output is valid Markdown.
    - Check for correct primitive syntax.

### GATE: G7_Validate_CA_Prompt
- **Purpose:** Checks the generated CA prompt against the formal framework definition and best practices.
- **Inputs:** `A7_CA_Approved_Prompt_Output`, `A2_CA_Framework_Definition`.
- **Outputs:** Updates `A8_Conversion_Errors`.
- **Operation:**
    1.  Parse `A7_CA_Approved_Prompt_Output`.
    2.  Check for adherence to `A2_CA_Framework_Definition` (e.g., correct primitive structure, explicit inputs/outputs, verification sections).
    3.  Identify any remaining ambiguities or potential inefficiencies.
- **Verification (Audit):
    - Ensure `A8_Conversion_Errors` accurately reflects any issues.

### GATE: G8_Request_Clarification
- **Purpose:** Formulates questions to the user when significant ambiguities or errors are found.
- **Inputs:** `A1_Input_Prompt`, `A8_Conversion_Errors`.
- **Outputs:** Updates `A9_User_Clarification_Request`.
- **Operation:**
    1.  Review `A8_Conversion_Errors`.
    2.  Formulate concise, targeted questions to the user to resolve the most critical ambiguities in `A1_Input_Prompt`.
- **Verification (Audit):**
    - Ensure questions are clear and actionable.

---

## 🔁 Loops (Iterative Refinement)

### LOOP: L1_Conversion_Refinement_Loop
- **Purpose:** Manages the iterative process of converting and refining the CA prompt until it's approved or clarified.
- **Gates in Loop:** `G7_Validate_CA_Prompt`, `G8_Request_Clarification`, and potentially re-execution of `G2` through `G6`.
- **Termination Condition:**
    - `A8_Conversion_Errors` is empty (prompt is approved).
    - User provides clarification that resolves all errors.
    - A predefined maximum number of iterations is reached.
- **Operation:**
    1.  Execute `G7_Validate_CA_Prompt`.
    2.  If `A8_Conversion_Errors` is not empty:
        -   Execute `G8_Request_Clarification`.
        -   Present `A9_User_Clarification_Request` to the user.
        -   Wait for user input (which would update `A1_Input_Prompt` or provide specific answers).
        -   Re-execute `G1` through `G6` based on user clarification.
    3.  If `A8_Conversion_Errors` is empty, exit loop.

---

## 🚀 Orchestration Flow

1.  **Initial State:** Set `A0_Objective`, `A2_CA_Framework_Definition`.
2.  **Input Prompt:** Receive user input for `A1_Input_Prompt`.
3.  **Initial Parsing:** Execute `G1_Parse_Input_Prompt`.
4.  **Infer Primitives:**
    -   Execute `G2_Infer_Anchors`.
    -   Execute `G3_Infer_Gates`.
    -   Execute `G4_Infer_Loops`.
5.  **Infer Orchestration:** Execute `G5_Infer_Orchestration`.
6.  **Format Prompt:** Execute `G6_Format_CA_Prompt`.
7.  **Enter Refinement Loop:** Execute `L1_Conversion_Refinement_Loop`.
8.  **Final Output:** If `L1_Conversion_Refinement_Loop` terminates successfully, output `A7_CA_Approved_Prompt_Output`. Otherwise, output `A8_Conversion_Errors` and `A9_User_Clarification_Request` for manual intervention.

---
