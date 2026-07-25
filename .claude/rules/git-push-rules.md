# Git Push Rules

## Two-Tier Policy

Classify every repo by whether it has a git `origin` remote. Test with `git remote get-url origin`:

- **Remote-backed** - `git remote get-url origin` succeeds (the repo has an `origin`). Commit AND push in every git workflow.
- **Local-only** - `git remote get-url origin` fails (no `origin` configured). Commit only; never push.

The folder name is NOT used to classify repos. Identity is decoupled from the folder name - a repo can be renamed freely without changing its push behavior. See `.claude/repo.md` for a repo's identity, description, and stakeholders.

## Remote-Backed Repos

These have an `origin` remote (typically `github.com/mikegrove81/<name>`; home-dev itself is one). Push after committing in:
- /start: push the pre-start checkpoint commit
- /sync: push after the checkpoint commit
- /wrap: push after the session-end commit
- /repo-updatecore, /compound, /sync-out: push after committing
- Any other workflow: commit is fine, and push is expected

If the current branch has no upstream yet, use `git push -u origin <branch>` (home-dev is `master`).

**Never force-push.** Pull policy is a session-skill decision, not a blanket rule: home-dev's `/start` may `git pull` to pick up edits made from another machine; child repos must never `git pull` home-dev (see session-start Common Pitfalls). A local-only repo has no remote to pull from.

## Local-Only Repos

Repos with no `origin` remote - typically a fresh `/project-new` repo before `/project-graduate` adds the GitHub remote. Do NOT attempt `git push` in any context - session skills (/start, /sync, /wrap), manual commits, or admin skills. Commit locally only. Never `git pull` either.
