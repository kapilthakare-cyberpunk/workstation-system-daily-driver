# CLAUDE.md - Workstation System Daily Driver Configuration

> **System:** Linux Mint 22.3 (Zena) | Intel i5-1135G7 @ 2.40GHz | 7.5GB RAM | 366GB SSD
> **Shell:** Zsh + Oh My Zsh + Powerlevel10k | **Editor:** Nano
> **Created:** 2026-04-07 | **Maintained by:** Claude

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `claude-start` | Launch optimized Claude session |
| `daily-sync` | Sync projects, cleanup, backup |
| `project-new <name>` | Create new project from template |
| `downloads-organize` | Auto-sort Downloads by file type |
| `system-health` | Check CPU, RAM, disk, temps |
| `mcp-status` | Show running MCP servers |

---

## System Optimization

### Boot Time Optimization (< 15s target)

**Current Status:**
```bash
# Check current boot time
systemd-analyze blame | head -10
systemd-analyze critical-chain
```

**Disabled Services (keep these disabled):**
```bash
# AI/Development tools that auto-start (disable to speed up boot)
sudo systemctl disable --now snapd  # If not using snaps
disable all MCP servers from auto-starting
disable unused AI assistant background services
```

**Fast Boot Settings:**
```bash
# In /etc/default/grub - set these:
GRUB_TIMEOUT=1
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nomodeset"
# Then: sudo update-grub
```

**Startup Applications (whitelist only):**
- Network Manager
- Cinnamon desktop core
- Powerlevel10k instant prompt
- **NO** AI tools at startup (start on-demand)

### Memory Management (7.5GB constraint)

**Zsh Optimization:**
```bash
# In ~/.zshrc - already optimized:
# - Powerlevel10k instant prompt enabled
# - Lazy-load NVM: export NVM_LAZY_LOAD=true
# - Skip MCP initialization message (already disabled)
```

**Swappiness (reduce swap usage):**
```bash
# /etc/sysctl.conf
vm.swappiness=10
vm.vfs_cache_pressure=50
```

**Memory-hungry tools (start on-demand only):**
- Docker (start when needed: `sudo systemctl start docker`)
- Ollama (local LLM)
- All MCP servers

---

## Folder Organization Standards

### Home Directory Structure

```
~/
├── Projects/           # Active development projects
│   ├── Archive/       # Old/completed projects
│   └── _docs/         # Project documentation
│
├── Documents/          # Personal documents
│   ├── archive/        # Old documents
│   ├── code/         # Code snippets, scripts
│   └── desktop-archive/  # Archived Desktop items
│
├── Downloads/            # Organized automatically
│   ├── Archives/      # .zip, .tar, .gz
│   ├── Code/          # Source files, repos
│   ├── Images/        # Screenshots, photos
│   ├── Installers/    # .deb, .AppImage
│   ├── Media/         # Videos, audio
│   ├── PDFs/          # Documents
│   ├── Spreadsheets/  # .ods, .xlsx
│   └── Misc/          # Uncategorized
│
├── Pictures/           # Personal photos
│   ├── 2025/         # Year-based organization
│   ├── 2026/
│   └── Desktop-Imports/  # Screenshots, temp
│
├── Desktop/            # Keep minimal!
│   └── (only active working files)
│
├── Backups/            # System backups
├── Configs/            # Dotfiles backup
├── docs/               # General documentation
├── bin/                # Personal scripts
└── tmp/                # Temporary working space
```

### Automatic Organization Rules

**Downloads Auto-Sort Script:**
```bash
#!/bin/bash
# ~/bin/downloads-organize

DOWNLOADS="$HOME/Downloads"

# Archives
mv -n $DOWNLOADS/*.{zip,tar,gz,bz2,xz,7z,rar} $DOWNLOADS/Archives/ 2>/dev/null

# Code
mv -n $DOWNLOADS/*.{js,ts,py,go,rs,java,c,cpp,h,json,yaml,yml} $DOWNLOADS/Code/ 2>/dev/null
mv -n $DOWNLOADS/*-main $DOWNLOADS/Code/ 2>/dev/null  # GitHub zips

# Images
mv -n $DOWNLOADS/*.{jpg,jpeg,png,gif,webp,svg,bmp,raw,cr2} $DOWNLOADS/Images/ 2>/dev/null
mv -n $DOWNLOADS/*screenshot* $DOWNLOADS/Images/ 2>/dev/null

# Installers
mv -n $DOWNLOADS/*.{deb,AppImage,flatpakref} $DOWNLOADS/Installers/ 2>/dev/null

# Media
mv -n $DOWNLOADS/*.{mp4,mkv,avi,mov,webm,mp3,wav,flac} $DOWNLOADS/Media/ 2>/dev/null

# PDFs
mv -n $DOWNLOADS/*.pdf $DOWNLOADS/PDFs/ 2>/dev/null

# Spreadsheets
mv -n $DOWNLOADS/*.{ods,xlsx,xls,csv} $DOWNLOADS/Spreadsheets/ 2>/dev/null
```

