---
title: binconfig(5) - Bin CLI v$VERSION Manual
---

# binconfig(5)

## NAME

**.binconfig** - Per-project configuration file for [bin(1)](bin.1.html)

## DESCRIPTION

A **.binconfig** file may be placed in the root directory of a project. It may contain any combination of global settings (which affect Bin CLI itself) and command settings (which affect a single command).

## FILE FORMAT

A **.binconfig** file is written in INI format. The overall format is:

> _GLOBAL SETTINGS_
>
> [_COMMAND NAME_]
> _COMMAND SETTINGS_

Each setting is written on a separate line in the format:

> _KEY_ = _VALUE_

Spaces are allowed around the **=** signs, and are automatically trimmed from the start/end of lines.

Values should not be quoted - quotes will be treated as part of the value. This avoids the need to escape inner quotes.

Boolean values can be set to **true**/**false** (recommended), **yes**/**no**, **on**/**off** or **1**/**0** (all case-insensitive). Anything else triggers an error.

Lines that start with **;** or **#** are comments, which are ignored. No other lines can contain comments.

## GLOBAL SETTINGS

Global settings may appear at the top of a file.

**dir =** _DIRECTORY_
: Define a custom directory that contains the commands. The path is relative to the `.binconfig` file.

    **Default:** bin

**exact = true**
: Disable unique prefix matching.

    **Default:** false

**template =** _TEMPLATE_
: Customise the template for scripts created by `--create`. It is passed to `echo -e`, so you can use escape sequences such as `\n` for new lines.

    **Default:** `#!/usr/bin/env bash\nset -euo pipefail\n\n`

## COMMAND SETTINGS

**alias =** _ALIAS_
: Define an alias for the command. The alias can be used in place of the command name to execute the command. This can be repeated multiple times to define multiple aliases.

**aliases =** _ALIAS1_, _ALIAS2_, ...
: Define multiple aliases for the command at once.

**help =** _DIRECTORY_
: Add a short (one-line) description of the command. This will be displayed when you run **bin** with no parameters (or with an ambiguous prefix).

## EXAMPLE CONFIG FILE

`; Global settings`
`dir = scripts`
`exact = true`
`template = #!/bin/sh\n\n`

`; Settings for each command (script)`
`[hello]`
`alias = hi`
`help = Say "Hello, World!"`

## SEE ALSO

* [bin(1)](bin.1.html)
* [https://github.com/bin-cli/bin-cli/tree/v$VERSION#config-files](https://github.com/bin-cli/bin-cli/tree/v$VERSION#readme)
