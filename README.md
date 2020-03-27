
# Starter Project Templates

Use this repo to start a new project. 

You lickely want to download and not clone or fork. Then you can `git init` and start a new repo. 

![Download project](tmp/gitlab-download.png)


Follow the steps below to configure and initialize.

## Setup

* Run `cd scripts; sh config.sh` (or `config.bat`)
* Setup `app/_ins.sql` with the correct Workspace & App Number
* Generate for your `release.sql` script [ASCII Art](https://asciiartgen.now.sh/?style=standard)

## Getting Started

Start a new release:
```
sh scripts/new.sh
```

## Folder Structure

| Folder | Description |
|:--|--|
| app | Application exports
| bin | Binary files, executable scripts, Sublime/VSC specific files 
| conversion | Conversion and seed data scripts
| docs | Project documents 
| install | Installation scripts of none code objects like tables, types, and indexes.
| release | Current release scripts for changes and patching
| scripts | Usually re-runable scripts referenced by a release script
| plsql | Packages (`.pls`, `.plb`), triggers (not audit triggers) or sometimes stand alone procedures and functions.
| sql | Generic sql scripts that are not part of the application
| tmp | Garbage stuff, not under version control
| views | Application views
| www | Assets that go in the server: images, CSS, and JavaScript
