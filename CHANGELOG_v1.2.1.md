# TAD Framework v1.2.1 - Critical Design Fixes

**Release Date:** 2025-01-30
**Type:** Patch Release (Critical bug fixes and design improvements)

---

## 🚨 Critical Design Fixes

### 1. MCP Installation Philosophy Correction

**Problem:** Original v1.2 design required humans to manually run `tad mcp install` CLI commands, which violated TAD's agent-driven philosophy.

**User Feedback:**
> "MCP 不应该是 Agent，它可以自己主动安装吗？为什么要我人工去安装呢？"
> (Translation: "Shouldn't MCP be installed by the Agent itself? Why do humans need to manually install it?")

**Solution:**
- ✅ **Alex now installs MCPs automatically** using the Bash tool
- ✅ **No human CLI needed** - entire process is agent-driven
- ✅ **Seamless workflow** - Alex handles installation in Round 2.5 (20-30 seconds)
- ✅ **User only chooses** - Select 0 (install all) / 1 (choose) / 2 (skip)

**Files Changed:**
- `.tad/tasks/requirement-elicitation.md` - Round 2.5 now uses Bash tool
- `.tad/agents/agent-a-architect-v1.1.md` - Added `mcp_installation` section
- `.tad/MCP_USAGE_GUIDE.md` - Updated with agent-driven installation flow

---

## 🔧 Configuration Improvements

### 2. Config File Clarity

**Problem:** Multiple config files (config.yaml, config-v1.1.yaml, config-v2.yaml, config-v3.yaml) with no clear indication of which is active.

**Solution:**
- ✅ **Added Configuration section to README.md** explaining active config
- ✅ **Created symlink**: `config.yaml → config-v3.yaml` for clarity
- ✅ **Updated .gitignore** to properly track configs
- ✅ **install.sh** now automatically creates the symlink

**Files Changed:**
- `README.md` - Added "Configuration" section
- `install.sh` - Added symlink creation (lines 120-123)
- `.gitignore` - Updated to track symlink

---

## 🛠️ New TAD CLI

### 3. Simple Framework Management CLI

**Philosophy:** CLI is for framework management only, NOT for agent work.

**Commands:**
```bash
./tad version   # Show TAD version from .tad/version.txt
./tad doctor    # Run comprehensive health check
./tad upgrade   # Upgrade to latest version
./tad help      # Show usage information
```

**What's NOT included (by design):**
- ❌ `tad init` - Agent A handles project initialization
- ❌ `tad scenario` - Agent A handles scenario analysis
- ❌ `tad handoff` - Agent A creates handoff documents
- ❌ `tad gate-check` - Agent B handles quality gates
- ❌ `tad mcp install` - Agents install MCPs automatically

**Files Changed:**
- Created `tad` bash script (143 lines)
- Updated `install.sh` to install the CLI
- Updated `README.md` with CLI documentation

---

## 📝 Documentation Updates

### 4. MCP Usage Guide Overhaul

**Changes:**
- 🚨 **Added prominent warning** about agent-driven installation
- ✅ **Updated Quick Start** from 3 steps to 2 steps (removed manual install)
- ✅ **Added example workflow** showing Alex auto-installing MCPs
- ✅ **Marked CLI commands as deprecated** (kept for reference only)

**Files Changed:**
- `.tad/MCP_USAGE_GUIDE.md` - Major update with new installation flow

### 5. README Improvements

**Changes:**
- ✅ Added "Configuration" section explaining which config is active
- ✅ Updated "Next Steps" with `./tad doctor` instead of `/tad-status`
- ✅ Added "CLI Commands" section with usage examples
- ✅ Clarified CLI scope (framework management vs agent work)

**Files Changed:**
- `README.md` - Updated sections and added CLI documentation

---

## 🔍 Testing Recommendations

Before deploying, test these scenarios:

### Fresh Installation Test:
```bash
# In a new project
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
./tad version  # Should show "TAD Framework v1.2"
./tad doctor   # Should show all green checkmarks
/alex          # Should activate Agent A successfully
```

### Upgrade from v1.1 Test:
```bash
# In existing v1.1 project
./tad upgrade  # Should upgrade to v1.2 via upgrade-to-v1.2.sh
./tad doctor   # Should verify all components
```

### MCP Auto-Installation Test:
```bash
# Terminal 1:
/alex
# Tell Alex: "我想用 Next.js 和 Supabase 做全栈应用"
# Alex should auto-detect project type in Round 2.5
# Alex should offer to install supabase, playwright, vercel
# Select option 0
# Alex should use Bash tool to install automatically (20-30s)
# Should proceed to Round 3 without human intervention
```

---

## 📊 Summary of Changes

**Files Modified:** 6
- `.tad/tasks/requirement-elicitation.md`
- `.tad/agents/agent-a-architect-v1.1.md`
- `.tad/MCP_USAGE_GUIDE.md`
- `README.md`
- `install.sh`
- `.gitignore`

**Files Created:** 2
- `tad` (CLI script)
- `CHANGELOG_v1.2.1.md` (this file)

**Lines Changed:** ~200 lines across all files

---

## 🎯 Impact

### User Experience Improvements:
- ⚡ **Faster workflow** - No manual CLI commands needed
- 🎨 **Cleaner experience** - Alex handles all MCP installation
- 📚 **Clearer documentation** - Config and CLI usage well-explained
- 🔧 **Better tooling** - Simple `tad` command for framework management

### Design Alignment:
- ✅ **Philosophy-correct** - Agents do the work, humans provide value
- ✅ **Non-invasive** - All changes are additive, zero breaking changes
- ✅ **Backward compatible** - v1.2 users can upgrade seamlessly

---

## 🚀 Upgrade Instructions

### From v1.2 to v1.2.1:
```bash
# Pull latest changes
git pull origin main

# Or re-run installer
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

# Verify
./tad version  # Should show v1.2
./tad doctor   # Should verify installation
```

### From v1.1 to v1.2.1:
```bash
# Use upgrade script
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.2.sh | bash

# Or use install script (auto-detects and upgrades)
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

# Verify
./tad version
./tad doctor
```

---

## 📦 Next Steps

1. **Test thoroughly** - Use the testing scenarios above
2. **Commit changes** - Create a clean commit for v1.2.1
3. **Update version** - Consider bumping to v1.2.1 in version.txt
4. **Tag release** - Create v1.2.1 tag if releasing as patch
5. **Update GitHub** - Push changes and update release notes

---

## 🙏 Credits

This release was driven by user feedback highlighting a fundamental design flaw in the original v1.2 MCP installation approach. The user correctly identified that MCP installation should be agent-driven, not human-driven, aligning perfectly with TAD's core philosophy.

**Key Insight:**
> "为什么要我人工去安装呢？" (Why do I need to manually install it?)

This simple question led to a complete redesign of the MCP installation workflow, making TAD v1.2 truly agent-driven and philosophically consistent.

---

**End of Changelog**
