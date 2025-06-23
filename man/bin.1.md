---
title: bin(1) - Bin CLI v$VERSION Manual
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
> : Specify the directory name to search for (absolute or relative path).
>
> **--exe** _NAME_, **--exe**=_NAME_
> : Override the executable name displayed in the command list.

Options that do something special:

> **--completion**
> : Output a tab completion script for the current shell.
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

**bin deploy production**
: Run the <root>/bin/deploy/production command.

## ENVIRONMENT

The environment variables **`$BIN_EXE`** ('bin' executable name) and **`$BIN_COMMAND`** (executable name + command name) are passed to commands executed by Bin CLI. For maximum portability, use **`${BIN_COMMAND-$0}`**.

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

* [https://github.com/bin-cli/bin-cli/tree/v$VERSION#readme](https://github.com/bin-cli/bin-cli/tree/v$VERSION#readme)
