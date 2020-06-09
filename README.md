
# Starter Project Template

Template for Oracle PL/SQL and/or APEX development projects. It's **important** to note this is a **template**. As such if something doesn't fit your project's need or additional things are required start with this and adjust. All the tools here are meant to help provide results quickly and if they aren't don't use them.

- [Start](#start)
- [Setup](#setup)
- [Getting Started](#getting-started)
- [Folder Structure](#folder-structure)
- [Release Autocomplete](#release-autocomplete)
  - [Release File Configuration](#release-file-configuration)
  - [Run](#run)

## Start

In Github simply click the [`Use this template`](https://github.com/insum-labs/starter-project-template/generate) button. If using another git platform, start a new project (`git init`) then [**download**](https://github.com/insum-labs/starter-project-template/archive/master.zip) this project (*do not clone or fork*) and unzip into your new project.


## Setup

* Setup `apex/_ins.sql` with the correct Workspace & App Number
* Decide if your project will use a static or dynamic template `_release_template_static.sql` or `_release_template_dynamic.sql`.  You could optionally delete one of them.
* Generate for your `_release.sql` script [ASCII Art](https://asciiartgen.now.sh/?style=standard)
* Optionally remove directories that won't apply (ie. conversion)

## Getting Started

Start a new release:
* Run commands like the following depending on a static or dynamic release

```
rm ../release/[a-z]*.sql
cp ../release/_release_template_static.sql ../release/_release.sql
```


```
rm ../release/[a-z]*.sql
cp ../release/_release_template_dynamic.sql ../release/_release.sql
```


* Optionally modify `script/new.sh` as needed

```
sh scripts/new.sh
```


## Folder Structure

The default folder structure (listed below) provides a set of common folders most projects will use. You're encouraged to add new folders to your projects where necessary. For example if you have ORDS scripts you may want to create a root folder called `ords` to store them.

| Folder | Description |
|:--|--|
| [`.vscode`](.vscode/) | [Visual Studio Code](https://code.visualstudio.com/) specific settings
| apex | Application exports
| data | Conversion and seed data scripts
| docs | Project documents 
| lib | Installation libraries (OSS, Logger, etc..)
| release | Current release scripts for changes and patching
| scripts | Usually re-runable scripts referenced by a release script
| packages | Packages (`.pls` & `.plb` or `.pks` & `.pkb`), (*If you have triggers, stand alone procedures or functions it's recommend to create a new folder for them*)
| synonyms | Application Synonyms
| triggers | Application Triggers
| views | Application views
| www | Assets that go in the server: images, CSS, and JavaScript

## Release Autocomplete

_Note: This script was developed by [Insum Solutions](https://insum.ca)._

**Status: POC**

The release.js file is node.js application will automatically add files in the defined directories (like `views`, `packages`, `triggers`) into a release file.  Adjust the `releaseObjects` JSON structure to match your needs. The directories will be processed in order thus allowing for the correct resolution of dependencies.

### Release File Configuration

You must make sure that the following is included in your release file:

```sql
-- AUTOREPLACE_START
-- AUTOREPLACE_END
```

The code will automatically fill in the section between these lines.

### Run

`node ./release/release.js ./release/<release file>`


Example:

```bash
# Go to releases folder in trunk/master of current SVN/Git project
cd releases

node release.js _release.sql
```

This application can be run multiple times as it keeps the substitution strings.
