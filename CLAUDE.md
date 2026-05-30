# Proxmox MCP Server

MCP server that gives Claude tools to manage a Proxmox VE server — start/stop VMs, check status, manage drives, control Samba shares.

## Memory

This project's memory lives at `.claude/memory/` inside this repo — use that path for all reads and writes, not the default `~/.claude/projects/` path.

## Skills

Skills in `skills/` auto-trigger based on their descriptions:

- **session-start** - Open a session: sync git, load context (`/start`)
- **session-sync** - Mid-session checkpoint: commit and push (`/sync`)
- **session-wrap** - Close a session: digest, commit, push (`/wrap`)
- **compound** - Extract reusable patterns after deliverables (`/compound`)
- **update-core** - Pull core skill updates from home-dev (`/update-core`)
