# Bin – A simple task runner

[![GitHub Actions Status](https://github.com/bin-cli/bin-cli/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/bin-cli/bin-cli/actions/workflows/test.yml)

## Introduction

*Bin* is a simple task/script runner, designed to be used in code repositories, with scripts written in any programming language.

It automatically searches in parent directories, so you can run scripts from anywhere in the project tree.

It supports aliases and unique prefix matching, as well as tab completion, reducing the amount you need to type.

It is implemented as a self-contained shell script, small enough to bundle with your dotfiles or projects if you want to.

Its use is completely optional - users who choose not to install *Bin* can run the scripts directly.

*It doesn't natively support Windows - though it can be used via [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), [Git Bash](https://gitforwindows.org/), [MSYS2](https://www.msys2.org/) or [Cygwin](https://www.cygwin.com/).*

### How it works

A project just needs a `bin/` folder and some executable scripts:

```
repo/
├── bin/
│   ├── build
│   ├── deploy
│   └── hello
└── ...
```

The scripts can be written in any language, or can even be compiled binaries. Here is a simple `bin/hello` shell script:

```bash
#!/bin/sh
echo "Hello, ${1:-World}!"
```

To execute it, run:

```bash
$ bin hello
```

Now you may be thinking why not just do this:

```bash
$ bin/hello
```

And you're right, that would do the same thing... But *Bin* will also search in parent directories, so you can use it from anywhere in the project:

```bash
$ cd app/Http/Controllers/
$ bin hello # still works
$ bin/hello # doesn't work!
$ ../../../bin/hello # works, but is rather tedious to type!
```

It also supports unique prefix matching, so if `hello` is the only script starting with `h`, all of these will work too:

```bash
$ bin hell
$ bin hel
$ bin he
$ bin h
```

If you type a prefix that isn't unique, *Bin* will display a list of possible matches. Similarly, if you run `bin` on its own, it will list all available scripts.

There are a few more optional features, but that's all you really need to know to use it.

## Getting started

### Installation

System-wide:

```bash
sudo wget https://github.com/bin-cli/bin-cli/releases/latest/download/bin -O /usr/local/bin/bin
sudo chmod +x /usr/local/bin/bin
```

Or for the current user only:

```bash
mkdir -p ~/bin
wget https://github.com/bin-cli/bin-cli/releases/latest/download/bin -O ~/bin/bin
chmod +x ~/bin/bin
echo 'PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
```

#### Tab completion

Add this:

```bash
eval "$(bin --completion)"
```

To one of the following files:

- `/usr/share/bash-completion/completions/bin` (recommended for system-wide install)
- `/etc/bash_completion.d/bin`
- `~/.local/share/bash-completion/completions/bin` (recommended for per-user install)
- `~/.bash_completion`
- `~/.bashrc`

You may want to wrap it in a conditional, in case *Bin* is not installed:

```bash
if command -v bin &>/dev/null; then
    eval "$(bin --completion)"
fi
```

(Only `bash` is supported at the moment. I may add `zsh` and others in the future.)

### Creating scripts

In the root of the repository, create a `bin` directory:

```bash
mkdir bin
```

Then create some scripts, in the language of your choice, using the text editor of your choice:

```bash
vim bin/sample1
nano bin/sample2
code bin/sample3
```

For example:

```bash
#!/bin/sh
echo 'Hello, World!'
```

And make the scripts executable:

```bash
chmod +x bin/*
```

That's all there is to it. Now you can run them:

```bash
bin sample
```

### Creating/editing scripts in your preferred editor

There are built-in commands you can use to create/edit scripts in your preferred editor (`$VISUAL` or `$EDITOR`, with `editor`, `nano` or `vi` as a fallback):

```bash
bin --create sample
bin -c sample

bin --edit sample
bin -e sample
```

The `--edit` command supports unique prefix matching:

```bash
bin -e sam
```

### Config files

*Bin* config files are named `.binconfig`, and are written in [INI format](https://en.wikipedia.org/wiki/INI_file).

They are entirely **optional** - you don't need to create a config file unless you want to use [aliases](#aliases), [help text](#help-text), [inline commands](#inline-commands), a [custom script directory](#custom-script-directory) or disable [unique prefix matching](#unique-prefix-matching). Here is an example with all of these:

```ini
root=scripts
exact=true

[hello]
alias=hi
help=Say "Hello, World!"

[phpunit]
command="$BIN_ROOT/vendor/bin/phpunit" "%@"
```

They should be placed in the project root directory, alongside the `bin/` directory:

```
repo/
├── bin/
│   └── ...
└── .binconfig
```

You can use these commands to create/edit it in your preferred editor (`$VISUAL` or `$EDITOR`, with `editor`, `nano` or `vi` as a fallback):

```bash
bin --create .binconfig
bin --edit .binconfig
```

## Other features

### Help text

To add a short description for a command, enter it in `.binconfig` as follows:

```ini
[deploy]
help=Sync the code to the live server
```

This will be displayed when running `bin` with no parameters (or with an ambiguous prefix). For example:

```bash
$ bin
Available commands
bin artisan    Run Laravel Artisan command with the appropriate version of PHP
bin deploy     Sync the code to the live server
bin php        Run the appropriate version of PHP for this project
```

I recommend keeping the description short, and implementing a `--help` parameter if further explanation is required.

### Subcommands

If you have multiple related commands, you may want to group them together and make subcommands. To do that, just create a subdirectory:

```
repo/
├── bin/
│   └── deploy/
│       ├── live
│       └── staging
└── ...
```

Now `bin deploy live` will run `bin/deploy/live`, and `bin deploy` will list the available subcommands.

In `.binconfig`, use the full command names:

```ini
[deploy live]
help=Deploy to the production site

[deploy staging]
help=Deploy to the staging site
```

### Script extensions

If you prefer, you can create scripts with an extension to represent the language:

```
repo/
└── bin/
    ├── sample1.sh
    ├── sample2.py
    └── sample3.rb
```

The extensions will be removed when listing scripts and in [tab completion](#tab-completion) (as long as there are no conflicts):

```bash
$ bin
Available commands
bin sample1
bin sample2
bin sample3
```

You can run them with or without the extension:

```bash
$ bin sample1
$ bin sample1.sh
```

### Unique prefix matching

As noted above, if you type a prefix that uniquely identifies a command, that command will be executed.

If you prefer to disable unique prefix matching, add this at the top of `.binconfig`:

```ini
exact=true
```

Or you can use `--exact` on the command line (perhaps using a shell alias):

```bash
bin --exact hello
```

To enable it again, overriding the config file, use `--prefix`:

```bash
bin --prefix hel
```

### Aliases

You can define aliases in `.binconfig` like this:

```ini
[deploy]
alias=publish
```

This means `bin publish` is an alias for `bin deploy`, and would call `bin/deploy`.

You can define multiple aliases by separating them with commas (and optional spaces). You can use the key "`aliases`" if you prefer:

```ini
[deploy]
aliases=publish, push
```

Or you can list them on separate lines:

```ini
[deploy]
alias=publish
alias=push
```

This also works for subcommands:

```ini
[deploy]
alias=push

[deploy live]
alias=publish

[deploy staging]
alias=stage
```

Here, `bin push live` and `bin publish` would both be aliases for `bin deploy live`.

Alternatively, you can use symlinks to define aliases:

```bash
$ cd bin
$ ln -s deploy push
$ ln -s deploy/live publish
$ ln -s deploy/staging stage
```

Be sure to use relative targets, not absolute ones, so they work in any location. (Absolute targets will be rejected, for safety.)

In either case, aliases are listed alongside the help text when you run `bin` with no parameters (or with a non-unique prefix). For example:

```bash
$ bin
Available commands
bin artisan    Run Laravel Artisan command with the appropriate version of PHP (alias: art)
bin deploy     Sync the code to the live server (aliases: publish, push)
```

Aliases are also subject to unique prefix matching - so here `bin pub` would match `bin publish`. `bin pu` would match both `bin publish` and `bin push`, but since both are aliases for the same script, that would be treated as a unique prefix and would therefore also run `bin deploy`.

Defining an alias that conflicts with a script or another alias will cause *Bin* to exit with an error code and print a message to stdout (for safety).

### Inline commands

If you have a really short script, you can instead write it as an inline command in `.binconfig`:

```ini
[hello]
command=echo 'Hello World'

[phpunit]
command="$BIN_ROOT/vendor/bin/phpunit" "$@"
```

The following variables are available:

- `$BIN_DIR` points to the directory containing the scripts (usually `$BIN_ROOT/bin`, unless configured otherwise)
- `$BIN_ROOT` points to the project root directory (usually one level above `bin/`)
- `$1`, `$2`, ... and `$@` contain the additional arguments

The command is executed within a Bash shell, so may contain logic operators if desired... But I recommend only using it for simple aliases to other scripts that can be called directly, such as the PHPUnit example above, since it won't be possible to call it without Bin CLI installed.

### Aliasing the `bin` command

If you prefer to shorten the script prefix from `bin` to `b`, you can create a symlink. The exact command will depend on how and where you installed *Bin* - for example:

```bash
$ sudo ln -s /usr/bin/bin /usr/local/bin/b
```

Or you can create an alias in your shell's config. For example, in `~/.bashrc`:

```bash
alias b='bin --exe b'
```

We use the optional parameter `--exe` here to set the name used in the list of scripts:

```bash
$ b
Available commands
b hello
```

You can set up [tab completion](#tab-completion) too:

```bash
eval "$(bin --completion --exe b)"
```

### Custom script directory

If you prefer the directory to be named `scripts` (or something else), you can configure that at the top of `.binconfig`:

```ini
root=scripts
```

The root path is relative to the `.binconfig` file - it won't search any parent or child directories.

This option is provided for use in projects that already have a `scripts` directory or similar. I recommend renaming the directory to `bin` if you can, for consistency with the executable name and [standard UNIX naming conventions](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

#### Scripts in the root directory

If you have your scripts directly in the project root, you can use this:

```ini
root=.
```

However, subcommands will <u>not</u> be supported, because that would require searching the whole (potentially [very large](https://i.redd.it/tfugj4n3l6ez.png)) directory tree to find all of scripts.

#### Overriding it at runtime

You can also set the root directory at the command line, which will override the config file:

```bash
$ bin --dir scripts
```

In this case, it will search the parent directories as normal, and ignore the `root` setting in any `.binconfig` files it finds.

This is mostly useful when defining a custom alias, to support repositories you don't control:

```bash
alias scr='bin --exe scr --dir scripts'
```

It can also be an absolute path - e.g. if you have some global scripts that you don't want to add to `$PATH`:

```bash
alias dev="bin --exe dev --dir $HOME/scripts/dev"
```

You can set up [tab completion](#tab-completion) too:

```bash
eval "$(bin --completion --exe scr --dir scripts)"
eval "$(bin --completion --exe dev --dir $HOME/scripts/dev)"
```

### Automatic shims

I often use *Bin* to create shims for other executables - for example, [different PHP versions](https://github.com/bin-cli/bin-cli/wiki/PHP-version-shim) or [running scripts inside Docker](https://github.com/bin-cli/bin-cli/wiki/Docker-shim).

Rather than typing `bin php` every time, I use a Bash alias to run it automatically:

```bash
alias php='bin php'
```

However, that only works when inside a project directory. The `--shim` parameter tells *Bin* to run the global command of the same name if no local script is found:

```bash
alias php='bin --shim php'
```

Now typing `php -v` will run `bin/php -v` if available, but fall back to a regular `php -v` if not.

If you want to run a fallback command that is different to the script name, use `--fallback <command>` instead:

```bash
alias php='bin --fallback php8.1 php'
```

Both of these options imply `--exact` - i.e. [unique prefix matching](#unique-prefix-matching) is disabled.

### Getting the command name

*Bin* will set the environment variable `$BIN_COMMAND` to the command that was executed, for use in help messages:

```bash
echo "Usage: ${BIN_COMMAND-$0} [...]"
```

For example, if you ran `bin sample -h`, it would be set to `bin sample`, so would output:

```
Usage: bin sample [...]
```

But if you ran the script manually with `bin/sample -h`, it would output the fallback from `$0` instead:

```
Usage: bin/sample [...]
```

There is also `$BIN_EXE`, which you can use to display other commands, if required.

### Automatic exclusions

Scripts starting with `_` (underscore) are excluded from listings, but can be executed. This can be used for helper scripts that are not intended to be executed directly. (Or you could use a separate [`libexec` directory](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s07.html) if you prefer.)

Files starting with `.` (dot / period) are always ignored and cannot be executed with *Bin*.

Files that are not executable (not `chmod +x`) are listed as warnings, and will error if you try to run them. The exception is when using `root=.`, where they are just ignored.

A number of common non-executable file types (`*.json`, `*.md`, `*.txt`, `*.yaml`, `*.yml`) are also excluded when using `root=.`, even if they are executable, to reduce the noise when all files are executable (e.g. on FAT32 filesystems).

The directories `/bin`, `/snap/bin`, `/usr/bin`, `/usr/local/bin` and `~/bin` are ignored when searching parent directories, unless there is a corresponding `.binconfig` file, because they are common locations for global executables.

## Writing scripts

This is a very simple shell script, as listed above:

```bash
#!/bin/sh
echo 'Hello, World!'
```

It will run using the default system shell - in Ubuntu, that is Dash rather than Bash, which is a little faster but doesn't have all the same features.

If you want to use Bash instead, you could use `#!/bin/bash`, but it is better to use this variant, which should work even if Bash is installed in another location (e.g. by [Homebrew](https://brew.sh/)):

```bash
#!/usr/bin/env bash
echo 'Hello, World!'
```

For non-trivial scripts, I recommend adding `set -euo pipefail`, or equivalent, [for safety](https://www.howtogeek.com/782514/how-to-use-set-and-pipefail-in-bash-scripts-on-linux/).

```bash
#!/usr/bin/env bash
set -euo pipefail

# ...
```

For scripts written in other programming languages, just change the executable name as appropriate:

```python
#!/usr/bin/env python3
print('Hello, World!')
```

```ruby
#!/usr/bin/env ruby
puts 'Hello, World!'
```

```perl
#!/usr/bin/env perl
print "Hello, World!\n";
```

```php
#!/usr/bin/env php
<?php
echo "Hello, World!\n";
```

See [the wiki](https://github.com/bin-cli/bin-cli/wiki) for more example scripts and script-writing tips, and share your own in [the discussions section](https://github.com/bin-cli/bin-cli/discussions/categories/example-scripts-script-writing-tips).

## Miscellaneous

### CLI reference

<!-- START auto-update-cli-reference-docs -->

```
Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]

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

Any options must be given before the command, because everything after the command will be passed as parameters to the script.

For more details see https://github.com/bin-cli/bin-cli#readme
```

<!-- END auto-update-cli-reference-docs -->

## Get involved

- [Discussions & ideas](https://github.com/bin-cli/bin-cli/discussions)
- [Bug reports](https://github.com/bin-cli/bin-cli/issues)
- [Pull requests](https://github.com/bin-cli/bin-cli/pulls)

## License

[MIT License](LICENSE.md)
