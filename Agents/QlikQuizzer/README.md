# 📊 QlikQuizzer v3.0 — Context Anchored Tutor
© 2026 Justin Rodriguez | **GPL v3 Open Framework**

> "Turning probabilistic prompts into deterministic certification engines."

**QlikQuizzer** is a production-grade adaptive tutor designed for the **Qlik 2024 Certification Exams** (QSBA, QSDA, QSSA). Unlike traditional chatbots, it is built on the **Context Anchoring (CA)** framework, using structured reasoning gates and anchored state management to provide a stable, high-fidelity learning experience.

---

## 🧠 The Context Anchoring Edge

QlikQuizzer implements the core primitives of the **Rodriguez Context Anchoring Model**:

- **Anchors (State):** Uses `A0-A3` anchors to lock in the 2024 Exam Domain and track student progress without "contextual drift."
- **Gates (Logic):** Discrete reasoning steps (`G1-G3`) manage question generation, evaluation, and self-auditing.
- **Loops (Orchestration):** Controlled iteration cycles manage the quiz flow and provide periodic 5-question performance summaries.
- **Sliding Window (Boundary Theory):** Implements a **Pinned System Prompt** strategy, keeping the context window stable and preventing "Context Bloom" during long study sessions.

---

## 🛠️ Technical Architecture

- **Engine:** Python / Flask
- **Reasoning:** GPT-4o-mini (Optimized for the Context Stability Envelope)
- **Deployment:** Azure App Service (Linux)
- **Security:** Azure Key Vault with Managed Identity (Zero-Trust Secret Injection)
- **Infrastructure:** Bicep (Infrastructure-as-Code)

---

## 🚀 Getting Started

### 1. Local Development
1. Clone the repository and navigate to the `QlikQuizzer` agent.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Set your environment variables:
   - `OPENAI_API_KEY`: Your API key.
   - `SESSION_SECRET_KEY`: A random string for Flask session isolation.
4. Run the app:
   ```bash
   python qlikquizzer.py
   ```

### 2. Azure Deployment (Context Anchored Infra)
Deploy the entire stack (including Key Vault and App Service) using the provided Bicep templates:
```powershell
az deployment sub create --location eastus --template-file github/ContextAnchoring/Agents/QlikQuizzer/Deploy/main.bicep --parameters openaiApiKey=$(Read-Host -Prompt "Enter Key" -AsSecureString)
```

---

## 📂 Project Structure

- `/Prompts`: Contains the **Anchored Reasoning Blueprints** (`.md`).
- `/Deploy`: Bicep infrastructure-as-code files.
- `qlikquizzer.py`: The "Message Bus" orchestrator (State-decoupled).
- `chat.html`: The interactive student interface.

---

## 📜 Philosophy
QlikQuizzer demonstrates that **Language is the Runtime**. By decoupling the reasoning logic (Markdown) from the execution logic (Python), we create a system that is modular, testable, and resilient to the inherent noise of large language models.

---

**Written by Justin Rodriguez**
**Date:** April 4, 2026
**License:** GNU General Public License v3.0 or later

