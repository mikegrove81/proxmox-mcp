Scaffold a new local git repo under `C:\Repo`. Follow the complete workflow defined in `skills/new-project/SKILL.md`.

1. Parse the project name from args — ask if omitted
2. Validate the path doesn't already exist and name is PascalCase or kebab-case
3. Create folder structure (`docs/`, `references/`), `.gitignore`, and `CLAUDE.md`
4. `git init`, add all, commit with `init: {ProjectName} scaffolded via /new-project`
5. Add a PowerShell alias to the PS profile — confirm alias before adding
6. CD into the new repo and report ready state

When the project is ready for GitHub, use `/graduate-project`.

Read the full skill file for folder structure, gitignore contents, and alias rules.
