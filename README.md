
# Starter Project Template

Template for Oracle PL/SQL and/or APEX development projects. It's **important** to note this is a **template**. If something doesn't fit your project's need or additional changes are required adjust accordingly. All the tools here are meant to help provide results quickly. If your project doesn't need them, remove them.

- [Start](#start)
- [Overview](#overview)
- [Setup](#setup)
- [Git Workflows](#git-workflows)
- [Folder Structure](#folder-structure)
- [Windows Setup](#windows-setup)
  - [cmder setup](#cmder-setup)
- [Release Autocomplete](#release-autocomplete)
  - [Release File Configuration](#release-file-configuration)
  - [Run](#run)

## Start

In Github simply click the [`Use this template`](https://github.com/insum-labs/starter-project-template/generate) button. If using another git platform, start a new project (`git init`) then [**download**](https://github.com/insum-labs/starter-project-template/archive/master.zip) this project (*do not clone or fork*) and unzip into your new project.

If you're new to git check out these resources to help learn more about it:

- [Visualized Git Commands](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)

## Overview

This template contains a lot of features that may help with your project.

- [Folders](folder-structure): The most common project folder structure is provided with this project.
- [Release](release/): Framework to build and do releases.
- [Visual Studio Code](https://code.visualstudio.com/) (VSC) integration: compile or run your SQL and PL/SQL code right from VSC. More details are provided in the [`.vscode`](.vscode/) folder.


## Setup

* Replace `CHANGEME` references throughout this project. Each substitution should be evident in each file.
* Remove directories that don't apply to your project (ie. data, templates, etc...)

## Git Workflows

They're several concepts of how to manage your Git projects. I.e. is your active development done in the `master` branch or in a `develop` branch? Each concept has their pros and cons and we recommend you review and understand the differences to apply the best method for your project. The most popular workflows are:

- [`git-flow`](https://www.git-tower.com/learn/git/ebook/en/command-line/advanced-topics/git-flow)
- [GitLab flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html)
  - This is a super set of `git-flow` and contains GitLab specific features to help if using [GitLab](https://gitlab.com/)
  - Document provides a great comparison of all the different workflow models
- [GitHub Flow](https://guides.github.com/introduction/flow/)
  - *Note in the GitLab flow document there's comment on GitHub flow is not recommended unless you deploy to prod frequently. For Oracle projects this comment can usually be ignored*

Given the simplicity of [GitHub Flow](https://guides.github.com/introduction/flow/) we recommend this concept for most projects.

## Folder Structure

The default folder structure (listed below) provides a set of common folders most projects will use. You're encouraged to add new folders to your projects where necessary. For example if you have ORDS scripts you may want to create a root folder called `ords` to store them.

| Folder | Description |
|:--|--|
| [`.vscode`](.vscode/) | [Visual Studio Code](https://code.visualstudio.com/) specific settings
| apex | Application exports
| [`data`](data/) | Conversion and seed data scripts
| docs | Project documents 
| lib | Installation libraries ([OOS Utils](https://github.com/OraOpenSource/oos-utils), [Logger](https://github.com/OraOpenSource/Logger), etc..)
| [`release`](release/) | Current release scripts for changes and patching. Documentation is provided on various ways to do releases.
| scripts | Usually re-runable scripts referenced by a release script
| packages | Packages (`.pls` & `.plb` or `.pks` & `.pkb`), (*If you have triggers, stand alone procedures or functions it's recommend to create a new folder for them*)
| synonyms | Application Synonyms
| triggers | Application Triggers
| views | Application views
| www | Assets that go in the server: images, CSS, and JavaScript



## Windows Setup

All the scripts provided in this started template are written in bash for Linux (and macOS) environments. Windows users have several options. They can install [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)(WSL) to run Linux in Windows. 

Alternatively users can install [cmder](https://cmder.net/) which is a Linux emulator for Windows. 

### cmder setup

To setup cmder [download](https://cmder.net/) the latest version. Unzip and place the folder `cmder` into `c:\`. *Note: cmder can be stored anywhere. For the purpose of these instructions its assumed that it's stored in `c:\cmder`*.

You can launch cmder anytime by running `c:\cmder\Cmder.exe` (*Hint: the first time you run it pin to your taskbar for quick access*)

To integrate with VSCode:

- `File > Preferences > Settings`
- Search for `terminal integrated shell`
  - In the results you'll find a link to `Terminal > Integrated > Automation Shell: Windows` and a link to `Edit in settings.json`. Click the edit link and add the following to `settings.json`:

```json
  "terminal.integrated.shell.windows": "C:\\cmder\\vendor\\git-for-windows\\bin\\bash.exe",
  "terminal.integrated.automationShell.linux": ""
```


*******
TODO: Move everything below here to the build or release folder

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
