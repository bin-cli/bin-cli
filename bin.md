 Bin CLI Source Code
================================================================================

As an experiment, more than anything, this script is written using
[literate programming](https://en.wikipedia.org/wiki/Literate_programming)[^literate].
However, I have kept the source code in the same order as the compiled code and
used functions, not macros, to split things out.

[^literate]: Disclaimer: I haven't read the book, just the Wikipedia article,
so I may not be doing it exactly right!

It can be compiled using [mdsh](https://github.com/bashup/mdsh), which is
bundled into the `libexec/` directory, so you don't need to install it. Just run
`bin/build [version]`, which will output the compiled script to `temp/dist/bin`.

 Script Header
--------------------------------------------------------------------------------

### Shebang

We'll start with a standard [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)).

```shell
#!/usr/bin/env bash
```

We use `/usr/bin/env bash` rather than `/bin/bash` so it works with Bash installed
in a non-standard location, e.g. with Homebrew.

We require Bash, not just a standard [POSIX](https://en.wikipedia.org/wiki/POSIX)
shell like [Dash](https://wiki.archlinux.org/title/Dash), because we use:

- Arrays
- Regular expression matching
- `[[`
- Function-local variables (especially in recursive functions)

While I would prefer to support all POSIX-compatible shells, it's probably not
worth the extra effort. Supporting Bash v3 (macOS) is already complex enough
(there are no associative arrays, and we
[have to use](https://stackoverflow.com/a/61551944/167815)
`${array+"${array[@]}"}` everywhere instead of `${array[@]}`)!

### Comment

Let's provide some basic information for anyone reading the compiled script.

```shell
################################################################################
# Bin - A simple task runner           Copyright (c) 2023 Dave James Miller    #
# https://github.com/bin-cli/bin-cli   MIT License                             #
################################################################################
```

And we'll make it clear that the compiled script is not the original code.

```shell
#
# Compiled from bin.md by mdsh
#
```

### Bash Options

This has been [called](http://redsymbol.net/articles/unofficial-bash-strict-mode/) the "unofficial bash strict mode". There are some downsides and [edge](https://mywiki.wooledge.org/BashFAQ/105) [cases](https://news.ycombinator.com/item?id=11313928), but I generally find it helpful. I may look at some of the [expanded](https://github.com/olivergondza/bash-strict-mode/blob/master/strict-mode.sh) [versions](https://github.com/sellout/bash-strict-mode/blob/main/bin/strict-mode.bash) at some point.

We want this to be the first thing that runs, so it applies to the whole script, so it is not wrapped in a function. Otherwise, it would be possible to typo the function name (for example) and it would keep running.

```shell
set -euo pipefail
```

We'll also enable `nullglob` so that `*` expands to an empty list `()` rather than a literal asterisk `('*')` when a directory is empty, avoiding the need to check every time. (We could set this lower down, but it makes sense to set all global options together.)

```shell
shopt -s nullglob
```

 Global Variables
--------------------------------------------------------------------------------

There are a number of global variables. Unfortunately there's little we can do
to avoid that, since we can't pass arrays/maps around by reference like in other
languages, and Bash doesn't have anything equivalent to classes/objects.

I have marked each assignment to a global variable with the comment `# global`.
Every other variable used in a function should be marked `local`.

For easy reference and sanity checking, the full list of global variables is:

- `$action` (string)
- `$aliases` (array of strings)
- `$arguments` (array of strings)
- `$broken_symlinks` (array of strings)
- `$commands_listed_in_binconfig` (array of strings)
- `$exe` (string)
- `$fallback` (string)
- `$final_argument_for_completion` (string)
- `$full_command` (string)
- `$is_custom_exe` (boolean)
- `$last_argument` (integer)
- `$list_title` (string)
- `$main_binconfig` (string)
- `$main_bin_dir` (string)
- `$main_bin_dir_from_root` (string)
- `$main_is_root_dir` (boolean)
- `$main_root` (string)
- `$map__<map>__<key>` (mixed)
- `$matching_commands` (array of strings)
- `$merge_error_if_not_found` (boolean)
- `$merge_with_parent` (boolean)
- `$non_executable_files` (array of strings)
- `$option_error` (string)
- `$registered_commands` (array of strings)
- `$script_dir` (string)
- `$shim` (boolean)
- `$shortened_aliases` (array of strings)
- `$shortened_commands` (array of strings)
- `$template` (string)
- `$unique_prefix_matching` (boolean)

And the following constants (readonly variables):

- `$BOLD` (string)
- `$ERR_*` (integers)
- `$GREY` (string)
- `$LWHITE` (string)
- `$NEW_LINE` (string)
- `$RESET` (string)
- `$UNDERLINE` (string)
- `$VERSION` (string)
- `$YELLOW` (string)

The map names are:

- `alias_sources` (string → string)
- `alias_to_executable` (string → string)
- `command_to_bin_dir` (string → string)
- `command_to_executable` (string → string)
- `command_to_inline_script` (string → string)
- `command_to_root` (string → string)
- `commands_matching_aliases` (string → boolean)
- `executable_to_command` (string → string)
- `help` (string → string)
- `original_commands` (string → string)

Some of these variables are initialised before the `main` function is called.
Others are only defined if/when they are found in the options or config file,
so we can differentiate between unset and empty variables.

Since Bash doesn't actually have a boolean type, they are implemented as strings
with the value `true` or `false`. This makes it possible to write
`if $var; then ...`.

 Main
--------------------------------------------------------------------------------

Let's start by defining the high-level program structure...

First, we will parse the command line arguments to determine the action to be
performed. Then we can directly handle the simple actions.

For everything else, we need to search the filesystem for commands and config
files. Then we either run the given command, display a list of commands, or
output tab completion results, as appropriate.

```shell
main() {
    parse_arguments

    if action_is 'completion'; then
        output_tab_completion_script

    elif action_is 'help'; then
        display_help

    elif action_is 'version'; then
        display_version

    else
        register_commands_and_config

        if action_is 'create' || action_is 'edit'; then
            create_or_edit_binconfig_file_if_requested
        fi

        if action_is 'complete-bash'; then
            prepare_for_tab_completion
        fi

        parse_command_and_run_edit_or_create_if_possible
        determine_shortened_commands_and_aliases_for_listing

        if action_is 'complete-bash'; then
            output_tab_completion_results
        else
            output_command_listing
        fi
    fi
}
```

 Parse Options
--------------------------------------------------------------------------------

We need to parse the options given on the command line to determine the
action we should take, as well as various settings.

### Help Text

As an overview of the options available, let's start with the help text.

```plain @help
Usage: <EXE> [OPTIONS] [--] [COMMAND] [ARGUMENTS...]

Options that can be used with a command:
  --dir DIR             Specify the directory name to search for (overrides .binconfig)
  --exact               Disable unique prefix matching
  --exe NAME            Override the executable name displayed in the command list
  --fallback COMMAND    If the command is not found, run the given global command (implies '--exact')
  --prefix              Enable unique prefix matching (overrides .binconfig)
  --shim                If the command is not found, run the global command with the same name (implies '--exact')

Options that do something with a COMMAND:
  --create, -c          Create the given script and open in your $EDITOR (implies '--exact')
  --edit, -e            Open the given script in your $EDITOR

Options that do something special and don't accept a COMMAND:
  --completion          Output a tab completion script for the current shell
  --help, -h            Display this help
  --version, -v         Display the current version number and exit

Any options must be given before the command, because everything after the command will be passed as arguments to the script.

For more details see https://github.com/bin-cli/bin-cli#readme
```

We'll also make a function to display that when we call `bin --help`. This makes
use of `mdsh`'s ability to turn code blocks (like the one above) into variables.

```shell
display_help() {
    echo "${mdsh_raw_plain__help[0]/<EXE>/$exe}"
}
```

### Actions

The possible actions are:

- blank (default action - run the command or list the available commands)
- `help`
- `version`
- `completion` (just outputs the script to enable tab completion)
- `complete-bash` (called by bash-completion to actually perform tab completion)
- `create`
- `edit`

We'll initialise it to the blank (default) action.

```shell
action='' # global
```

Since actions are mutually independent, we'll return an error if the user
specifies more than one. (The alternative would be silently using the last
option given - but I think that is more confusing.)

```shell
set_action() {
    if [[ -n $action ]]; then
        set_option_error "The '--$action' and '--$1' arguments are incompatible"
    fi

    action=$1 # global
}
```

We'll also define a small helper function to check the current action, mainly to
make the code in `main` a bit cleaner / easier to read.

```shell
action_is() {
    [[ $action = "$1" ]]
}
```

### Parse Options

We need to assign the script arguments to a global variable so we can read/write
to them from various functions. We can't use `$@` directly because each function
has its own arguments that shadow the global arguments.

```shell
arguments=("$@") # global
```

Now we can loop through the arguments and parse them. We stop once we reach one
that doesn't start with a `-` - i.e. the command name. We'll also allow `--` to
explicitly stop parsing, just for consistency with other programs - though I
don't recommend making a command whose name starts with `-`.

We allow both `--param value` and `--param=value` formats for long options.
We don't allow combining short options - it's more complex to implement, and not
worth it because all the short options are mutually exclusive.

We can't use `getopt`, `getopts`, etc. to help with this because we don't want
to clobber anything after the command name - we need to keep them intact to pass
to the command.

```shell
parse_arguments() {
    while [[ ${#arguments[@]} -gt 0 ]]; do
        case ${arguments[0]} in
            --complete-bash) set_action complete-bash ;;
            --completion)    set_action completion ;;
            --create | -c)   set_action create ;;
            --dir)           set_script_dir "${arguments[1]-}"; array_shift arguments ;;
            --dir=*)         set_script_dir "${arguments[0]#*=}" ;;
            --edit | -e)     set_action edit ;;
            --exact)         set_unique_prefix_matching false ;;
            --exe)           set_exe "${arguments[1]-}"; array_shift arguments ;;
            --exe=*)         set_exe "${arguments[0]#*=}" ;;
            --fallback)      set_fallback "${arguments[1]-}"; array_shift arguments ;;
            --fallback=*)    set_fallback "${arguments[0]#*=}" ;;
            --help | -h)     set_action help ;;
            --prefix)        set_unique_prefix_matching true ;;
            --shim)          set_shim true ;;
            --version | -v)  set_action version ;;
            --)              array_shift arguments; break ;;
            -*)              fail "Invalid option '${arguments[0]}'" ;;
            *)               break ;;
        esac

        array_shift arguments
    done

    handle_option_error
}

```

### Option Error Handling

We can't exit immediately if we find an error, because `fail` (defined later)
outputs the executable name, and `--exe` could come after the option with the
error. Instead, we'll store it in a variable and check it when we're done with
parsing. If there is more than one error, we'll display the first one, as if
we had exited immediately.

```shell
set_option_error() {
    if is_unset option_error; then
        option_error=$1 # global
    fi
}
```

```shell
handle_option_error() {
    if is_set option_error; then
        fail "$option_error"
    fi
}
```

 Config Files
--------------------------------------------------------------------------------

`.binconfig` files are INI files, so we need some functions to parse them. We do
that in two separate phases.

### Get the `dir` Option

First, when we are searching for the `bin/` directory or checking for a matching
`.binconfig` file, we only need to extract the global `dir` option.

If `dir` is not set, we return the default directory name `bin`.

```shell
get_dir_from_binconfig() {
    local dir
    local file
    local key
    local line
    local root
    local sanity_check
    local value

    root=$1
    sanity_check=${2-false}

    file="${root%/}/.binconfig"

    dir=''
    line=0

    while IFS='=' read -r key value; do
        ((line += 1))

        key=$(trim "$key")

        if binconfig_line_is_ignored "$key"; then
            : # Skip blank lines & comments
        elif [[ $key =~ ^\[(.+)]$ ]]; then
            # [command] - marks the end of the global block
            break
        elif [[ $key = 'dir' ]]; then
            value=$(trim "$value")
            dir=${value%%/}
            break
        fi
    done <"$file" # kcov-ignore-line: Usage not detected

    if [[ -z $dir ]]; then
        dir='bin'
        line=0
    fi

    if $sanity_check; then
        sanity_check_bin_dir "$root" "$dir" "$file" "$line"
    fi

    echo "$dir"
}
```

This function optionally calls `sanity_check_bin_dir` to validate the
directory name - but only when we care that it is valid. (It shouldn't really be
the responsibility of this function, but this way allows us to pass it the
relevant line number, rather than needing yet another global variable to hold
it. I'm on the fence about which is better...)

### Other Settings

Once we have determined the correct `.binconfig` file to use, we can parse it
and register both the global and per-command settings.

```shell
parse_binconfig() {
    local binconfig
    local bin_dir
    local command
    local key
    local line
    local root
    local value

    binconfig=$1
    root=$2
    bin_dir=$3

    command=''
    line=0

    # shellcheck disable=SC2094 # We aren't writing to $binconfig but it thinks we might be
    while IFS='=' read -r key value; do
        ((line += 1))

        key=$(trim "$key")
        value=$(trim "$value")

        if binconfig_line_is_ignored "$key"; then
            : # Skip blank lines & comments
        elif [[ $key =~ ^\[(.+)]$ ]]; then
            command=${BASH_REMATCH[1]}
            record_command_listed_in_binconfig "$command"
        elif [[ -n $command ]]; then
            set_command_option "$command" "$key" "$value" "$binconfig" "$line" "$root" "$bin_dir"
        else
            set_global_option "$key" "$value" "$binconfig" "$line"
        fi
    done <"$binconfig" # kcov-ignore-line: Usage not detected
}
```

The global options are:

- `dir` already handled above
- `exact` - see [Unique Prefix Matching](#unique-prefix-matching)
- `merge` - see [Register Commands & Config Files](#register-commands--config-files)
- `template` - see [Create/Edit Files](#createedit-files)

```shell
set_global_option() {
    local binconfig
    local key
    local line
    local value
    local value_lowercase

    key=$1
    value=$2
    binconfig=$3
    line=$4

    if [[ $key = 'dir' ]]; then

        : # Already handled in 'get_dir_from_binconfig'

    elif [[ $key = 'exact' ]]; then

        value_lowercase=$(to_lowercase "$value")

        if in_array "$value_lowercase" 'false' 'no' 'off' '0'; then
            set_unique_prefix_matching_if_unset true
        elif in_array "$value_lowercase" 'true' 'yes' 'on' '1'; then
            set_unique_prefix_matching_if_unset false
        else
            fail "Invalid value for 'exact' in $binconfig line $line: $value"
        fi

    elif [[ $key = 'merge' ]]; then

        value_lowercase=$(to_lowercase "$value")

        if in_array "$value_lowercase" 'false' 'no' 'off' '0'; then
            merge_with_parent=false # global
        elif in_array "$value_lowercase" 'true' 'yes' 'on' '1'; then
            merge_with_parent=true # global
            merge_error_if_not_found=true # global
        elif [[ $value_lowercase = 'optional' ]]; then
            merge_with_parent=true # global
            merge_error_if_not_found=false # global
        else
            fail "Invalid value for 'merge' in $binconfig line $line: $value"
        fi

    elif [[ $key = 'template' ]]; then

        set_template_if_unset "$value"

    else

        # Unknown keys don't trigger an error for forwards compatibility
        debug "Ignored unknown key '$key' in $binconfig line $line"

    fi
}
```

The command-specific options are:

- `alias` or `aliases` - see [Aliases](#aliases)
- `command` - see [Commands](#commands)
- `help` - see [Command Help Text](#command-help-text)

```shell
set_command_option() {
    local binconfig
    local bin_dir
    local command
    local key
    local line
    local root
    local value
    local value_lowercase

    command=$1
    key=$2
    value=$3
    binconfig=$4
    line=$5
    root=$6
    bin_dir=$7

    if [[ $key = 'alias' || $key = 'aliases' ]]; then

        IFS=',' read -ra line_aliases <<<"$value"
        for alias in ${line_aliases+"${line_aliases[@]}"}; do
            alias=$(trim "$alias")
            register_command_alias "$alias" "$command" "$binconfig line $line"
        done

    elif [[ $key = 'command' ]]; then

        register_inline_command "$command" "$value" "$binconfig line $line" "$root" "$bin_dir"

    elif [[ $key = 'help' ]]; then

        if [[ -n "$value" ]]; then
            register_command_help "$command" "$value"
        fi

    else

        # Unknown keys don't trigger an error for forwards compatibility
        debug "Ignored unknown key '$key' in $binconfig line $line"

    fi
}
```

### Comments

Like many INI parsers, we allow both `#` and `;` to denote comments - but only
at the start of a line. (There may also be whitespace before it - that is
removed by `trim` before this function is called.)

We'll also use this function to skip blank lines.

```shell
binconfig_line_is_ignored() {
    [[ $1 = '' || $1 = '#'* || $1 = ';'* ]]
}
```

 Global Options
--------------------------------------------------------------------------------

### Executable Name

We display the script name in various places, including help text, command lists
and error messages. By default, we use the script name from `$0`, but strip off
the path if necessary.

```shell
exe=${0##*/} # global
is_custom_exe=false # global
```

This can be overridden with the `--exe` option. This is mostly useful when
defining an alias, and is typically combined with other custom options - e.g.
`alias scr='bin --exe scr --dir scripts'`.

```shell
set_exe() {
    exe=$1 # global
    is_custom_exe=true #global
}
```

`$is_custom_exe` can be used to check whether `--exe` was used.

### Fallback / Shim

`--fallback` can be used to specify an alternative command to run if the
specified command is not found in the current project.

```shell
set_fallback() {
    fallback=$1 # global
}
```

```shell
has_fallback() {
    is_set fallback
}
```

```shell
run_fallback() {
    # shellcheck disable=SC2086 # We want word splitting here
    run_command $fallback "${arguments[@]}"
}
```

`--shim` is a shorthand where the fallback has the same name as the command -
typically used to override a global command with a local version of the same.

```shell
set_shim() {
    shim=$1 # global
}
```

```shell
is_shim() {
    ${shim-false}
}
```

### Unique Prefix Matching

We enable/disable unique prefix matching according to the following rules:

- The `--exact` or `--prefix` command line options take precedence
- Then the lowest (first parsed) `.binconfig` file with an `exact` option set (whether `true` or `false`)
- If neither are used, it defaults to on

```shell
set_unique_prefix_matching() {
    unique_prefix_matching=$1 # global
}
```

```shell
set_unique_prefix_matching_if_unset() {
    if is_unset unique_prefix_matching; then
        set_unique_prefix_matching "$1"
    fi
}
```

```shell
unique_prefix_matching() {
    ${unique_prefix_matching-true}
}
```

When `--fallback` or `--shim` are used, this setting is ignored.

### Script Directory

By default, we search for either a `.binconfig` file, or a `bin/` directory.
However, it is also possible to specify a directory with `--dir`.

```shell
set_script_dir() {
    script_dir=$1 # global
}
```

```shell
has_script_dir() {
    is_set script_dir
}
```

The `--dir` option can either be an absolute path, which is searched directly,
or a directory name, which is found by searching upwards from the current
working directory as normal.

```shell
script_dir_is_absolute() {
    [[ $script_dir = /* ]]
}
```

When we are using a `.binconfig` file, we apply some additional sanity checks to
ensure it will work even if it is moved elsewhere. This is because Bin is
designed to be used in a project that is under version control (Git, etc.).

```shell
sanity_check_bin_dir() {
    local bin_dir_real
    local dir
    local file
    local line
    local root_real

    root=$1
    dir=$2
    file=$3
    line=$4

    if [[ $dir = /* ]]; then
        fail "The option 'dir' cannot be an absolute path in $file line $line"
    fi

    if [[ -d "$root/$dir" ]]; then
        bin_dir_real=$(realpath "$root/$dir")
        root_real=$(realpath "$root")

        if [[ "$bin_dir_real/" != "$root_real/"* ]]; then
            fail "The option 'dir' cannot point to a directory outside $root in $file line $line"
        fi
    elif [[ $line -gt 0 ]]; then
        fail "The directory specified in $file line $line does not exist: $root/$dir/"
    fi
}
```

If `dir` is set, it must point to a valid directory - but if it is not set (i.e.
`$line` is `0`), it doesn't have to exist. That is because it is possible to
define all commands as inline commands, directly in `.binconfig`.

 Command Help Text
--------------------------------------------------------------------------------

We can also register help text for each command in `.binconfig`. This is stored
in a simple map.

```shell
register_command_help() {
    map_set help "$1" "$2"
}
```

```shell
command_help() {
    map_get help "$1"
}
```

 Command Registration
--------------------------------------------------------------------------------

Before we can run any commands, we need to make a list of them all. This allows
us to support unique prefix matching, detect conflicts, and so on.

We need an array to hold the list of commands.

```shell
registered_commands=() # global
```

We also have various maps, which don't need to be initialised.

### Executable Commands

Regular commands are implemented as shell scripts. We need to record:

- The command name, for listing and various other functions
- A map from command name to executable, so we can run it
- A map from executable to command name, so we can implement symlink aliases

```shell
register_executable_command() {
    local bin_dir
    local executable
    local name
    local root

    name=$1
    executable=$2

    prevent_duplicate_command command "$name" "$executable"

    registered_commands+=("$name") # global

    map_set command_to_executable "$name" "$executable"
    map_set executable_to_command "$executable" "$name"
}
```

### Inline Commands

Inline commands are defined in `.binconfig`. We need to record:

- The command name, as above
- A map from command name to script, so we can run it
- A map from command name to root directory, so we can set `$BIN_ROOT`
- A map from command name to bin directory, so we can set `$BIN_DIR`

The latter two are not made available to regular commands - it is better to use
script-relative paths (e.g. `dirname "$0"`), which still work when the scripts
are run directly.

```shell
register_inline_command() {
    local bin_dir
    local name
    local root
    local script
    local source

    name=$1
    script=$2
    source=$3
    root=$4
    bin_dir=$5

    prevent_duplicate_command command "$name" "$source"

    registered_commands+=("$name") # global

    map_set command_to_inline_script "$name" "$script"
    map_set command_to_root "$name" "$root"
    map_set command_to_bin_dir "$name" "$bin_dir"
}
```

### Prevent Duplicate Commands

Since commands can be registered in two different ways, and multiple `bin/`
directories can be merged, we need to handle duplicates. While we could use a
last-wins rule, allowing lower directories to override higher ones, I think it
is safer to throw an error.

```shell
prevent_duplicate_command() {
    local name
    local source
    local type

    type=$1
    name=$2
    source=$3

    if map_has command_to_executable "$name" || map_has command_to_inline_script "$name"; then
        fail "The $type '$name' defined in $source conflicts with an existing command"
    fi
}
```

 Alias Registration
--------------------------------------------------------------------------------

We also need to make a list of aliases, and map them to commands.

```shell
aliases=() # global
```

### Command Aliases

A normal command alias is defined in a `.binconfig` file. We need to record:

- The alias name, for listing and various other functions
- The command that the alias points to
- Where the alias was defined, for use in error messages

Aliases may be registered before commands, so we can't verify that the command
exists at this point.

```shell
register_command_alias() {
    local alias
    local command
    local source

    alias=$1
    command=$2
    source=$3

    prevent_duplicate_alias "$alias" "$source"

    aliases+=("$alias") # global
    map_set original_commands "$alias" "$command"
    map_set alias_sources "$alias" "$source"
}
```

### Executable Aliases

Aliases can also be defined by symlinks. In this case, the alias points to an
executable, not directly to a command.

```shell
register_executable_alias() {
    local alias
    local executable
    local source

    alias=$1
    executable=$2
    source=$3

    prevent_duplicate_alias "$alias" "$source"

    aliases+=("$alias") # global
    map_set alias_to_executable "$alias" "$executable"
    map_set alias_sources "$alias" "$source"
}
```

### Prevent Duplicate Aliases

As with commands, we want to prevent duplicate aliases being defined.

```shell
prevent_duplicate_alias() {
    local existing
    local name
    local source

    name=$1
    source=$2

    if existing=$(map_get alias_sources "$name"); then
        fail "The alias '$name' defined in $source conflicts with the alias defined in $existing"
    fi
}
```

At this point, we can't check for aliases that conflict with commands, as the
commands may not have been defined.

### Process Aliases

Once we have registered all the commands and aliases, we have some additional
processing to do...

```shell
process_aliases() {
    change_executable_aliases_to_command_aliases
    expand_aliases_to_cover_subcommands
    prevent_aliases_conflicting_with_commands
}
```

For each executable alias, we need to determine the command it maps to.

```shell
change_executable_aliases_to_command_aliases() {
    local alias
    local command
    local executable

    for alias in ${alias_to_executable+"${alias_to_executable[@]-}"}; do
        if executable=$(map_get alias_to_executable "$alias"); then
            command=$(map_get executable_to_command "$executable")
            map_set original_commands "$alias" "$command"
        fi
    done
}
```

We need to expand aliases to cover subcommands - e.g. if `deploy` is an alias of
`push` then `deploy live` is an alias of `push live`.

```shell
expand_aliases_to_cover_subcommands() {
    local alias
    local command
    local source
    local suffix
    local target

    for alias in ${aliases+"${aliases[@]}"}; do
        target=$(map_get original_commands "$alias")
        for command in ${registered_commands+"${registered_commands[@]}"}; do
            if [[ "$command" = "$target "* ]]; then
                suffix=${command:${#target}}

                aliases+=("$alias$suffix") # global
                map_set original_commands "$alias$suffix" "$target$suffix"

                source=$(map_get alias_sources "$alias")
                map_set alias_sources "$alias$suffix" "$source"
            fi
        done
    done
}
```

Finally, we need to check for aliases (including expanded ones) that conflict
with existing commands.

```shell
prevent_aliases_conflicting_with_commands() {
    local alias
    local source

    for alias in ${aliases+"${aliases[@]}"}; do
        source=$(map_get alias_sources "$alias")
        prevent_duplicate_command alias "$alias" "$source"
    done
}
```

 Register Commands & Config Files
--------------------------------------------------------------------------------

Now let's actually search the filesystem for `.binconfig` files and `bin/`
directories, and register the commands and config.

This is a long function. I'll try to clean it up further in the future, but for
now the gist is:

- Find the starting directory/config file:
  - If `--dir` is an absolute path, use that
  - Else if `--dir` is a directory name, look for that in the working directory or a parent
  - Else look for a `.binconfig` file in the working directory or a parent, and read `dir` to find the directory name
  - Else look for a `bin/` directory in the working directory or a parent
- Register the commands in the directory
- Parse the `.binconfig` file
- If `merge=true` was set in the config file:
  - Look for a `.binconfig` file in a parent directory, and read `dir` to find the directory name
  - Else look for a `bin/` directory in a parent directory
  - Register the new commands, parse the new `.binconfig` file, and repeat as needed

```shell
register_commands_and_config() {
    local binconfig
    local bin_dir
    local bin_dir_from_root
    local is_root_dir
    local merging
    local root
    local start_directory

    merge_error_if_not_found=true # global
    merging=false
    start_directory=$PWD

    while true; do

        bin_dir=''
        bin_dir_from_root=''
        binconfig=''
        is_root_dir=false
        merge_with_parent=false # global
        root=''

        if ! $merging && has_script_dir; then

            # Look for the directory specified by '--dir'
            if script_dir_is_absolute; then

                if [[ ! -d $script_dir ]]; then
                    fail "Specified directory '$script_dir/' is missing"
                fi

                bin_dir=$script_dir

            else

                if ! dir_parent=$(findup -d "$script_dir"); then
                    fail "Could not find '$script_dir/' directory starting from '$start_directory'" "$ERR_NOT_FOUND"
                fi

                bin_dir="$dir_parent/$script_dir"

            fi

            # If there is no .binconfig file, assume the parent directory is the root
            binconfig=''
            root=$(dirname "$bin_dir")
            bin_dir_from_root=$(basename "$bin_dir")

            # Look for a matching .binconfig file (i.e. one with the correct value for 'dir')
            if binconfig_dir=$(cd "$bin_dir" && findup -f .binconfig); then
                dir_in_binconfig=$(get_dir_from_binconfig "$binconfig_dir")
                required_dir=$(relative_path "$binconfig_dir" "$bin_dir")

                if [[ "$dir_in_binconfig" = "$required_dir" ]]; then
                    binconfig="$binconfig_dir/.binconfig"
                    root=$binconfig_dir
                    bin_dir_from_root=$required_dir
                fi
            fi

        else

            # No '--dir' given, or merging with the parent directory - start at the current directory
            if root=$(cd "$start_directory" && findup -f .binconfig); then

                # .binconfig found - that takes precedence
                binconfig="${root%/}/.binconfig"
                bin_dir_from_root=$(get_dir_from_binconfig "$root" true)
                if [[ $bin_dir_from_root = '.' ]]; then
                    bin_dir=${root%/}
                else
                    bin_dir="${root%/}/$bin_dir_from_root"
                fi

            elif root=$(cd "$start_directory" && findup -d bin); then

                # bin/ directory found
                binconfig="${root%/}/.binconfig"
                bin_dir_from_root='bin'
                bin_dir="${root%/}/$bin_dir_from_root"

                if in_array "$bin_dir" "$BIN_TEST_ROOT/bin" "$BIN_TEST_ROOT/usr/bin" "$BIN_TEST_ROOT/usr/local/bin" "$BIN_TEST_ROOT/snap/bin" "$HOME/bin"; then
                    if ! $merge_error_if_not_found; then
                        break
                    elif $merging; then
                        # This returns a generic (i.e. configuration) error because merge=true should only be used if the parent exists
                        fail "Could not find 'bin/' directory or '.binconfig' file starting from '$start_directory' (merge=true) (ignored '$bin_dir')" "$ERR_GENERIC"
                    else
                        # Whereas this returns a 'not found' error because it has probably just been run from a directory with no scripts
                        fail "Could not find 'bin/' directory or '.binconfig' file starting from '$start_directory' (ignored '$bin_dir')" "$ERR_NOT_FOUND"
                    fi
                fi

            elif ! $merge_error_if_not_found; then

                # merge = optional
                break

            elif $merging; then

                # This returns a generic (i.e. configuration) error because merge=true should only be used if the parent exists
                fail "Could not find 'bin/' directory or '.binconfig' file starting from '$start_directory' (merge=true)" "$ERR_GENERIC"

            else

                # Whereas this returns a 'not found' error because it has probably just been run from a directory with no scripts
                fail "Could not find 'bin/' directory or '.binconfig' file starting from '$start_directory'" "$ERR_NOT_FOUND"

            fi

        fi

        # Special case for "dir = ."
        if [[ $bin_dir_from_root = '.' ]]; then
            is_root_dir=true
        fi

        # Find and register available commands
        if [[ -d $bin_dir ]]; then
            register_commands_in_directory "$bin_dir" "$is_root_dir"
        fi

        # Parse config file
        if [[ -f $binconfig ]]; then
            parse_binconfig "$binconfig" "$root" "$bin_dir"
        fi

        # Remember the lowest level for --create and some error messages
        if is_unset main_root; then
            main_binconfig=$binconfig
            main_bin_dir=$bin_dir
            main_bin_dir_from_root=$bin_dir_from_root
            main_is_root_dir=$is_root_dir
            main_root=$root
        fi

        # Merge with parent?
        if ! $merge_with_parent; then
            break
        fi

        merging=true
        start_directory=$(dirname "$root")

    done

    # Process aliases
    process_aliases
}
```

Once we have found the `bin/` directory, recursively search for executable
files (scripts) to register as commands, and symlinks to treat as aliases.

```shell
register_commands_in_directory() {
    local dir
    local file
    local is_root_dir
    local name
    local prefix
    local realfile
    local target

    dir=$1
    is_root_dir=$2
    prefix=${3-}

    # Loop through the directory to find commands
    for file in "$dir/"*; do
        name=${file##*/}  # Remove path
        name=${name// /-} # Spaces to dashes

        realfile=$(realpath "$file") || true

        if [[ -L $file ]]; then
            target=$(readlink "$file")
            if [[ $target = /* ]]; then
                fail "The symlink '$file' must use a relative path, not absolute ('$target')"
            fi
            if [[ -e $file ]]; then
                register_executable_alias "$prefix$name" "$realfile" "$file"
            else
                record_broken_symlink "$file" "$target"
            fi
        elif [[ -d $file ]]; then
            # Ignore subdirectories if scripts are in the root directory,
            # because it could take a long time to search a large tree, and it's
            # unlikely someone who keeps scripts in the root would also have
            # some in subdirectories
            if ! $is_root_dir; then
                map_set executable_to_command "$realfile" "$prefix$name"
                register_commands_in_directory "$file" false "$prefix$name "
            fi
        elif [[ ! -x $file ]]; then
            if ! $is_root_dir; then
                record_non_executable_file "$file"
            fi
        else
            # Ignore known plain text files if scripts are in the root directory,
            # mostly in case they're on a filesystem where all files are executable
            if ! ($is_root_dir && [[ $name =~ \.(json|md|txt|yaml|yml)$ ]]); then
                register_executable_command "$prefix$name" "$realfile"
            fi
        fi
    done
}
```

 Parse and Run the Command
--------------------------------------------------------------------------------

Now we have the commands and aliases registered, and the command name and
arguments stored in `$arguments`, we can figure out which command we need to
run/edit/create, or which commands to list/tab complete.

This is another big function that should probably be split up further at some
point, but the gist of it is:

- Check if the command name given (the first argument) can be matched to any commands/aliases:
  - As an exact match, or
  - By adding an extension (e.g. `.sh`), or
  - As the start of a command that has subcommands, or
  - As a unique prefix match (if enabled)
- Handle them as follows:
  - If there are no matches, display an error, or
  - If it matches multiple commands, assign them to a variable for listing, or
  - If it matches a command that has subcommands, append the next argument and repeat, or
  - If it matches exactly one command, run/edit that command

There is also special handling for `--create`, `--fallback` and `--shim`.

```shell
parse_command_and_run_edit_or_create_if_possible() {
    local append
    local binconfig_file
    local bin_dir_for_binconfig
    local current_directory
    local parent
    local subcommand

    # If no command is given, we will list all available commands
    set_command_list 'Available commands' registered_commands

    # Loop through each argument until we find a matching command
    current_directory=$main_bin_dir
    full_command='' # global

    while [[ ${#arguments[@]} -gt 0 ]]; do
        subcommand=${arguments[0]}
        array_shift arguments

        # Build up the entered command in canonical format
        full_command+=" $subcommand" # global

        # Check if there's an exact match - run it if so
        find_matching_commands exact "${full_command:1}"
        run_command_if_only_one_match "${arguments[@]}"

        # Check if there's an almost-exact match with an added extension - run it if so
        find_matching_commands with-extension "${full_command:1}"
        run_command_if_only_one_match "${arguments[@]}"

        # Check if there are any subcommands - move on to the next argument if so
        find_matching_commands subcommands "${full_command:1}"

        if [[ ${#matching_commands[@]} -gt 0 ]]; then
            current_directory="$current_directory/$subcommand"
            set_command_list 'Available subcommands' matching_commands
            continue
        fi

        # No exact matches - check for special actions
        if action_is 'create'; then
            if [[ $subcommand = .* ]]; then
                fail "Command names may not start with '.'"
            fi

            if [[ ${#arguments[@]} -gt 0 ]]; then
                current_directory="$current_directory/$subcommand"
                continue
            fi

            mkdir -p "$current_directory"
            create_script "$current_directory/$subcommand"
            open_in_editor "$current_directory/$subcommand"
        elif is_shim; then
            # shellcheck disable=SC2086 # We want word splitting here
            run_command ${full_command:1} "${arguments[@]}"
        elif has_fallback; then
            run_fallback
        fi

        # Check if there are any unique prefix matches
        # We need to check even with --exact so we can list them
        find_matching_commands prefix "${full_command:1}"

        if unique_prefix_matching; then
            # If all matching commands have the same parent command, pretend
            # the user typed the full parent command, then continue parsing
            if parent=$(matching_commands_shared_prefix "${full_command:1}"); then
                current_directory="$current_directory/$parent"
                full_command=" $parent"
                set_command_list 'Matching commands' matching_commands
                continue
            fi

            run_command_if_only_one_match "${arguments[@]}"
        fi

        # If there were no prefix matches, stop searching
        if [[ ${#matching_commands[@]} -eq 0 ]]; then
            if $main_is_root_dir && [[ -d "$current_directory/$subcommand" ]]; then
                fail "Subcommands are not supported with the config option 'dir = $main_bin_dir_from_root'"
            fi
            if [[ $subcommand = .* && -e "$current_directory/$subcommand" ]]; then
                fail "Command names may not start with '.'"
            fi
            if [[ -f "$current_directory/$subcommand" && ! -x "$current_directory/$subcommand" ]]; then
                fail "'$current_directory/$subcommand' is not executable (chmod +x)" "$ERR_NOT_EXECUTABLE"
            fi

            append=''
            if in_array "${full_command:1}" completion create edit help version; then
                append="${NEW_LINE}${GREY}Perhaps you meant to run 'bin --${full_command:1}'?${RESET}"
            fi
            fail "Command '${full_command:1}' not found in $main_bin_dir/ or $main_binconfig$append" "$ERR_NOT_FOUND"
        fi

        # Otherwise display the list of matches
        set_command_list 'Matching commands' matching_commands
        break
    done
}
```









---

```shell
run_command() {
    if action_is 'complete-bash'; then
        bug 'run_command() should not be reached during tab completion' # kcov-ignore-line: This should never happen
    elif action_is 'create'; then
        fail "$1 already exists (use --edit to edit it)"
    elif action_is 'edit'; then
        open_in_editor "$1"
    else
        exec "$@"
    fi
}
```

```shell
run_command_if_only_one_match() {
    local command
    local executable
    local script

    if [[ ${#matching_commands[@]} -ne 1 ]]; then
        return
    fi

    command=${matching_commands[0]}

    # Export the command name so it can be displayed in help messages
    # Typically with a fallback to $0 if it is unset: ${BIN_COMMAND-$0}
    export BIN_COMMAND="$exe $command"

    # And this can be used to display other command names
    export BIN_EXE=$exe

    if executable=$(map_get command_to_executable "$command"); then
        run_command "$executable" "$@"
    fi

    if script=$(map_get command_to_inline_script "$command"); then
        # These variables are useful for inline commands, but aren't made available
        # to regular commands because it is better to use "$(dirname "$0")" instead
        export BIN_ROOT BIN_DIR
        BIN_ROOT=$(map_get command_to_root "$command")
        BIN_DIR=$(map_get command_to_bin_dir "$command")

        run_command bash -c "$script" -- "$@"
    fi

    bug 'Reached the end of run_command_if_only_one_match() without running a command' # kcov-ignore-line: This should never happen
}
```

```shell
command_matches() {
    local command
    local found
    local target
    local type

    type=$1
    target=$2
    command=$3

    # Check for a match of the given type
    found=false

    if [[ $type = exact ]]; then
        [[ "$command" = "$target" ]] && found=true
    elif [[ $type = with-extension ]]; then
        [[ "$command" = "$target".* ]] && found=true
    elif [[ $type = subcommands ]]; then
        [[ "$command" = "$target "* ]] && found=true
    elif [[ $type = prefix ]]; then
        [[ "$command" = "$target"* ]] && found=true
    else
        bug "Invalid \$type '$type' passed to command_matches()" # kcov-ignore-line: This should never happen
    fi

    # If it doesn't match, return false
    if ! $found; then
        return 1
    fi

    return 0
}
```

```shell
matching_commands=() # global
```

```shell
find_matching_commands() {
    local alias
    local command
    local target
    local type

    type=$1
    target=$2
    stop_after_first=${3-false}

    for alias in ${aliases+"${aliases[@]}"}; do
        if command_matches "$type" "$target" "$alias"; then
            command=$(map_get original_commands "$alias")
            map_set commands_matching_aliases "$command" true
        fi
    done

    matching_commands=() # global
    for command in ${registered_commands+"${registered_commands[@]}"}; do
        if map_has commands_matching_aliases "$command"; then
            matching_commands+=("$command") # global
        elif command_matches "$type" "$target" "$command"; then
            matching_commands+=("$command") # global
        else
            continue
        fi

        if $stop_after_first; then
            break
        fi
    done
}
```

```shell
has_matching_commands() {
    local alias
    local command
    local target
    local type

    type=$1
    target=$2

    find_matching_commands "$type" "$target" true

    [[ ${#matching_commands[@]} -gt 0 ]]
}
```

```shell
matching_commands_shared_prefix() {
    local command
    local next_command
    local prefix
    local prefix_length
    local remaining
    local shared_next_command

    prefix=$1
    prefix_length=${#prefix}

    shared_next_command=''

    for command in ${matching_commands+"${matching_commands[@]}"}; do
        # Remove the common prefix
        remaining=${command:$prefix_length}

        if [[ ! $remaining = *' '* ]]; then
            continue
        fi

        next_command=${remaining/ */}

        if [[ -z $shared_next_command ]]; then
            shared_next_command=$next_command
        elif [[ "$next_command" != "$shared_next_command" ]]; then
            # Not unique
            return 1
        fi
    done

    if [[ -n $shared_next_command ]]; then
        echo "$prefix$shared_next_command"
    else
        # No subcommands found
        return 1
    fi
}
```

 Determine Shortened Commands & Aliases
--------------------------------------------------------------------------------

```shell
determine_shortened_commands_and_aliases_for_listing() {
    determine_shortened_commands
    determine_shortened_aliases
}
```

```shell
determine_shortened_commands() {
    local original_command
    local short

    shortened_commands=() # global

    # shellcheck disable=SC2154 # Assigned by set_command_list()
    for command in ${list_commands+"${list_commands[@]}"}; do
        short=$(remove_extension "$command")

        if [[ "$short" = "$command" ]]; then
            shortened_commands+=("$command") # global
        elif has_duplicate "$short" "$command"; then
            shortened_commands+=("$command") # global
        else
            shortened_commands+=("$short") # global
            original_command=$(map_get original_commands "$command" "$command")
            map_set original_commands "$short" "$original_command"
        fi
    done
}
```

```shell
determine_shortened_aliases() {
    local original_command
    local short

    shortened_aliases=() # global

    for alias in ${aliases+"${aliases[@]}"}; do
        short=$(remove_extension "$alias")

        if [[ "$short" = "$alias" ]]; then
            shortened_aliases+=("$alias") # global
        elif has_duplicate "$short" "$alias"; then
            shortened_aliases+=("$alias") # global
        else
            shortened_aliases+=("$short") # global
            original_command=$(map_get original_commands "$alias")
            map_set original_commands "$short" "$original_command"
        fi
    done
}
```

```shell
remove_extension() {
    local command

    # Can't use ${command%%.*} because it could remove too much ("a.b c" => "a" instead of "a.b")
    # Can't use ${command%.*} because it could remove too little ("a.b.c" => "a.b" instead of "a")
    command=$1

    while [[ "$command" =~ (.*)(\.[a-zA-Z0-9]+)+ ]]; do
        command=${BASH_REMATCH[1]}
    done

    echo "$command"
}
```

```shell
has_duplicate() {
    local alias
    local command
    local long
    local short

    short=$1
    long=$2

    for command in ${registered_commands+"${registered_commands[@]}"}; do
        case "$command" in
            # Ignore a match to itself
            "$long") continue ;;
            "$short") return 0 ;;
            "$short."*) return 0 ;;
            "$short "*) return 0 ;;
            *) continue ;;
        esac
    done

    for alias in ${aliases+"${aliases[@]}"}; do
        case "$alias" in
            "$short") return 0 ;;
            "$short "*) return 0 ;;
            *) continue ;;
        esac
    done

    # No matches found
    return 1
}
```

 Tab Completion
--------------------------------------------------------------------------------

This doesn't do the tab completion - it just outputs the script to be `eval`ed.

```shell
output_tab_completion_script() {
    local complete_command

    complete_command=("$0" --complete-bash)

    if has_script_dir; then
        complete_command+=("--dir" "'$script_dir'")
    fi

    if $is_custom_exe; then
        complete_command+=("--exe" "'$exe'")
    fi

    echo "complete -C \"${complete_command[*]}\" -o default $exe"
}
```

This runs before the commands are parsed.

```shell
final_argument_for_completion=''
```

```shell
prepare_for_tab_completion() {
    local args

    # Remove everything after the cursor
    args=${COMP_LINE:0:$COMP_POINT}
    # shellcheck disable=SC2086 # We want word splitting here
    set -- $args

    # Remove the command name
    shift

    # Assign what's left to $arguments for processing as normal
    arguments=("$@") # global

    # If there is a space at the end, we want to complete the next argument; otherwise the last one given
    if [[ $args != *' ' ]]; then
        final_argument_for_completion=$(array_last_element arguments) # global
        array_pop arguments
    fi
}
```

```shell
output_tab_completion_results() {
    local match
    local matches
    local matching_commands
    local prefix

    # Work out the full prefix we're looking for
    prefix=''
    if [[ -n $full_command ]]; then
        prefix="${full_command:1} "
    fi

    target="$prefix$final_argument_for_completion"

    # Look for commands and aliases that match, and collect the possible next arguments for each
    matches=()
    matching_commands=()

    for command in ${shortened_commands+"${shortened_commands[@]}"}; do
        if ! command_matches prefix "$target" "$command"; then
            continue
        fi

        match=${command#"$prefix"}
        match=${match/ */}
        matches+=("$match")
        matching_commands+=("$command")
    done

    for alias in ${shortened_aliases+"${shortened_aliases[@]}"}; do
        if ! command_matches prefix "$target" "$alias"; then
            continue
        fi

        command=$(map_get original_commands "$alias")
        if ! in_array "$command" ${matching_commands+"${matching_commands[@]}"}; then
            match=${alias#"$prefix"}
            match=${match/ */}
            matches+=("$match")
            matching_commands+=("$command")
        fi
    done

    # Output the matches and remove duplicates
    for command in ${matches+"${matches[@]}"}; do
        if is_hidden_command "$command" "$final_argument_for_completion"; then
            continue
        fi

        echo "$command"
    done | sort | uniq
}
```

```shell
is_hidden_command() {
    local command
    local prefix_length
    local target

    command=$1
    target=${2-}

    # We can't just match on $command, because it may be the parent command that
    # has already been typed that is hidden, so subcommands should be shown
    prefix_length=${#target}

    if [[ $prefix_length -eq 0 ]]; then
        command=" $command"
    else
        command=${command:$prefix_length}
    fi

    [[ $command = *' _'* ]]
}
```

 Create/Edit Files
--------------------------------------------------------------------------------

```shell
set_template() {
    template=$1 # global
}
```

```shell
set_template_if_unset() {
    if is_unset template; then
        set_template "$1"
    fi
}
```

```shell
create_script() {
    local script

    script=$1

    if is_set template; then
        echo -e "$template" >"$script"
    else
        echo -e '#!/usr/bin/env bash\nset -euo pipefail\n\n' >"$script"
    fi

    chmod +x "$script"
    echo "Created script $script"
}
```

```shell
create_or_edit_binconfig_file_if_requested() {
    if [[ ${arguments[0]-} != '.binconfig' ]]; then
        return
    fi

    binconfig_file="$main_root/.binconfig"

    if action_is 'create'; then
        if [[ -e $binconfig_file ]]; then
            fail "$binconfig_file already exists (use --edit to edit it)"
        fi

        create_binconfig_file "$binconfig_file"
    else
        if [[ ! -e $binconfig_file ]]; then
            fail 'No .binconfig file found (use --create to create one)'
        fi

        bin_dir_for_binconfig=$(get_dir_from_binconfig "$main_root")
        if [[ "$bin_dir_for_binconfig" != "$main_bin_dir_from_root" ]]; then
            fail ".binconfig belongs to $bin_dir_for_binconfig/ not $main_bin_dir_from_root/"
        fi
    fi

    open_in_editor "$binconfig_file"
}
```

```shell
create_binconfig_file() {
    local file
    local output_started

    file=$1

    (# kcov-ignore-line: Usage not detected
        output_started=false

        if [[ $main_bin_dir_from_root != 'bin' ]]; then
            echo "dir = $main_bin_dir_from_root"
            output_started=true
        fi

        for command in ${registered_commands+"${registered_commands[@]}"}; do
            if $output_started; then
                echo
            fi
            echo "[$command]"
            echo 'alias ='
            echo 'help ='
            output_started=true
        done

        if ! $output_started; then
            echo
        fi
    ) >"$file" # kcov-ignore-line: Usage not detected

    echo "Created file $file"
}
```

```shell
open_in_editor() {
    local editor
    local file

    file=$1

    editor=${VISUAL-${EDITOR-}}

    if [[ -z $editor ]]; then
        if command -v editor &>/dev/null; then
            editor='editor'
        elif command -v nano &>/dev/null; then
            editor='nano'
        elif command -v vi &>/dev/null; then
            editor='vi'
        else
            fail 'No editor configured - please export EDITOR or VISUAL environment variables'
        fi
    fi

    exec "$editor" "$file"
}
```

 List Available/Matching Commands
--------------------------------------------------------------------------------

```shell
set_command_list() {
    local var

    list_title=$1 # global
    var=$2

    eval "list_commands=(\${${var}+\"\${${var}[@]}\"})"
}
```

```shell
get_command_aliases() {
    local alias
    local command
    local command_alias_count
    local command_aliases
    local original_command
    local target

    command=$1

    command_alias_count=0
    command_aliases=''

    original_command=$(map_get original_commands "$command" "$command")

    for alias in ${shortened_aliases+"${shortened_aliases[@]}"}; do
        target=$(map_get original_commands "$alias")
        if [[ "$target" = "$original_command" ]]; then
            ((command_alias_count += 1))
            command_aliases+=", $alias"
        fi
    done

    if [[ $command_alias_count -eq 1 ]]; then
        echo "alias: ${command_aliases:2}"
    elif [[ $command_alias_count -gt 1 ]]; then
        echo "aliases: ${command_aliases:2}"
    else
        return 1
    fi
}
```

```shell
output_command_listing() {
    local command_aliases
    local command_help
    local maxlength
    local visible_commands

    # Remove hidden commands
    visible_commands=()

    for command in ${shortened_commands+"${shortened_commands[@]}"}; do
        if ! is_hidden_command "$command" "${full_command:1}"; then
            visible_commands+=("$command")
        fi
    done

    # Calculate the maximum length of a command in the list so we can align the help text
    maxlength=0
    for command in ${visible_commands+"${visible_commands[@]}"}; do
        if [[ ${#command} -gt $maxlength ]]; then
            maxlength=${#command}
        fi
    done

    echo "$LWHITE$BOLD$UNDERLINE$list_title$RESET"

    for command in ${visible_commands+"${visible_commands[@]}"}; do
        if command_help=$(command_help "$command"); then
            if command_aliases=$(get_command_aliases "$command"); then
                printf "%s %-${maxlength}s    %s\n" "$exe" "$command" "$command_help $GREY($command_aliases)$RESET"
            else
                printf "%s %-${maxlength}s    %s\n" "$exe" "$command" "$command_help"
            fi
        else
            if command_aliases=$(get_command_aliases "$command"); then
                printf "%s %-${maxlength}s    %s\n" "$exe" "$command" "$GREY($command_aliases)$RESET"
            else
                printf "%s %s\n" "$exe" "$command"
            fi
        fi
    done | sort

    if [[ ${#visible_commands[@]} -eq 0 ]]; then
        echo "${GREY}None found${RESET}"
    fi

    output_warnings
}
```

 Display Warnings
--------------------------------------------------------------------------------

```shell
output_warnings() {
    output_broken_symlinks
    output_non_executable_files
    output_missing_commands
}
```

### Broken Symlinks

```shell
broken_symlinks=() # global
```

```shell
record_broken_symlink() {
    local file
    local target

    file=$1
    target=$2

    broken_symlinks+=("$file => $target") # global
}
```

```shell
output_broken_symlinks() {
    if [[ ${#broken_symlinks[@]} -gt 0 ]]; then
        echo
        echo "${YELLOW}Warning: The following symlinks point to targets that don't exist:${RESET}"
        for symlink in ${broken_symlinks+"${broken_symlinks[@]}"}; do
            echo "$symlink"
        done
    fi
}
```

### Non-Executable Files

```shell
non_executable_files=() # global
```

```shell
record_non_executable_file() {
    local file

    file=$1

    non_executable_files+=("$file") # global
}
```

```shell
output_non_executable_files() {
    if [[ ${#non_executable_files[@]} -gt 0 ]]; then
        echo
        echo "${YELLOW}Warning: The following files are not executable (chmod +x):${RESET}"
        for file in ${non_executable_files+"${non_executable_files[@]}"}; do
            echo "$file"
        done
    fi
}
```

### Missing Commands

```shell
commands_listed_in_binconfig=() # global
```

```shell
record_command_listed_in_binconfig() {
    local command

    command=$1

    commands_listed_in_binconfig+=("$command") # global
}
```

```shell
output_missing_commands() {
    local missing_commands

    missing_commands=()
    for command in ${commands_listed_in_binconfig+"${commands_listed_in_binconfig[@]}"}; do

        # Regular script
        if map_has command_to_executable "$command"; then
            continue
        fi

        # Inline command
        if map_has command_to_inline_script "$command"; then
            continue
        fi

        # Directory
        if has_matching_commands subcommands "$command"; then
            continue
        fi

        missing_commands+=("$command")
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo
        echo "${YELLOW}Warning: The following commands listed in .binconfig do not exist:${RESET}"
        for command in ${missing_commands+"${missing_commands[@]}"}; do
            echo "[$command]"
        done
    fi
}
```

 Version
--------------------------------------------------------------------------------

The version number is set by `bin/build`, which is called by `bin/release`. If
no version number is provided - including when running the tests - it defaults
to `v1.2.3-dev`.

This code block is executed at compile time, so the generated script only
contains `VERSION=v1.2.3` or similar. The `%q` ensures the value is properly
quoted - though in practice that is not necessary.

```shell @mdsh
printf "VERSION=%q\n" "$VERSION"
```

The main thing we need this for is to output the version number when running
`bin --version`. We'll keep the output short and sweet.

```shell
display_version() {
    echo "Bin CLI $VERSION"
}
```

We need some special handling when running the tests, so we'll also use the
version number to differentiate development builds from production builds.

```shell
is_dev_version() {
    [[ $VERSION = 'v1.2.3-dev' ]]
}
```

 Error Handling
--------------------------------------------------------------------------------

Define a function to be called when the script needs to exit with an error
message & code, so we can do so consistently.

If we are performing tab completion, we don't want to output anything as it
would clobber the prompt. We'll also return a success code, since the tab
completion successfully returned nothing (although I don't know if that makes
any practical difference).

Otherwise, we will prefix the error message with the executable name - usually
`bin`, but it may be overridden with `--exe` or by just renaming / symlinking
the script.

```shell
fail() {
    local code
    local message

    message=$1
    code=${2-$ERR_GENERIC}

    if action_is 'complete-bash'; then
        exit
    fi

    echo "$exe: $message" >&2
    exit "$code"
}
```

We'll define the possible exit codes as constants, so we don't have magic
numbers in various places.

We use standard Linux (Unix? POSIX?) exit codes when scripts can't be executed
(permission denied) or can't be found.

For everything else, we use a code that is unlikely to be returned by the
scripts themselves. I chose 246 because it's "bin" written on a telephone
keypad, as well as being sufficiently high enough to be unusual. Codes above
127 typically represent "killed by signal N+127", but there are only 64
signals, and code 246 would represent signal 119.

```shell
readonly ERR_NOT_EXECUTABLE=126
readonly ERR_NOT_FOUND=127
readonly ERR_GENERIC=246
```

 Debug Logging
--------------------------------------------------------------------------------

When debugging, it is useful to be able to log things and dump variables to
display on screen.

We'll also output the line number, since that can be helpful when there is
more than one debug statement. And the line numbers of the call stack -
because why not! But we don't want them to get in the way, so we'll display
them in a light grey colour.

Originally I had "debug" statements throughout the code and a "--debug" option
to display the log to users... But as the script grew, that got harder to
maintain and much harder to read - so now I just add debug statements
temporarily when debugging.

```shell
debug() {
    # kcov-ignore-start: Debug statements are only added when needed
    local DEBUG_GREY
    local DEBUG_RESET
    local line

    # Unlike the global $GREY and $RESET variables defined elsewhere, these
    # are not dependent on whether we're writing to a terminal or a file
    DEBUG_GREY=$'\e[90m'
    DEBUG_RESET=$'\e[0m'

    line=$(debug_line)

    write_to_fd3 "$@" "${DEBUG_GREY}[$line]${DEBUG_RESET}"
    # kcov-ignore-end
}
```

We can't write to either stdout (`&1`) or stderr (`&2`), because that would
cause earlier tests to fail, so we'll write to `&3` instead.

It is read by the Cucumber.js tests and written to `debug.txt`, then later
displayed on screen by the `bin/test` script. Perhaps in the future I should
simplify that and write directly to a file instead... But this seemed logical
at the time I wrote it!

In case FD3 is not open, we need to suppress error messages and prevent
`errexit` from causing the script to exit.

```shell
write_to_fd3() {
    # kcov-ignore-start: Debug statements are only added when needed
    echo "$@" 2>/dev/null >&3 || true
    # kcov-ignore-end
}
```

If we somehow reach a place in the code that shouldn't be possible, we want to
abort, make it clear it shouldn't have happened, and display the line number.

```shell
bug() {
    # kcov-ignore-start: This should never be needed!
    local line
    line=$(debug_line)
    fail "BUG: $1 on $line"
    # kcov-ignore-end
}
```

In both `debug` and `bug`, we want to output the line numbers from the call
stack.

`$BASH_LINENO` is an array containing the line numbers from the stack trace. We
remove the first (call to this function) and last (always line 0), convert it
to a space-separated string, then replace the spaces by commas to get a string
like `line 132, 41, 1722`.

```shell
debug_line() {
    local lines
    lines=${BASH_LINENO[*]:1:${#BASH_LINENO[@]}-2}
    echo "line ${lines// /, }"
}
```

 ANSI Codes
--------------------------------------------------------------------------------

```shell
if [[ -t 1 ]]; then
    # kcov-ignore-start: There is never a terminal connected during unit tests
    readonly RESET=$'\e[0m'
    readonly BOLD=$'\e[1m'
    readonly UNDERLINE=$'\e[4m'
    readonly YELLOW=$'\e[33m'
    readonly GREY=$'\e[90m'
    readonly LWHITE=$'\e[97m'
    # kcov-ignore-end
else
    readonly RESET=''
    readonly BOLD=''
    readonly UNDERLINE=''
    readonly YELLOW=''
    readonly GREY=''
    readonly LWHITE=''
fi

readonly NEW_LINE=$'\n'
```

 Generic Helper Functions
--------------------------------------------------------------------------------

```shell
array_shift() {
    local places
    local var

    var=$1
    places=${2-1}

    eval "$var=(\"\${${var}[@]:$places}\")"
}
```

```shell
array_last_element() {
    local var

    var=$1

    eval "echo \${${var}[\${#${var}[@]} - 1]}"
}
```

```shell
array_pop() {
    local var

    var=$1

    eval "$var=(\"\${${var}[@]:0:\${#${var}[@]} - 1}\")"
}
```

Note that we can't easily combine `array_last` and `array_pop` because
`last=$(array_pop var)` would cause `array_pop` to run in a subshell, so the
variable would not actually be modified.

```shell
in_array() {
    local needle
    local value

    needle=$1
    shift

    for value in "$@"; do
        if [[ "$value" = "$needle" ]]; then
            return 0
        fi
    done

    return 1
}
```

```shell
is_set() {
    [[ -n ${!1+isset} ]]
}
```

```shell
is_unset() {
    ! is_set "$1"
}
```

```shell
trim() {
    local string

    string=$1

    # https://stackoverflow.com/a/3352015/167815
    string=${string#"${string%%[![:space:]]*}"}
    string=${string%"${string##*[![:space:]]}"}

    echo "$string"
}
```

```shell
to_lowercase() {
    # Can't use ${value,,} because it doesn't work in Bash 3 (macOS)
    echo "$1" | tr '[:upper:]' '[:lower:]'
}
```

 Maps (Associative Arrays)
--------------------------------------------------------------------------------

This is to support Bash 3 (macOS - *sigh*!), which doesn't have associative arrays.

```shell
map_key() {
    local char
    local i
    local key
    local length
    local map

    map=$1
    key=$2

    printf '%s' "map__${map}__"

    length=${#key}
    for ((i = 0; i < length; i++)); do
        char=${key:i:1}
        case $char in
            [a-zA-Z0-9]) printf '%s' "$char" ;;
            # Encode all other characters in hex to make them valid variable names
            *) printf '_%02X' "'$char" ;;
        esac
    done
}
```

```shell
map_set() {
    local key
    local map
    local value

    map=$1
    key=$2
    value=$3

    # Make an array containing the raw keys so we can loop through them
    eval "$map+=(\"\$key\")"

    # Store the values in separate variables
    key=$(map_key "$map" "$key")
    printf -v "$key" %s "$value"
}
```

```shell
map_get() {
    local key
    local map
    local default

    map=$1
    key=$2
    default=${3-}

    key=$(map_key "$map" "$key")

    if is_set "$key"; then
        echo "${!key}"
    elif [[ $# -ge 3 ]]; then
        echo "$default"
    else
        return 1
    fi
}
```

```shell
map_has() {
    local key
    local map

    map=$1
    key=$2

    key=$(map_key "$map" "$key")

    is_set "$key"
}
```

 Filesystem Helpers
--------------------------------------------------------------------------------

```shell
findup() (
    while true; do
        if test "$@"; then
            echo "$PWD"
            return 0
        fi

        if [[ $PWD = '/' || $PWD = "$BIN_TEST_ROOT" ]]; then
            return 1
        fi

        cd ..

    done
)
```

```shell
relative_path() {
    local child
    local parent

    parent=$1
    child=$2

    echo "${child#"${parent}/"}"
}
```

 Cross-Platform `realpath`
--------------------------------------------------------------------------------

```shell
# Based on: https://github.com/mkropat/sh-realpath/blob/65512368b8155b176b67122aa395ac580d9acc5b/realpath.sh
# Copyright (c) 2014 Michael Kropat - MIT License
# Modified to work with 'set -e', and to follow our code conventions

# Not every code path is covered by our tests
# kcov-ignore-start

realpath() {
    local resolved
    resolved=$(resolve_symlinks "$1")
    canonicalize_path "$resolved"
}

resolve_symlinks() {
    _resolve_symlinks "$1"
}

_resolve_symlinks() {
    _assert_no_path_cycles "$@" || return

    local dir_context new_context path

    if path=$(readlink -- "$1"); then
        dir_context=$(dirname -- "$1")
        new_context=$(_prepend_dir_context_if_necessary "$dir_context" "$path")
        _resolve_symlinks "$new_context" "$@"
    else
        echo "$1"
    fi
}

_prepend_dir_context_if_necessary() {
    if [[ $1 = '.' ]]; then
        echo "$2"
    else
        _prepend_path_if_relative "$1" "$2"
    fi
}

_prepend_path_if_relative() {
    case "$2" in
        /*) echo "$2" ;;
        *) echo "$1/$2" ;;
    esac
}

_assert_no_path_cycles() {
    local target path

    target=$1
    shift

    for path in "$@"; do
        if [[ "$path" = "$target" ]]; then
            return 1
        fi
    done
}

canonicalize_path() {
    if [[ -d $1 ]]; then
        _canonicalize_dir_path "$1"
    else
        _canonicalize_file_path "$1"
    fi
}

_canonicalize_dir_path() {
    (cd "$1" 2>/dev/null && pwd -P)
}

_canonicalize_file_path() {
    local dir file
    dir=$(dirname -- "$1")
    file=$(basename -- "$1")

    (cd "$dir" 2>/dev/null && dir2=$(pwd -P) && echo "$dir2/$file")
}
# kcov-ignore-end
```

 Test Helpers
--------------------------------------------------------------------------------

The `BIN_TEST_ROOT` env var is ignored in production builds, but is used to
emulate global directories in the tests.

```shell
if is_dev_version; then
    BIN_TEST_ROOT=${BIN_TEST_ROOT-}
else
    BIN_TEST_ROOT='' # kcov-ignore-line: Not tested
fi
```

 Finished
--------------------------------------------------------------------------------

Phew, we have finally finished defining everything - so let's run it!

```shell
main
```

 Footnotes
--------------------------------------------------------------------------------

<!-- Footnotes are rendered here --->
