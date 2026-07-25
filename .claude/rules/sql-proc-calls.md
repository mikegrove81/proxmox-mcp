# SQL Procedure Call Rules

## Never Pass Functions as Procedure Arguments

SQL Server cannot evaluate functions in a procedure call's argument list. Always capture to a variable first.

WRONG: `EXEC [dbo].[SomeProc] @Param = ERROR_MESSAGE();`
WRONG: `EXEC [dbo].[SomeProc] @Param = GETDATE();`
WRONG: `EXEC [dbo].[SomeProc] @Param = ISNULL(@X, 'default');`

RIGHT:
```sql
SET @ErrMsg = ERROR_MESSAGE();
EXEC [dbo].[SomeProc] @Param = @ErrMsg;
```

## Always Bracket-Wrap Object Names

Wrap ALL SQL object names in `[]`. Assume everything is a reserved word or has invalid characters.

WRONG: `SELECT col FROM dbo.MyTable`
RIGHT: `SELECT [col] FROM [dbo].[MyTable]`

This applies to: tables, views, columns, procedures, functions, schemas, indexes, constraints, parameters in DDL.
