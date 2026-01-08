# TAD Work Directory

**TAD v1.5+** - User Work Area (Separate from Framework)

## Purpose

This directory contains **your project-specific work**, completely separated from TAD framework files.

- ✅ **Safe to version control** - These are your project files
- ✅ **Preserved during upgrades** - Framework updates won't touch this
- ✅ **Project-specific** - Each project has its own tad-work/

## Directory Structure

```
tad-work/
├── handoffs/           # Active handoff documents (Alex → Blake)
├── archive/            # Completed/archived handoffs
├── context/            # Project context and session data
├── working/            # Temporary work files
├── learnings/          # Project-specific learnings (optional)
│   ├── pending/        # Draft learning records
│   └── pushed/         # Pushed to TAD framework repo
└── evidence/           # Quality evidence and metrics
    ├── gates/          # Quality gate execution records
    ├── patterns/       # Discovered patterns
    ├── metrics/        # Performance metrics
    └── project-logs/   # Project logs
```

## What's NOT Here

Framework files (templates, tasks, agent definitions) are in `.tad/`:
- `.tad/config.yaml` - Framework configuration
- `.tad/templates/` - Document templates
- `.tad/tasks/` - Task definitions
- `.tad/learnings/` - Framework improvement suggestions

## Version Control

Recommended `.gitignore` for `tad-work/`:

```gitignore
# Temporary work files
tad-work/working/*
!tad-work/working/.gitkeep

# Session context (optional, keep if you want to preserve)
tad-work/context/*
!tad-work/context/.gitkeep

# Everything else should be committed
```

## Migration from v1.4

If upgrading from TAD v1.4, your files have been migrated:
- `.tad/active/handoffs/` → `tad-work/handoffs/`
- `.tad/archive/` → `tad-work/archive/`
- `.tad/context/` → `tad-work/context/`
- `.tad/working/` → `tad-work/working/`
- `.tad/evidence/` → `tad-work/evidence/`

---

**TAD v1.5** - Framework and User Data Separation
