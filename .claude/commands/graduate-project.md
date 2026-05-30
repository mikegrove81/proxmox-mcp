Promote a local project repo to GitHub. Follow the complete workflow defined in `skills/graduate-project/SKILL.md`.

1. Parse the project name from args — if omitted, list repos in `C:\Repo` without a GitHub remote and ask
2. Validate the repo exists and has at least one commit
3. Ask for GitHub repo name (suggest lowercase) and visibility (default: private)
4. Create the remote with `gh repo create mikegrove81/{name} --private --source=. --push`
5. Report the GitHub URL and visibility

Read the full skill file for validation rules and pitfalls.
