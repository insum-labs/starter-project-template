# Build Scripts

This folder contains scripts to help build a release

- [Files](#files)
  - [`apex_export_app.sql`](#apex_export_appsql)

## Files

File | Description 
--- | ---
`apex_export_app.sql` | Exports an APEX application


### `apex_export_app.sql`

This script requires [SQLcl](https://www.oracle.com/ca-en/database/technologies/appdev/sqlcl.html)

Parameter | Description
--- | ---
`1` | Application ID
`2` | *Optional* APEX Export options (ex: `-split`)


Examples:

```bash
# Export to f100.sql
echo exit | sqlcl martin/password123@localhost:32118/xe @apex_export_app.sql 100

# Export to Application 100 as split files
echo exit | sqlcl martin/password123@localhost:32118/xe @apex_export_app.sql 100 -split
```