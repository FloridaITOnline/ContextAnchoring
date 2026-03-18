  # Project Overview

  **Written by Justin Rodriguez**
  **Date:** March 17, 2026
  **License:** GNU General Public License v3.0 or later

  ## Note From the Author

  I have been working on this problem since mid 2023. It was the first time I seriously tried to use AI to build
  something practical, and I noticed very quickly that the output quality could vary a lot.

  That led me to explore how prompting techniques affect reasoning quality. I found that methods such as personification
  are not just useful for novelty tasks like making an AI sound like Shakespeare. They can materially affect the
  quality, structure, and reliability of the output. In some cases, they can even improve predictive performance.

  What made this so interesting was that the improvement did not come from adding training data, upgrading hardware, or
  speeding up the network. It came from changing how the model was asked to think. Framing a task through the
  perspective of an expert often changed the quality of the response in meaningful ways.

  As I kept experimenting, I started to see that natural language could function as a computational medium. Boolean
  logic is straightforward. Operations like count distinct are straightforward. You can express structure, constraints,
  and transformation logic without relying on traditional programming syntax. That realization became the foundation for
  this project.

  ## What This Project Does

  This project demonstrates an automated pipeline that converts unstructured input into structured outputs such as JSON,
  CSV, and human-readable reports using PowerShell and LLM orchestration. It can also take structured data and produce
  predictable outputs for complex tasks using behavioral contracts, roles, and sample testing. 

  It simulates a multi-stage processing system in which each step validates and transforms data, similar to how modern
  cloud pipelines operate.

  ## Why It Matters

  Many real-world systems require transforming messy input into reliable, structured artifacts.

  This project demonstrates how that can be achieved through automation, validation, and controlled use of LLMs—without the 
  need to train custom models. It is particularly effective for problems that are complex, but not valuable enough to justify 
  building and maintaining a dedicated model.

  The core idea is that prompts can be designed to place an LLM into a repeatable operational state. When that state is consistent, 
  the outputs become predictable—and therefore testable. By validating this state against representative test cases, we can build 
  confidence in how the system will behave across similar real-world inputs.

  This aligns with Equivalence Testing Theory (also called Equivalence Partitioning), which suggests that a representative test case 
  can be used to infer behavior across all inputs within the same equivalence class. In practice, this allows for efficient and robust 
  validation using small, well-designed sample sets instead of exhaustive testing.

  Equivalence Testing Theory, combined with Boundary Value Analysis, strengthens this approach by testing not only valid inputs, but 
  also invalid and edge-case conditions. This helps verify not just that the model produces correct outputs, but that it fails in expected 
  and explainable ways—indicating the system is operating within the desired state.

  The result is a practical approach to evaluating LLM reliability using structured reasoning and plain-language logic.

  ## What the Blog Covers

  I explain how I think about the prompt as a compute runtime, and I show how prompts can be orchestrated as a
  distributed compute model with structured control, state transfer, and multi-stage execution.
