---
title: bin(1) - Bin CLI $VERSION Manual
---

# bin(1)

## NAME

**bin** - A simple task/script runner for any language

## SYNOPSIS

**bin** [_OPTIONS_] [**--**] [_COMMAND_] [_ARGUMENTS_...]

## DESCRIPTION

Bin CLI is a simple task runner, designed to be used in code repositories, with  scripts written in any programming language.

It automatically searches in parent directories, so you can run scripts from anywhere in the project tree. It also supports aliases, unique prefix matching and tab completion, reducing the amount you need to type.

## OPTIONS

Options that can be used with a command:

> **--dir** _DIR_, **--dir**=_DIR_
> : Specify the directory name to search for (overrides [.binconfig](binconfig.5.html)).
>
> **--exact**
> : Disable unique prefix matching.
>
> **--exe** _NAME_, **--exe**=_NAME_
> : Override the executable name displayed in the command list.
>
> **--fallback** _COMMAND_, **--fallback**=_COMMAND_
> : If the command is not found, run the given global command (implies **--exact**).
>
> **--prefix**
> : Enable unique prefix matching (overrides [.binconfig](binconfig.5.html)).
>
> **--shim**
> : If the command is not found, run the global command with the same name (implies **--exact**).

Options that do something with a **COMMAND**:

> **--create**, **-c**
> : Create the given script and open in your **$EDITOR** (implies **--exact**).
>
> **--edit**, **-e**
> : Open the given script in your **$EDITOR**.

Options that do something special and don't accept a **COMMAND**:

> **--completion**
> : Output a tab completion script for the current shell.
>
> **--info**
> : Display information about the current project (root, bin directory and config file location).
>
> **--help**, **-h**
> : Display the help text.
>
> **--version**, **-v**
> : Display the current version number.

Any options must be given before the command, because everything after the command will be passed as parameters to the script.

## EXAMPLES

**bin**
: List all available commands.

**bin build**
: Run the <root>/bin/build command.

**bin -c build**
: Create the <root>/bin/build command and open it in your preferred $EDITOR.

**bin -e build**
: Open the <root>/bin/build command in your preferred $EDITOR.

**bin deploy production**
: Run the <root>/bin/deploy/production command.

All of these examples are dependent on the scripts that exist in <root>/bin, as well as the contents of the [.binconfig](binconfig.5.html) file (if any).

## ENVIRONMENT

Your preferred editor is determined by **`$VISUAL`** or **`$EDITOR`**. (If neither are set, it defaults to **editor**, **nano** or **vi**.)

The environment variables **`$BIN_EXE`** ('bin' executable name) and **`$BIN_COMMAND`** (executable name + command name) are passed to all commands executed by Bin CLI. For maximum portability, use **`${BIN_COMMAND-$0}`**.

The environment variables **`$BIN_ROOT`** (root directory path) and **`$BIN_DIR`** (bin/ directory path) are passed to inline commands (defined in [.binconfig](binconfig.5.html)) only.

## EXIT STATUS

The exit status of a command is preserved. Exit statuses that may be set by bin itself are:

**0**
: Successful execution.

**126**
: Command found but not executable (run **chmod +x** _SCRIPT_ to fix this).

**127**
: Command not found.

**246**
: Invalid argument or misconfiguration.

## SECURITY CONSIDERATIONS

Bin CLI executes arbitrary commands/scripts in the current working directory (or the directory specified by --dir) - the same as if you executed them directly. You should not run commands from untrusted sources.

## REPORTING BUGS

[https://github.com/bin-cli/bin-cli/issues](https://github.com/bin-cli/bin-cli/issues)

## COPYRIGHT

Copyright © 2023-2024 Dave James Miller.

This is free software released under the MIT License. There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

## SEE ALSO

* [binconfig(5)](binconfig.5.html)
* [https://github.com/bin-cli/bin-cli/tree/$VERSION#readme](https://github.com/bin-cli/bin-cli/tree/$VERSION#readme)
