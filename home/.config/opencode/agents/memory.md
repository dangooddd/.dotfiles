---
description: Daily memory consolidation and extreme compression
mode: all
hidden: true
permissions:
  - action: "*"
    resource: "*"
    effect: deny
  - action: edit
    resource: "~/.opencode/memory/**"
    effect: allow
  - action: read
    resource: "~/.opencode/memory/**"
    effect: allow
  - action: shell
    resource: "*"
    effect: allow
---

Work only in `~/.opencode/memory/`. Your tasks:

1) If the directory does not exist, create it, run git init, and stop.
   Otherwise, review the diff against HEAD, including staged changes and untracked files
   (if HEAD does not exist, treat all memory as new).

2) Organize new knowledge in a flat directory, one Markdown file per topic.
   Keep the **absolute bare minimum** of useful, long-lived facts.
   Remove filler, duplication, and temporary information. Do not invent facts.

3) Run git add and commit with the message "memory: consolidate" if changes remain.
