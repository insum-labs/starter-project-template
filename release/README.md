# Release

Oracle releases are very "unforgiving" (i.e., if an error occurs, it can ruin the entire rest of release and make it difficult to back out). As such, the concept provided with this starter template is to provide a way to run releases manually. This methodology considers a "release / build" to be when code **leaves** development (rather than when code goes into production). This means that it's very likely that each time code is finally deployed to production, multiple releases will be deployed.

It's acknowledged that each team and situation is different. If this concept does not work for your situation then it can be deleted / ignored.

## Structure

Some files are provided by default to help guide your release process


### `_release.sql` 

Example release script. This is the only file that will be run for each release, and it references other files in this project. 

You must review this file and modify it accordingly for your project needs. Again, we emphasize that every project is different, and it's expected that this file should be modified to meet your project's needs. Typical examples are included in it but don't necessarily need to be used.

Once the release file has been verified to be correct it's recommend you run it as: 

```bash
git checkout tags/<tag_name/number>
cd release
$SQLCL <connection_string> @_release.sql
```

### The `code` folder

This folder stores non-rerunable code specific to each release. It's recommended to create a file per-ticket. Ex: `code/issue-123.sql`. The contents of `code/issue-123.sql` may contain things such as DDL and DML statements. Re-runnable code (such as views, packages, etc) **should not** be in here. Instead, store them in their appropriate folders included with this project. After each release the contents of the `code` folder will be deleted as it is no longer required.

Each file created in the `code` should be added to `code/_run_release_code.sql`. This file should be cleared after each release. Examples of what `code/_run_release_code.sql` would look like:

```sql
@issue-123.sql
@issue-456.sql
```
