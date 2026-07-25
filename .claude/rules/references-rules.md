---
paths:
  - "references/**"
---

# Reference File Rules

Reference files contain technology standards, ETL patterns, and architectural guidance. They are the foundation layer — not operational state.

## Loading Rules

- Check the summary field in frontmatter before loading the full file
- Load reference files on demand, not preemptively
- Multiple reference files may be relevant to a task — scan frontmatter to decide

## Modification Rules

- References in this vault are actively developed — edits are permitted
- Compound-learning may propose reference updates when learnings generalize beyond a single task
- When editing: maintain YAML frontmatter, update the `updated:` date, keep the summary current
- Do not move operational facts into reference files — those belong in memory/