**Cron job for daily organization:**
```bash
# Add to crontab: crontab -e
*/30 * * * * $HOME/bin/downloads-organize >/dev/null 2>&1
0 2 * * * $HOME/bin/daily-sync >/dev/null 2>&1
```

---

## Development Environment

### Project Templates

**New Project Script:**
```bash
#!/bin/bash
# ~/bin/project-new

PROJECT_NAME=$1
PROJECT_TYPE=${2:-nodejs}  # nodejs, python, go
PROJECT_DIR="$HOME/Projects/$PROJECT_NAME"

mkdir -p $PROJECT_DIR
cd $PROJECT_DIR
git init

# Create based on type
case $PROJECT_TYPE in
  nodejs)
    npm init -y
    echo "node_modules/\n.env\ndist/\n*.log" > .gitignore
    ;;
  python)
    python -m venv venv
    echo "venv/\n__pycache__/\n.env\n*.pyc\n.pytest_cache/" > .gitignore
    ;;
  go)
    go mod init "github.com/kapilt/$PROJECT_NAME"
    echo "bin/\ndist/\n.env\n*.exe" > .gitignore
    ;;
esac

# Common files
cat > README.md << 'EOF'
# PROJECT_NAME

## Quick Start

## Development

## Deployment
EOF

cat > .claude.md << 'EOF'
# PROJECT_NAME Context

## Tech Stack
- 

## Commands
- Start: 
- Test: 
- Build: 

## Notes
EOF

echo "Project $PROJECT_NAME created in $PROJECT_DIR"
```

### Active Development Tools

**Essential (keep installed):**
- Node.js (via NVM) - Primary runtime
- Go - For CLI tools and backends
- Docker - Containerization
- Claude Code - AI development

**AI Tools (on-demand start):**
```bash
# Start only when needed
claude-start() {
  cd ~/Projects/claude-marketplace  # or current project
  claude
}

ollama-start() {
  sudo systemctl start ollama
  echo "Ollama started on http://localhost:11434"
}
```

**MCP Server Management:**
```bash
# ~/.zshrc additions
mcp-status() {
  echo "=== MCP Servers ==="
  ps aux | grep -E "mcp|claude" | grep -v grep
}

mcp-kill-all() {
  pkill -f "mcp-server"
  pkill -f "claude.*mcp"
  echo "All MCP servers stopped"
}
```

---

## Daily Workflow Automation

### Morning Routine Script

```bash
#!/bin/bash
# ~/bin/daily-sync

echo "=== Daily System Sync ==="
echo "$(date)"

# 1. Clean Downloads
echo "→ Organizing Downloads..."
$HOME/bin/downloads-organize

# 2. Backup dotfiles
echo "→ Backing up configs..."
cp ~/.zshrc ~/.dotfiles/
cp ~/.bashrc ~/.dotfiles/
cp -r ~/.claude/rules ~/.dotfiles/ 2>/dev/null

# 3. Clean temp files
echo "→ Cleaning temp files..."
rm -rf ~/.cache/thumbnails/*
rm -rf ~/tmp/*

# 4. Docker cleanup (if docker running)
if systemctl is-active --quiet docker; then
  echo "→ Docker cleanup..."
  docker system prune -f --volumes 2>/dev/null
fi

# 5. Update chezmoi/dotfiles
if command -v chezmoi &> /dev/null; then
  chezmoi add ~/.zshrc
  chezmoi git -- commit -m "Daily auto-backup $(date +%Y-%m-%d)"
fi

# 6. Check disk space
echo "→ Disk usage:"
df -h ~ | tail -1

echo "=== Sync Complete ==="
```

### System Health Check

```bash
#!/bin/bash
# ~/bin/system-health

echo "=== System Health ==="
echo "$(date '+%Y-%m-%d %H:%M:%S')"
echo ""

echo "┌─ CPU ───────────────────────"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "Usage: ${cpu_usage}%"
echo "Temperature: $(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{print $1/1000"°C"}')"
echo ""

echo "┌─ Memory ────────────────────"
free -h | grep -E "Mem|Swap"
echo ""

echo "┌─ Disk ──────────────────────"
df -h ~
echo ""

echo "┌─ Top Processes ───────────"
ps aux --sort=-%mem | head -6
echo ""

echo "┌─ Boot Time ─────────────────"
systemd-analyze 2>/dev/null || echo "Systemd not available"
echo ""

echo "=== End Report ==="
```

---

## Claude Code Configuration

### Optimized Settings

**~/.claude/settings.json key settings:**
```json
{
  "alwaysThinkingEnabled": true,
  "autoUpdates": false,
  "numStartups": 29,
  "allowedTools": {
    "Bash": true,
    "Read": true,
    "Write": true,
    "Edit": true,
    "Glob": true,
    "Grep": true,
    "Agent": true
  }
}
```

