#!/bin/bash
# workstation-system-daily-driver setup script

echo "=== Workstation System Daily Driver Setup ==="

# 1. Create Directories
echo "→ Creating local directories..."
mkdir -p ~/bin
mkdir -p ~/.gemini
mkdir -p ~/.claude-mem

# 2. Link/Copy Scripts
echo "→ Installing utility scripts..."
cp bin/* ~/bin/
chmod +x ~/bin/*

# 3. Setup Shell
echo "→ To setup shell, compare your ~/.zshrc with configs/shell/zshrc.example"

# 4. Initialize Configs (if they don't exist)
if [ ! -f ~/.gemini/settings.json ]; then
    echo "→ Initializing Gemini settings..."
    cp configs/gemini/settings.json.example ~/.gemini/settings.json
fi

# 5. Restore Crontab
echo "→ To restore crontab, run: crontab < crontab.example"

echo "=== Setup Complete ==="
echo "Note: Don't forget to add your API keys to ~/.env"
