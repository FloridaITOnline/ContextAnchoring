# ✅ **Anchor — Detailed Definition (Context Anchoring)**
© 2026 Justin Rodriguez
Licensed under GPL v3

*Version 1.3 — GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)

## 📌 What Is an Anchor?

> **An Anchor is a stable, named reference point that preserves essential context across the steps of a task, creating predictability, continuity, and bounded scope for an LLM.**

It acts like a **persistent register of meaning**:  
The model must treat it as fixed unless explicitly updated.

Anchors define:
- What matters  
- What stays constant  
- What must be remembered and respected  

They are the **core memory objects** of Context Anchoring.

---

## 🧩 Core Properties

1) **Named**  
   - Anchors have labels (e.g., A0, A1, or semantic names)  
   - Naming makes them easily referenced  

2) **Stable & Persistent**  
   - They remain active across multiple steps  
   - They do not change unless explicitly updated  

3) **Scope-Defining**  
   - They declare what is allowed (in-bounds) and disallowed (out-of-bounds)  

4) **Minimal & Essential**  
   - They store only the context necessary for continuity  

5) **Invariants**  
   - They function as “must-remain-true” conditions  
   - They override subsequent contextual drift  

6) **Explicitly Referencable**  
   - Later steps can call back to the anchors  

7) **Composable**  
   - Anchors can be layered or extended to build richer tasks  

---

## 🎯 Why Anchors Exist

Anchors prevent:
- Context drift  
- Hallucination from forgotten constraints  
- Re-explaining information  
- Stepwise loss of intent  
- Failure in long-form reasoning  

Anchors give language models:
- Deterministic behavior  
- Bounded scope  
- Memory continuity  

---

## 🚫 What Anchors Are *Not*

Anchors are **not**:
- A full transcript  
- A vague preference  
- A one-time instruction  
- A disposable constraint  
- A passive hint  
- Unnamed or implicit memory  

Anchors must be:
- **Explicit**
- **Named**
- **Persistent**

---

## 🔁 Anchor Lifecycle

1) **Declaration**  
   Anchors are defined at the start.

2) **Reference**  
   Gates and reasoning steps refer to them.

3) **Persistence**  
   They remain active across steps.

4) **Update (Optional)**  
   They change only if explicitly modified.

5) **Deactivation**  
   Session resets or terminates.

---

## 🔠 Typical Anchor Types

  | Category | Function | Examples |
  |----------|----------|----------|
  | **Objective** | Defines task goal | “Draft onboarding email”, “Analyze chess game” |
  | **Scope / Domain** | Limits content | UI/UX only, Admin vs User role, Finance domain |
  | **Difficulty** | Sets complexity | Easy, Medium, Hard |
  | **Format / Structure** | Controls procedural shape | JSON output, 3‑step bullet list, Markdown table |
  | **State** | Stores evolving info | Score: 2–1, Current phase: “Middlegame” |
  | **Safety Constraints** | Ensures guardrails | No PII, medical disclaimer required |

---

## 🏗️ Structure

Each anchor has:
- **Name** (identifier)
- **Content** (value / directive)
- **Scope** (where/when it applies)
- **Mutability** (static or dynamic)

Example:

---
**Written By:** Justin Rodriguez

