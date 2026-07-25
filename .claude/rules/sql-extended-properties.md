# SQL Extended Properties (ms_description)

All SQL objects created or altered by Claude must include `ms_description` extended properties. These descriptions feed the Data Dictionary and help Claude understand object intent.

## What Requires a Description

| Level | Applies To |
|-------|-----------|
| Object | Tables, Views, Stored Procedures, Functions, Triggers |
| Column | Every column in Tables and Views |
| Parameter | Stored Procedure and Function parameters |

## How to Apply

Use `sp_addextendedproperty` for new objects and `sp_updateextendedproperty` for existing ones. Check existence first to avoid errors.

### Table

```sql
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stages raw invoice headers from vendor API before transform',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'stg_InvoiceHeader';
```

### Column

```sql
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Vendor-assigned unique invoice number',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'stg_InvoiceHeader',
    @level2type = N'COLUMN', @level2name = N'InvoiceNumber';
```

### Stored Procedure

```sql
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Transforms staged invoice headers into warehouse fact table with SCD Type 1 updates',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'TransformInvoiceHeader';
```

### View

```sql
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Joins invoice headers with vendor master for reporting',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vw_InvoiceDetail';
```

## Description Quality

Descriptions must be meaningful, not restated names:
- **Bad:** "The InvoiceHeader table" or "Stores invoice headers"
- **Good:** "Stages raw invoice headers from vendor API before transform to fact table"
- **Bad:** "The InvoiceNumber column"
- **Good:** "Vendor-assigned unique invoice number; used as natural key for dedup"

For columns, describe the business meaning and any non-obvious usage (natural keys, join targets, computed logic).

## When Altering Existing Objects

When modifying an existing object that lacks `ms_description`:
1. Add descriptions for the object itself and any columns/parameters you are touching
2. Do not retroactively describe columns you aren't changing - flag them as missing to the user

## Upsert Pattern

When unsure if a description already exists, use this pattern:

```sql
IF NOT EXISTS (
    SELECT 1 FROM sys.extended_properties
    WHERE major_id = OBJECT_ID(N'dbo.TableName')
      AND minor_id = 0
      AND name = N'MS_Description'
)
    EXEC sp_addextendedproperty
        @name = N'MS_Description', @value = N'Description here',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'TableName';
ELSE
    EXEC sp_updateextendedproperty
        @name = N'MS_Description', @value = N'Description here',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'TableName';
```
