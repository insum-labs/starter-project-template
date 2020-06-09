# MS Visual Studio Code Build Tasks

- [Compiling Code](#compiling-code)
- [Setup](#setup)
  - [`tasks.json`](#tasksjson)

[Microsoft Visual Studio Code (VSC)](https://code.visualstudio.com/) is a code editor. It is the recommended editor for Logger. VSC allows for compile PL/SQL code directly from VSC (see [this blog](https://ora-00001.blogspot.ca/2017/03/using-vs-code-for-plsql-development.html)) for more information.

## Compiling Code

To compile the current file you're editing execute the "task" by `⌘+shift+B` and select `compile: <project name>`.

## Setup

The first time you execute this script an error will be shown and `build/config.sh` will be created with some default values. Modify the variables as necessary.

### `tasks.json`

This file defines the VSCode task. The only thing that needs to be modified is the to define a task name. Search the file for `CHANGEME` and replace with the project name.