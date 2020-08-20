
# Starter Project Template

[Template for Oracle PL/SQL and/or APEX development](https://github.com/insum-labs/starter-project-template) projects. This template provides scripts and processes to help speed up your development simplify some of your release processes.

It's **important** to note this is a **template**. If something doesn't fit your project's need or additional changes are required adjust accordingly. All the included tools are meant to help provide results quickly. If your project doesn't need them, remove them.

- [Start](#start)
- [Overview](#overview)
- [Setup](#setup)
- [Folder Structure](#folder-structure)
- [Other Info](#other-info)
  - [Git](#git)
  - [Git Workflows](#git-workflows)
  - [Windows Setup](#windows-setup)
    - [cmder setup](#cmder-setup)

## Start

In Github simply click the [`Use this template`](https://github.com/insum-labs/starter-project-template/generate) button. 

If using another git platform, start a new project (`git init`) then [**download**](https://github.com/insum-labs/starter-project-template/archive/master.zip) this project (*do not clone or fork*) and unzip into your new project. When copying it's important to copy all hidden files and folders. Example copy command: `cp -r ~/Downloads/starter-project-template-master/. ~/git/my-project`.


## Overview

This template contains a lot of features that may help with your project.

- [Build](build/): Scripts to generate the release
- [Folders](#folder-structure): The most common project folder structure is provided with this project.
- [Release](release/): Framework to build and do releases.
- [Visual Studio Code](https://code.visualstudio.com/) (VSC) integration: compile or run your SQL and PL/SQL code right from VSC. More details are provided in the [`.vscode`](.vscode/) folder.

Once [configured](#setup) the high level process to leverage this template is as follows:

- **Develop**
  - Packages go in [`packages`](packages/), views go into [`views`](views/), etc
  - Release specific / non re-runnable code goes into the [`release/code`](release/code) folder (see the [`release`](release) folder for more info on how to name files and list them in your release)
    - Each release will start at exactly the same point: [`release/_release.sql`](release/_release.sql). If automating your releases this provides a consistent script to run which can reduce any manual intervention.
- **Build Release**
  - Once ready to promote your code run `./build/build.sh <version>`. This will do things such as export your APEX application(s), scrape the views/packages folder for all the files, etc.
    - More information about the build process is available in the [`build`](build/) folder
- **Run Release**
  - They're various approaches on how to approach a release and tag your code. You need to read through the [release](release/) guidelines to chose an approach that is best for you
- **Clean up Release**
  - Once a release is done you "clear" the release specific code (i.e. `release/code` folder will be cleared and reset). A bash script [`reset_release`](scripts/#reset_release) is provided to do this automatically. Examples can be found in the [`release`](release/) folder.

## Setup

- [`scripts/project-config.sh`](scripts/project-config.sh): Configure APEX settings
- [`scripts/user-config.sh`](scripts/user-config.sh): The first time any bash script is executed this file will be generated and needs to be modified with user specific settings. By default this file will not be committed to your git repo as it contains user specific settings and database passwords
- Remove directories that don't apply to your project (ie. data, templates, etc...)


## Folder Structure

The default folder structure (listed below) provides a set of common folders most projects will use. You're encouraged to add new folders to your projects where necessary. For example if you have ORDS scripts you may want to create a root folder called `ords` to store them.

| Folder | Description |
|:--|--|
| [`.vscode`](.vscode/) | [Visual Studio Code](https://code.visualstudio.com/) specific settings
| [`apex`](apex/) | Application exports
| [`data`](data/) | Conversion and seed data scripts
| docs | Project documents 
| lib | Installation libraries ([OOS Utils](https://github.com/OraOpenSource/oos-utils), [Logger](https://github.com/OraOpenSource/Logger), etc..)
| [`release`](release/) | Current release scripts for changes and patching. Documentation is provided on various ways to do releases.
| [`scripts`](scripts/) | Usually re-runable scripts referenced by a release script
| packages | Packages (`.pks` & `.pkb`), (*If you have triggers, stand alone procedures or functions it's recommend to create a new folder for them*)
| synonyms | Application Synonyms
| triggers | Application Triggers
| views | Application views
| www | Assets that go in the server: images, CSS, and JavaScript



## Other Info

### Git

If you're new to git check out these resources to help learn more about it:

- [Visualized Git Commands](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)

### Git Workflows

They're several concepts of how to manage your Git projects. I.e. is your active development done in the `master` branch or in a `develop` branch? Each concept has their pros and cons and we recommend you review and understand the differences to apply the best method for your project. The most popular workflows are:

- [`git-flow`](https://www.git-tower.com/learn/git/ebook/en/command-line/advanced-topics/git-flow)
- [GitLab flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html)
  - This is a super set of `git-flow` and contains GitLab specific features to help if using [GitLab](https://gitlab.com/)
  - Document provides a great comparison of all the different workflow models
- [GitHub Flow](https://guides.github.com/introduction/flow/)
  - *Note in the GitLab flow document there's comment on GitHub flow is not recommended unless you deploy to prod frequently. For Oracle projects this comment can usually be ignored*

Given the simplicity of [GitHub Flow](https://guides.github.com/introduction/flow/) we recommend this concept for most projects.


### Windows Setup

All the scripts provided in this started template are written in bash for Linux (and macOS) environments. Windows users have several options. They can install [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)(WSL) to run Linux in Windows. 

Alternatively users can install [cmder](https://cmder.net/) which is a Linux emulator for Windows. 

#### cmder setup

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