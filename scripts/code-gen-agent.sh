#!/bin/bash
# Code Generation Agent v4 - With Streamlit deployment support
# Usage: ./code-gen-agent.sh "<command>"

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs 2>/dev/null || true)
elif [ -f "$(dirname "$0")/../.env" ]; then
    export $(grep -v '^#' "$(dirname "$0")/../.env" | xargs 2>/dev/null || true)
fi

COMMAND="$1"
REPO_URL=""
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_deploy() { echo -e "${CYAN}[DEPLOY]${NC} $1"; }

# Check token
if [ -z "$GITHUB_TOKEN" ]; then
    log_error "GitHub token not set. Set GITHUB_TOKEN in .env"
    exit 1
fi

# Parse repo URL
if [[ "$COMMAND" =~ Repo:[[:space:]]*(https://github\.com/[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+) ]]; then
    REPO_URL="${BASH_REMATCH[1]}"
    log_info "Repo: $REPO_URL"
fi

if [ -z "$REPO_URL" ]; then
    log_warn "No repo URL. Enter one:"
    read -p "> " REPO_URL
fi

# Extract topic
TOPIC=$(echo "$COMMAND" | grep -o '\[.*\]' | head -1 | tr -d '[]' || echo "generated-app")
BRANCH_NAME="feature/$(echo "$TOPIC" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')-$(date +%Y%m%d-%H%M%S)"

log_info "🚀 Generating: $TOPIC"
log_info "🌿 Branch: $BRANCH_NAME"

# Temp dir
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

OWNER=$(echo "$REPO_URL" | sed -n 's|.*github.com/\([^/]*\)/.*|\1|p')
REPO_NAME=$(echo "$REPO_URL" | sed -n 's|.*github.com/[^/]*/\([^/]*\).*|\1|p')

log_step "📥 Cloning..."
git clone "https://${GITHUB_TOKEN}@github.com/${OWNER}/${REPO_NAME}.git" . 2>&1 || exit 1

git checkout -b "$BRANCH_NAME" 2>&1 || exit 1

# Smart code generation based on command keywords
log_step "🤖 Generating code..."

FILES_CREATED=0
STREAMLIT_READY=false

# Python Calculator with Streamlit
if [[ "$COMMAND" =~ [Pp]ython ]] && [[ "$COMMAND" =~ [Cc]alculator ]]; then
    log_info "Creating Python calculator with Streamlit deployment..."
    
    # Main calculator app (tkinter version for local use)
    cat > calculator.py << 'EOF'
#!/usr/bin/env python3
"""Moaning Calculator - Desktop version with tkinter"""
import tkinter as tk
import random

class MoaningCalculator:
    MOANS = ["Oh yeah!", "Mmm!", "Ah!", "Oh!", "Yes!", "Mmm-hmm!", "Oh baby!"]
    
    def __init__(self, root):
        self.root = root
        root.title("Moaning Calculator 😏")
        root.geometry("320x420")
        root.configure(bg="#2b2b2b")
        
        self.expression = ""
        self.display = tk.Entry(root, font=('Arial', 24, 'bold'),
                               bg="#1a1a1a", fg="white",
                               justify='right', bd=0)
        self.display.grid(row=0, column=0, columnspan=4, padx=15, pady=20, sticky='ew')
        
        buttons = [
            ('7',1,0), ('8',1,1), ('9',1,2), ('/',1,3),
            ('4',2,0), ('5',2,1), ('6',2,2), ('*',2,3),
            ('1',3,0), ('2',3,1), ('3',3,2), ('-',3,3),
            ('0',4,0), ('.',4,1), ('=',4,2), ('+',4,3),
            ('C',5,0), ('⌫',5,1)
        ]
        
        for (txt, r, c) in buttons:
            bg = "#ff6b6b" if txt == '=' else "#3c3c3c"
            btn = tk.Button(root, text=txt, font=('Arial',18,'bold'),
                           width=5, height=2, bg=bg, fg='white',
                           activebackground="#4a4a4a",
                           command=lambda t=txt: self.click(t))
            btn.grid(row=r, column=c, padx=5, pady=5)
        
        for i in range(6): root.grid_rowconfigure(i, weight=1)
        for i in range(4): root.grid_columnconfigure(i, weight=1)
    
    def click(self, char):
        print(f"🔊 {random.choice(self.MOANS)}")
        if char == '=':
            try: self.expression = str(eval(self.expression))
            except: self.expression = "Error"
        elif char == 'C': self.expression = ""
        elif char == '⌫': self.expression = self.expression[:-1]
        else: self.expression += str(char)
        self.display.delete(0, tk.END)
        self.display.insert(0, self.expression)

if __name__ == "__main__":
    root = tk.Tk()
    app = MoaningCalculator(root)
    root.mainloop()
EOF

    # Streamlit web version (for online deployment)
    cat > streamlit_app.py << 'EOF'
import streamlit as st
import random

st.set_page_config(page_title="Moaning Calculator 😏", page_icon="😏", layout="centered")

st.title("😏 Moaning Calculator")
st.markdown("*A calculator that expresses itself vocally!*")

# Initialize session state
if 'expression' not in st.session_state:
    st.session_state.expression = ""
if 'last_moan' not in st.session_state:
    st.session_state.last_moan = ""

MOANS = ["Oh yeah!", "Mmm!", "Ah!", "Oh!", "Yes!", "Mmm-hmm!", "Oh baby!", "Ahh!"]

def moan():
    moan_text = random.choice(MOANS)
    st.session_state.last_moan = moan_text
    return moan_text

def calculate():
    try:
        result = str(eval(st.session_state.expression))
        st.session_state.expression = result
    except:
        st.session_state.expression = "Error"

def clear():
    st.session_state.expression = ""
    st.session_state.last_moan = ""

def backspace():
    st.session_state.expression = st.session_state.expression[:-1]
    st.session_state.last_moan = ""

def append(char):
    moan()
    st.session_state.expression += str(char)

# Display
st.markdown(f"""
    <style>
    .stTextInput > div > div > input {{
        font-size: 32px;
        text-align: right;
        background-color: #1a1a1a;
        color: white;
    }}
    </style>
""", unsafe_allow_html=True)

# Expression display
st.text_input("Display", value=st.session_state.expression, 
              key="display", disabled=True, label_visibility="collapsed")

# Last moan display
if st.session_state.last_moan:
    st.success(f"🔊 *{st.session_state.last_moan}*")

# Button layout
col1, col2, col3, col4 = st.columns(4)

with col1:
    if st.button("7", use_container_width=True, key="7"): append("7")
    if st.button("4", use_container_width=True, key="4"): append("4")
    if st.button("1", use_container_width=True, key="1"): append("1")
    if st.button("0", use_container_width=True, key="0"): append("0")

with col2:
    if st.button("8", use_container_width=True, key="8"): append("8")
    if st.button("5", use_container_width=True, key="5"): append("5")
    if st.button("2", use_container_width=True, key="2"): append("2")
    if st.button(".", use_container_width=True, key="dot"): append(".")

with col3:
    if st.button("9", use_container_width=True, key="9"): append("9")
    if st.button("6", use_container_width=True, key="6"): append("6")
    if st.button("3", use_container_width=True, key="3"): append("3")
    if st.button("=", use_container_width=True, key="eq"): calculate()

with col4:
    if st.button("/", use_container_width=True, key="div"): append("/")
    if st.button("*", use_container_width=True, key="mul"): append("*")
    if st.button("-", use_container_width=True, key="sub"): append("-")
    if st.button("+", use_container_width=True, key="add"): append("+")

# Bottom row
col5, col6 = st.columns(2)
with col5:
    if st.button("C", use_container_width=True, key="clear"): clear()
with col6:
    if st.button("⌫", use_container_width=True, key="back"): backspace()

st.markdown("---")
st.markdown("🔊 *Click any button to hear the calculator moan!*")
st.caption("Built with Streamlit | Deploy on Streamlit Cloud")
EOF

    # Requirements
    cat > requirements.txt << 'EOF'
# Moaning Calculator
# Desktop: python calculator.py
# Web: streamlit run streamlit_app.py

streamlit==1.32.0
# Optional for desktop audio:
# playsound==1.3.0
EOF

    # Streamlit config
    mkdir -p .streamlit
    cat > .streamlit/config.toml << 'EOF'
[theme]
primaryColor = "#ff6b6b"
backgroundColor = "#2b2b2b"
secondaryBackgroundColor = "#3c3c3c"
textColor = "#ffffff"
font = "sans serif"
EOF

    # README with deployment instructions
    cat > README.md << EOF
# 😏 Moaning Calculator

A calculator that moans on every button click!

## 🎮 Try It Online

**Deploy on Streamlit Cloud (FREE):**

1. Go to https://streamlit.io/cloud
2. Sign in with GitHub
3. Click "New app"
4. Select this repository: \`$REPO_URL\`
5. Select branch: \`${BRANCH_NAME}\`
6. Main file path: \`streamlit_app.py\`
7. Click "Deploy!"

You'll get a live URL like: \`https://your-username-test-streamlit-app-abc123.streamlit.app\`

## 🖥️ Run Locally

### Desktop Version (tkinter)
\`\`\`bash
python calculator.py
\`\`\`

### Web Version (Streamlit)
\`\`\`bash
pip install -r requirements.txt
streamlit run streamlit_app.py
\`\`\`

## Features
- 🔢 Basic math operations (+, -, *, /)
- 🔊 Sound effects on every click (prints moans)
- 🎨 Dark theme UI
- 🌐 Web-ready with Streamlit
- 📱 Responsive design

## Tech Stack
- **Desktop:** Python + tkinter
- **Web:** Streamlit
- **Deployment:** Streamlit Cloud (free)

---
Generated from: ${COMMAND}
Branch: ${BRANCH_NAME}
EOF

    FILES_CREATED=6
    STREAMLIT_READY=true
    log_deploy "✅ Streamlit app ready for deployment!"
fi

# Fallback: Generic project
if [ $FILES_CREATED -eq 0 ]; then
    log_warn "Using generic template..."
    cat > README.md << EOF
# Generated Project

Command: ${COMMAND}

## Setup
Add your setup instructions here.

Generated: $(date)
EOF
    FILES_CREATED=1
fi

log_info "📦 Files: $FILES_CREATED"

# Git operations
git add . 2>&1 || exit 1

if ! git diff --cached --quiet; then
    # Syntax check for Python
    if ls *.py 1>/dev/null 2>&1; then
        log_step "🔍 Checking Python syntax..."
        python3 -m py_compile *.py 2>&1 && log_info "✅ OK" || log_warn "⚠️ Issues"
    fi
    
    git commit -m "feat: Generate ${TOPIC}

Command: ${COMMAND}
Files: ${FILES_CREATED}
Streamlit: ${STREAMLIT_READY}
AI: OpenClaw Agent" 2>&1 || exit 1
    
    log_step "🚀 Pushing..."
    git push -u origin "$BRANCH_NAME" 2>&1 || exit 1
    
    # Create PR with deployment instructions
    DEPLOY_INSTRUCTIONS=""
    if [ "$STREAMLIT_READY" = true ]; then
        DEPLOY_INSTRUCTIONS="

## 🚀 Deploy Online (FREE)

1. Go to https://streamlit.io/cloud
2. Sign in with GitHub
3. Click **New app**
4. Select this repo: \`${REPO_URL}\`
5. Branch: \`${BRANCH_NAME}\`
6. Main file: \`streamlit_app.py\`
7. Click **Deploy!**

You'll get a live URL to test instantly! 🎉"
    fi
    
    log_step "📬 Creating PR..."
    PR_RESPONSE=$(curl -s -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/${OWNER}/${REPO_NAME}/pulls \
        -d "{\"title\":\"feat: ${TOPIC} 🚀\",\"body\":\"Generated from command\\n\\n\`\`\`\\n${COMMAND}\\n\`\`\`\\n${DEPLOY_INSTRUCTIONS}\\n\\n---\\n*Built by OpenClaw Code Agent*\",\"head\":\"${BRANCH_NAME}\",\"base\":\"main\"}" 2>&1)
    
    PR_URL=$(echo "$PR_RESPONSE" | grep -o '"html_url": "[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$PR_URL" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ BUILD COMPLETE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 Topic: ${TOPIC}"
        echo "🌿 Branch: ${BRANCH_NAME}"
        echo "📬 PR: ${PR_URL}"
        echo "📦 Files: ${FILES_CREATED}"
        if [ "$STREAMLIT_READY" = true ]; then
            echo "🌐 Deploy: https://streamlit.io/cloud"
        fi
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        log_error "PR creation failed"
        echo "$PR_RESPONSE"
        exit 1
    fi
else
    log_warn "⚠️ No changes"
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"
log_info "🎉 Done!"
