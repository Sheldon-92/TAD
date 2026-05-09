# Mobile Development Setup Guide

Remote control home Mac from phone via SSH.

---

## Architecture

```
iPhone (Termius App)
  → Tailscale (encrypted tunnel)
  → SSH into Home Mac
  → Run happy / claude in any project
```

## Prerequisites

- Home Mac always on (plugged in, sleep disabled)
- iPhone with Tailscale + Termius installed

---

## Home Mac Setup (one-time)

### Step 1: Install Node.js 22 via nvm

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Restart terminal, then:
nvm install 22
nvm alias default 22
```

### Step 2: Install CLI tools

```bash
npm install -g happy-coder @anthropic-ai/claude-code
brew install tmux
```

### Step 3: Enable Remote Login (SSH)

> System Settings → General → Sharing → Remote Login → ON

### Step 4: Install Tailscale

> App Store → search "Tailscale" → install → sign in with PERSONAL account (not school/work)

Note the Mac's Tailscale IP:
```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale ip
```

### Step 5: Add project shortcuts to .zshrc

```bash
# Add to ~/.zshrc:
alias tad='cd ~/01-on\ progress\ programs/TAD && echo "=== TAD ===" && happy'
alias menusnap='cd ~/01-on\ progress\ programs/menu-snap && echo "=== Menu Snap ===" && happy'
alias heguiai='cd ~/01-on\ progress\ programs/合规ai && echo "=== 合规AI ===" && happy'
alias capstone='cd ~/01-on\ progress\ programs/capstone && echo "=== Capstone ===" && happy'
alias projects='ls ~/01-on\ progress\ programs/'
```

### Step 6 (Optional): Happy daemon auto-start

Create file `~/Library/LaunchAgents/com.happy-coder.daemon.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.happy-coder.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.nvm/versions/node/v22.22.0/bin/node</string>
        <string>$HOME/.nvm/versions/node/v22.22.0/bin/happy</string>
        <string>daemon</string>
        <string>start</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$HOME/.nvm/versions/node/v22.22.0/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
</dict>
</plist>
```

Then load it:
```bash
launchctl load ~/Library/LaunchAgents/com.happy-coder.daemon.plist
```

### Step 7: Syncthing — Two Macs file sync

Syncthing keeps two Mac's project files in real-time sync (including .tad/, .claude/ etc that git ignores).

```
MacBook A (portable)                    MacBook B (home)
~/01-on progress programs/TAD/   ←P2P→  ~/01-on progress programs/TAD/
  All files, all subdirectories    sync   All files, all subdirectories
```

#### 7a: Install on BOTH Macs

```bash
brew install --cask syncthing-app
```

#### 7b: Start Syncthing on BOTH Macs

Open `/Applications/Syncthing.app`. It runs in the menu bar (two arrows icon).

Click menu bar icon → "Open Syncthing" → opens browser at `http://localhost:8384`

#### 7c: Get Device IDs from BOTH Macs

In the browser UI (localhost:8384):
> Actions (top right) → Show ID

You'll see a long string like `XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-...`
Copy this. You need BOTH Macs' Device IDs.

#### 7d: Add remote device on BOTH Macs

On Mac A's browser UI:
> Bottom right → "Add Remote Device"
> → paste Mac B's Device ID
> → Device Name: `Home Mac` (or whatever you want)
> → Save

On Mac B's browser UI:
> Same thing, paste Mac A's Device ID
> → Device Name: `Portable Mac`
> → Save

Mac B will show a notification "New Device wants to connect" → click Accept.

#### 7e: Add shared folder

On Mac A's browser UI:
> Top left → "Add Folder"
> → Folder Label: `TAD` (display name)
> → Folder Path: `/Users/YOUR_USERNAME/01-on progress programs/TAD`
> → Switch to "Sharing" tab → check the remote device (Home Mac)
> → Save

Mac B will show a notification "Mac A wants to share folder TAD" → click Accept
> → Set the local folder path to the SAME project location on Mac B
> → Save

Repeat for each project you want to sync.

#### 7f: Ignore node_modules (important)

In each synced folder, create a `.stignore` file:

```bash
# In the project root:
echo "node_modules" > .stignore
echo ".git" >> .stignore
echo "dist" >> .stignore
echo ".next" >> .stignore
```

This prevents syncing large generated directories. You can `npm install` separately on each Mac.

#### 7g: Verify sync is working

In the browser UI (localhost:8384):
- Folder should show "Up to Date"
- Remote device should show "Connected"

Change a file on one Mac → within seconds it appears on the other.

#### 7h: Auto-start on login

Syncthing.app adds itself to Login Items by default. Verify:
> System Settings → General → Login Items → check Syncthing is listed

If not, add it manually.

#### Syncthing Tips

- **One-way editing**: Only edit on ONE Mac at a time to avoid conflicts
- **Conflict files**: If both Macs edit the same file simultaneously, Syncthing creates a `.sync-conflict-XXXXX` file — manually resolve
- **Pause sync**: In browser UI, click folder → Pause (useful during large refactors)
- **Monitor**: Menu bar icon shows sync status (green = synced, blue = syncing)

---

## iPhone Setup (one-time)

### Step 1: Install apps

- App Store → **Tailscale** → sign in with SAME personal account as Mac
- App Store → **Termius** (free)

### Step 2: Connect in Termius

- Connections tab → search bar → type: `ssh YOUR_USERNAME@MAC_TAILSCALE_IP`
- Enter Mac login password
- Done

---

## Daily Usage

```
Phone: open Termius → tap connection → type project shortcut:

  tad        → TAD project + Happy
  menusnap   → Menu Snap + Happy
  heguiai    → 合规AI + Happy
  capstone   → Capstone + Happy
  projects   → list all projects
```

---

## Installed Software Summary

| Software | Purpose | Install Method |
|----------|---------|---------------|
| nvm | Node.js version manager | curl script |
| Node.js 22 | Runtime for happy-coder + claude-code | nvm install 22 |
| happy-coder | Mobile Claude Code wrapper | npm install -g |
| claude-code | AI coding assistant | npm install -g |
| tmux | Terminal session persistence | brew install |
| Tailscale | Encrypted tunnel (phone ↔ Mac) | App Store |
| Syncthing | File sync between two Macs | brew install --cask |
| Termius (iPhone) | SSH client | App Store |

---

## Troubleshooting

| Problem | Solution |
|---------|---------|
| SSH connection timeout | Check Tailscale is ON on both devices |
| Tailscale devices not visible | Use personal account, not school/work |
| `happy` command not found | Run `source ~/.nvm/nvm.sh` first |
| Node.js yoga.wasm error | Switch to Node 22: `nvm use 22` |
| Password rejected | Verify Mac login password, check Remote Login is ON |
