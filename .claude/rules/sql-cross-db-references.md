# SQL Cross-Database Object References

## Rule

SQL objects (views, stored procedures, functions, triggers) must only reference other objects within databases the project has **write access** to, as defined in `.claude/db-access.conf`.

Do not create objects that depend on databases you only have read access to, and never reference system databases (msdb, master, tempdb, model) as object dependencies.

## Why

Cross-database dependencies on databases you don't own are fragile:
- The source object can change or be removed without notice
- Read access can be revoked, breaking your objects silently
- System databases are not under application control

Write-access databases are the ones the project controls. That's the safe boundary for object dependencies.

## When You Need Logic From Outside Your Boundary

- **Functions/scalar logic:** Duplicate the function code into a database you own
- **Data:** Stage it via ETL (console app, stored procedure, scheduled job) rather than cross-database joins in views or procs

## What This Does NOT Restrict

- **Ad-hoc queries** that JOIN across databases for analysis are fine
- **ETL processes** that READ from source databases and WRITE to owned databases are fine
- The restriction applies to **persisted objects** (views, procs, functions) that would create a runtime dependency on another database
