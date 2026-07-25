# Database Access Resolution

When working in any repo, resolve database access as follows:

## Resolution Workflow

1. **Read `.claude/db-access.conf`** in the current repo for access scope (which databases, read/write)
2. **Use the MCP alias from db-access.conf** as the `instance` parameter when calling MCP tools
3. If the user refers to a server by canonical name (e.g., "localhost"), resolve to the MCP alias before calling MCP tools

## How It Works

- `db-access.conf` entries use the `sql:` prefix and **MCP aliases** as the server portion
- These aliases match the instance names configured in the SQL MCP server's `appsettings.json`
- The guard hooks in `server-aliases.conf` map these same aliases to canonical server names for access validation
- Pass the MCP alias directly to MCP tools - the MCP server only recognizes aliases, not canonical names

## MCP Alias Reference

| MCP Alias | Canonical Server | Description |
|-----------|-----------------|-------------|
| SQL | localhost | Local SQL Server (default instance) |

## Example

Given db-access.conf contains:
```
sql: SQL/MyDatabase = read
```

Pass `SQL` as the instance to MCP tools:
```
mcp__sql__sql_query(instance="SQL", database="MyDatabase", query="...")
```

## Key Rules

- `db-access.conf` is the source of truth for access scope (which databases, read/write)
- Entries use the format: `sql: {alias}/{database} = read|write`
- MCP tools only accept the alias (SQL) - passing canonical server names causes errors
- Both `db-access.conf` and `server-aliases.conf` are protected by access-control-immutable.md - never edit them directly
