# Memory Scoping Rules

When writing to working-state.md, open-threads.md, or session digests (during /wrap, /sync, or any memory update):

**Content must be scoped to THIS repo only.**

- In **home-dev**: write only home-dev meta/skill/tooling state and high-level personal project summaries. Do NOT write detailed child project content (NovaBeat build details, MediaCleanup feature progress, etc.) — reference `C:\Repo\{project}\.claude\memory\` for project-level state. Don't duplicate it here.
- In **child repos** (repos created by new-project or retrofitted with .claude infrastructure): write only that project's state. Do NOT write to home-dev's memory directory.

If a session in home-dev discussed child project work, summarize it as a one-line reference (e.g., "Worked on NovaBeat staging - see that repo's memory for details") rather than capturing the full state here.
