import os
import openai
from flask import Flask, request, jsonify, render_template, session

app = Flask(__name__, template_folder="templates")

# Flask Session Security: Establish the session anchor
# In Azure, this should be set as an App Setting (Environment Variable)
app.secret_key = os.getenv("SESSION_SECRET_KEY", "a_very_secure_default_for_local_testing")

# Set OpenAI API key from environment variables (Injected via Key Vault)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise Exception("OpenAI API key is not set in environment variables.")

openai.api_key = OPENAI_API_KEY

# Path to the Anchored Prompt (The System Blueprint)
PROMPT_PATH = os.path.join(os.path.dirname(__file__), "Prompts", "QlikQuizzer_V3_Anchored.md")

def load_anchored_prompt():
    """Loads the Context Anchoring V3 prompt from disk."""
    try:
        with open(PROMPT_PATH, "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        print(f"[CRITICAL] Prompt file not found at {PROMPT_PATH}")
        return "You are a Qlik certification tutor. (Error: Anchored prompt file not found)."

@app.route("/")
def home():
    """Serve the chatbot HTML page and initialize the Anchor State."""
    # Reset the session anchor when the student loads the home page
    session['chat_history'] = [
        {"role": "system", "content": load_anchored_prompt()}
    ]
    return render_template("chat.html")

@app.route("/chat", methods=["POST"])
def chat():
    """
    Handle user messages using the Pinned Sliding Window strategy.
    User Isolation: State is managed via the 'session' object.
    Boundary Theory: We keep the System Prompt (Index 0) and the last 5 turns 
    to prevent context bloat and maintain the Stability Envelope (CSE).
    """
    # Retrieve the student's unique Context Anchor (A2) from their session
    chat_history = session.get('chat_history', [])
    
    # If the session is empty (e.g., direct API call), initialize it
    if not chat_history:
        chat_history = [{"role": "system", "content": load_anchored_prompt()}]

    user_message = request.form.get("user_input", "").strip()

    if not user_message:
        return jsonify({"message": "Please enter a valid input."})

    # Add user input to the reasoning context
    chat_history.append({"role": "user", "content": user_message})

    # --- THE SLIDING WINDOW (Context Anchoring Strategy 2) ---
    # We keep Index 0 (System Prompt) and the last 5 messages.
    # This prevents the context from growing indefinitely while keeping 
    # the core 'Rules' (Anchors) always active at the top.
    if len(chat_history) > 6:
        system_prompt = chat_history[0]
        recent_context = chat_history[-5:] # Take the last 5 messages
        chat_history = [system_prompt] + recent_context
    # ---------------------------------------------------------

    try:
        response = openai.ChatCompletion.create(
            model="gpt-4o-mini",
            messages=chat_history,
            max_tokens=1000,
            temperature=0.7
        )

        bot_response = response["choices"][0]["message"]["content"].strip()

        # Update history to maintain the student's unique Anchored State (A2)
        chat_history.append({"role": "assistant", "content": bot_response})
        
        # Save the updated Context Anchor back to the session
        session['chat_history'] = chat_history
        
        return jsonify({"message": bot_response})

    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return jsonify({"message": "The system encountered a reasoning error. Please try again."})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