### Project-Specific Rules

**Active Rules Directories:**
- `~/.claude/rules/common/` - Universal coding standards
- `~/.claude/rules/zh/` - Chinese rule translations
- `~/.claude/rules/web/` - Web development standards

**Quick Rule Reference:**
- 80% test coverage minimum
- No hardcoded secrets
- Immutability pattern enforced
- Functions <50 lines, files <800 lines

### Memory Management

**Memory Location:** `~/.claude/memory/`

**Types stored:**
- `user/` - Your preferences and role
- `project/` - Active work context
- `feedback/` - Corrections and confirmations
- `reference/` - External system pointers

**Best practices:**
- Check MEMORY.md at start of conversations
- Update memories when preferences change
- Delete stale project memories

---

## Backup Strategy

### Local Backup

**What gets backed up:**
```
~/.dotfiles/          # Git repo with dotfiles
~/Backups/
  ├── $(date +%Y%m%d)_home.tar.gz  # Weekly home backup
  └── important/      # Manual critical backups
```

**Backup script:**
```bash
#!/bin/bash
# ~/bin/backup-home

BACKUP_DIR="$HOME/Backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/home_essential.tar.gz \
  --exclude='*/node_modules' \
  --exclude='*/.git' \
  --exclude='*/target' \
  --exclude='*/__pycache__' \
  --exclude='*/venv' \
  --exclude='*/.cache' \
  ~/Documents \
  ~/Projects \
  ~/.zshrc \
  ~/.bashrc \
  ~/.config/nano \
  2>/dev/null

echo "Backup created: $BACKUP_DIR"
```

### Cloud Sync Targets

**Priority sync (if configured):**
1. Projects/ (code repos - already on GitHub)
2. Documents/ (personal files)
3. .dotfiles/ (configuration)

**Exclude from sync:**
- node_modules/, venv/, target/
- .cache/, tmp/
- Downloads/ (auto-organized, temporary)

---

## Troubleshooting

### Slow Boot

```bash
# Diagnose
systemd-analyze blame          # Slow services
systemd-analyze critical-chain # Startup chain
journalctl -b | grep -i error  # Boot errors

# Common fixes
sudo systemctl disable snapd    # If not using snaps
sudo systemctl disable ModemManager  # If no modem
sudo systemctl disable bluetooth     # If not using BT
```

### High Memory Usage

```bash
# Find memory hogs
ps aux --sort=-%mem | head -10

# Clear caches (safe)
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Kill stuck MCP servers
pkill -f "mcp-server"
```

### Full Disk

```bash
# Find large files
cd ~ && du -sh */ 2>/dev/null | sort -hr | head -20

# Clean package caches
sudo apt clean
npm cache clean --force
yarn cache clean

# Clean old logs
sudo find /var/log -name "*.gz" -delete
sudo find /var/log -name "*.old" -delete
```

---

## Security Checklist

### Daily
- [ ] No files on Desktop overnight
- [ ] Downloads organized
- [ ] No secrets in ~/tmp

### Weekly
- [ ] Review dotfiles in git
- [ ] Check for large unknown files
- [ ] Verify backup integrity

### Monthly
- [ ] Rotate API keys if needed
- [ ] Review installed packages
- [ ] Clean old backups (keep last 4)

---

## Maintenance Schedule

| Task | Frequency | Command/Script |
|------|-----------|----------------|
| Organize Downloads | Hourly | `downloads-organize` |
| Daily sync | Daily 2am | `daily-sync` |
| System health | Daily | `system-health` |
| Full backup | Weekly | `backup-home` |
| Update system | Weekly | `sudo apt update && sudo apt upgrade` |
| Clean old backups | Monthly | Keep last 4, delete rest |
| Review CLAUDE.md | Monthly | Update this file |

---

## Quick Commands Reference

```bash
# Navigation
proj() { cd ~/Projects/$1; }
docs() { cd ~/Documents; }
dl() { cd ~/Downloads; }

# System
cpu() { ps aux --sort=-%cpu | head -10; }
mem() { ps aux --sort=-%mem | head -10; }
du-sort() { du -sh */ 2>/dev/null | sort -hr | head -20; }

# Git (add to existing)
gs() { git status; }
gc() { git commit -m "$1"; }
gp() { git push; }

# Development
serve() { python3 -m http.server ${1:-8080}; }
myip() { curl -s ipinfo.io/ip; }
```

---

## Notes & Updates

**Last Updated:** 2026-04-07
**Next Review:** 2026-05-07

**TODO:**
- [ ] Set up daily-sync cron job
- [ ] Configure backup rotation
- [ ] Optimize startup services further
- [ ] Review AI tool startup times

---

*This configuration is maintained by Claude. Update with `/edit CLAUDE.md` or ask Claude to modify specific sections.*
