# Bare Folder Reference Resolution

When Mike refers to a folder by name without giving a full path, resolve the
location with these rules before acting.

## Resolution

| Reference form | Resolves to |
|----------------|-------------|
| Bare name, no `_` prefix (e.g. `config`, `skills`, `output`) | A folder **inside the current repo** — the repo root or a subfolder of it. |
| `_`-prefixed name (e.g. `_RepoWork`, `_RepoDeprecated`, `_RepoTemp`) | A folder at the **root of the repo fleet**, i.e. `C:\Repo\_*`. These are fleet-level containers, never inside a repo. |

If a bare name is ambiguous within the current repo (matches more than one
subfolder), ask which one — do not guess.

If a bare name doesn't clearly exist locally, ask the user for the full path —
do not search the entire system or assume it's at the fleet root.

## `_RepoWork` Is Reference-Only

`C:\Repo\_RepoWork` (gpg-development and its work-family repos) is **read-only**.
Never create, edit, move, rename, or delete anything inside it. It exists so
home-dev skills can *read* upstream content (e.g. `/repo-updatecore` pull,
`/sync-from-gpg`) — never write. The other `_*` containers follow their own
CLAUDE.md taxonomy rules; only home-dev-managed skills touch `_RepoDeprecated`
(`/project-deprecate`, `/project-purge`) and `_RepoTemp` is transient scratch.

## Why

Mike works across a fleet of sibling repos under `C:\Repo`. A bare folder name
is almost always local to whatever repo the session is running in; an
underscore prefix is the signal that he means a fleet-level container one level
up. Getting this wrong means either editing the wrong repo's folder or, worse,
writing into a reference-only work repo.
