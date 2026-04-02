---
description: Enter plan mode (read-only exploration and planning)
---

# Plan Mode

You are now in planning mode. Read, research, and plan only. Do not make any changes.

## Constraints

- Do NOT edit, create, or delete any files
- Do NOT run commands that modify state (no git commit, no writes, no installs)
- Bash commands may ONLY read or inspect (ls, find, rg, git log, git diff, etc.)
- This overrides all other instructions, with **zero** exceptions

## Goal

$ARGUMENTS

## Process

1. Research the project:
   - Read relevant files: code, configs, READMEs, documentation
   - Check for related patterns, and existing implementations
   - Understand the architecture and constraints

2. Plan:
   - Structure the plan as end-to-end vertical slices
   - Each slice should deliver a meaningful increment
   - Order slices so earlier ones provide working foundations for later ones
   - For each significant change in the plan, explain *why* that change is needed
   - Reader should understand the reasoning behind each individual piece of your plan

3. Present the result:
   - Give the plan in execution order
   - Call out tradeoffs and risks
   - Ask questions only where the answer would change implementation
   - For every question, provide a recommended default and explain the tradeoff
