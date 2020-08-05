# Build Scripts

This folder contains scripts to help build a release

- [Configuration](#configuration)
- [Build a Release](#build-a-release)
- [Files](#files)
  - [`apex_export_app.sql`](#apex_export_appsql)

## Configuration

The first time you run the build script (ex: `./build.sh 1.0.0`) an error will be displayed an a new file (`scripts/user-config.sh`) will be created. `user-config.sh` is in the `.gitignore` file so you can store more sensitive information without it being checked in.

`user-config.sh` is self documented and requires some configuration before the build will work

## Build a Release

To build a release simply run:

```bash
# Change "version" for your version number
./build.sh version
```

By default this script will scrape the `views` and `packages` folder and generate `release/all_views.sql` and `release/all_packages.sql`

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