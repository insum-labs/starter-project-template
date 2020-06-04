# Build Scripts

This folder contains scripts to help build a release

- [Files](#files)
  - [`apex_export_app.sql](#apex_export_appsql)

## Files

File | Description 
--- | ---
`apex_export_app.sql` | Exports an APEX application using [SQLcl](https://www.oracle.com/ca-en/database/technologies/appdev/sqlcl.html)


### `apex_export_app.sql

```bash
# DB_CONN is the connection string for SQLcl to connect to your database.
# Ex: DB_CONN="martin/password123@localhost:32118/xe"
DB_CONN="db_user/db_password@db_sever:db_port/db_sid"

# Comma delimited list of APEX application(s) you want to export
APEX_APP_IDS=123
APEX_EXPORT_OPTIONS=

# Set REPO_ROOT to the to root of your repository
REPO_ROOT=~/git/my-project

# SQLcl command
# By default SQLcl's binary file is "sql". Some people rename to "sqlcl". 
SQLCL_CMD=sqlcl


for APEX_APP_ID in $(echo $APEX_APP_IDS | sed "s/,/ /g")
do
  echo -e "*** APEX Export ***\n"
  cd $START_DIR/../apex
  echo -e "f$APEX_APP_ID:"
  echo exit | sqlcl $DB_CONN @../build/apex_export_app.sql $APEX_APP_ID
  # If you want to add APEX export options (such as -split)
  # echo exit | sqlcl $DB_CONN @../build/apex_export_app.sql $APEX_APP_ID -split

   $3 -split

  # Add release number to app
  sed -i "s/%RELEASE_VERSION%/$VERSION/" f$APEX_APP_ID.sql
done

```