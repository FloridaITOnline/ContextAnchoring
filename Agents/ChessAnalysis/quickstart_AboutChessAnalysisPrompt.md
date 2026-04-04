# Chess Analysis Bot - Context Anchoring in Action

2026 Justin Rodriguez
Licensed under GPL v3

[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)

This project demonstrates Context Anchoring as a working computing model, transforming a single prompt into a deterministic, stateful, and auditable chess analysis system without code, APIs, or external memory.

## Overview

The Chess Analysis Bot is a prompt-native application powered entirely by structured language and built with the Context Anchoring framework.

It converts standard chess game data (PGNs) into structured JSON, CSV, and rich commentary through a deterministic prompt pipeline known as the Quickstart Orchestrator.

Unlike traditional bots or API-based engines, this system performs all computation inside the model's context window, where reasoning, validation, and state persistence occur through controlled language and stable anchors.

## Context Anchoring Framework

Context Anchoring treats prompts as computation layers:

| Layer | Software Equivalent | Anchoring Equivalent |
|---|---|---|
| Code | Functions / APIs | Gates (reasoning units) |
| State | Variables | Anchors (validated text states) |
| Runtime | CPU / Memory | Model attention window |
| Compiler | Syntax parser | Prompt parser |
| QA / Testing | Unit tests | Gate validation and self-audit |

Each Gate acts as a callable function that executes logic via language structure and schema enforcement, not executable code.

## Architecture

### Gate Stack

| Gate | Function | Equivalent Component |
|---|---|---|
| PGN Intake Gate | Parses input PGN and validates format | Input parser |
| Step-1 JSON Gate | Canonicalizes game data into structured JSON | Data model |
| CSV Gate | Produces canonical CSV output | Export layer |
| Commentary Gate (v1.3) | Generates multi-paragraph natural analysis | Analysis engine |
| UX Gate (v1.2) | Presents persistent interaction interface | UI layer |
| Post-PGN Cue | Signals state readiness | Runtime logger |

### Execution Flow

PGN -> JSON -> CSV -> Commentary -> UX -> User Query -> UX (loop)

PGN Intake: Structured input via fenced tags (`===PGN-START=== ... ===PGN-END===`).

Step-1 JSON: Game reconstructed as canonical JSON with validation (FEN replay, tag audit).

CSV Emission: Produces export-ready records for sheets or databases.

Commentary Generation: Multi-paragraph Markdown prose describing tactics and structure.

UX Gate Rendering: Presents a terminal-style interface with 5 selectable analysis options.

Reinforcement Loop: UX Gate persists, allowing repeated topic exploration without losing state.

## State Management

State persistence is achieved through anchored context, not memory.

Each fenced section (JSON, CSV, Commentary, UX) acts as a semantic checkpoint.
Validated outputs become anchors, allowing subsequent reasoning to reference prior results deterministically.

Example:

```
===STEP1-JSON-START===
{...}
===STEP1-JSON-END===
```

This block anchors the parsed game state, which subsequent Commentary and UX Gates use as stable input.

## Why It Matters

This system proves that complex, multi-phase reasoning can be achieved purely in natural language, without traditional code execution.

It showcases Context Anchoring's potential as a computing model:

- Deterministic reasoning within prompts.
- Stateful, testable computation using anchors.
- Validation cycles (audits) acting as runtime assertions.
- Cross-Gate persistence forming logical software flow.

In short: this chess bot does not run code - it is the code.

## Example Interaction

```
User: Okay, I am ready. Please paste a single-game PGN.
User: (pastes Carlsen/Niemann PGN)

PGN-INTAKE: tags=14, plies=114
JSON + CSV emitted
PGN processed successfully.
Ask me what I thought of the game to begin commentary.

User: What did you think of the game?

Commentary Gate triggers:
- Generates multi-paragraph analysis
- Summarizes key strategic turning points
- Outputs UX menu with topic options

User: 2
Returns detailed list of critical moments.
```

All logic and flow occur within the model - no backend required.

## Files

| File | Purpose |
|---|---|
| `chessanalysis_nonprimitivebased.md` | Example prompt used to test the CA prompt orchestrator |
| `ContextAnchorPromptOrchestroator/CAPromptOrchestrator.md` | Orchestrator that converts a working prompt into a primitives-based CA prompt |
| `quickstart.md` | Main orchestrator definition and schema |
| `commentary_gate.md` | Narrative analysis gate definition |
| `ux_gate.md` | UX interface logic and persistent interaction rules |
| `context_anchoring.md` | Theoretical framework reference |
| `quickstart_AboutChessAnalysisPrompt.md` | Architecture and design overview (this file) |

## Concept Summary

Context Anchoring turns prompts into programmable systems.

This project demonstrates that with precise language structure, a model like GPT-5 can behave as a deterministic software stack - parsing input, managing state, validating results, and interacting with users coherently across cycles.

It is not a simulation of software - it is software composed of reasoning.

---

**Author:** Justin Rodriguez
Framework: Context Anchoring v1.1 - Public Domain
Repository: Florida IT Online - Prompt-Labs
