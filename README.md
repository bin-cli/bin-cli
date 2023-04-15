# Bin – A simple task runner

*The following is a draft / plan - nothing has actually been implemented yet. Feedback is welcomed.*

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

There are [a few more optional features](#other-features), but that's all you really need to know to use it.

## Getting started

### Installation

*TODO*

### Tab completion

Add this to your `~/.bashrc` (or `~/.bash_completion`) script:

```bash
eval "$(bin --completion)"
```

Or you can lazy-load it by putting it in `~/.local/share/bash-completion/completions/bin`.

You may want to wrap it in a conditional, in case *Bin* is not installed:

```bash
if command -v bin &>/dev/null; then
    eval "$(bin --completion)"
fi
```

(**Note:** Only `bash` is supported at the moment. I may add `zsh` and others in the future.)

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

(See below for some [sample scripts](#sample-scripts).)

And make the scripts executable:

```bash
chmod +x bin/*
```

That's all there is to it. Now you can run them:

```bash
bin sample
```

### Config files

*Bin* config files are named `.binconfig`, and are written in [INI format](https://en.wikipedia.org/wiki/INI_file).

They are entirely **optional** - you don't need to create a config file unless you want to use [aliases](#aliases), [help text](#help-text), a [custom script directory](#custom-script-directory) or disable [unique prefix matching](#unique-prefix-matching). Here is an example with all of these:

```ini
root=scripts
exact=true

[hello]
alias=hi
help=Say "Hello, World!"
```

They should be placed in the project root directory:

```
repo/
├── bin/
│   └── ...
└── .binconfig
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

Aliases are listed alongside the help text when you run `bin` with no parameters (or with an ambiguous prefix). For example:

```bash
$ bin
Available commands
bin artisan    Run Laravel Artisan command with the appropriate version of PHP (alias: art)
bin deploy     Sync the code to the live server (aliases: publish, push)
```

Aliases are also subject to unique prefix matching - so here `bin pub` would match `bin publish`. `bin pu` would match both `bin publish` and `bin push`, but since both are aliases for the same script, that would be treated as a unique prefix and would therefore also run `bin deploy`.

Defining an alias that conflicts with a script or another alias will cause *Bin* to exit with an error code and print a message to stdout (for safety).

### Aliasing `b` to `bin`

If you prefer to shorten the script prefix from `bin` to `b`, you can create a symlink. The exact command will depend on how and where you installed *Bin* - for example:

```bash
$ sudo ln -s /usr/bin/bin /usr/local/bin/b
```

Or you can can create an alias in your shell's config. For example, in `~/.bashrc`:

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
$ bin --root scripts
```

In this case, it will search the parent directories as normal, and ignore the `root` setting in any `.binconfig` files it finds.

This is mostly useful when defining a custom alias, to support repositories you don't control:

```bash
alias scr='bin --exe scr --root scripts'
```

It can also be an absolute path - e.g. if you have some global scripts that you don't want to add to `$PATH`:

```bash
alias dev="bin --exe dev --root $HOME/scripts/dev"
```

You can set up [tab completion](#tab-completion) too:

```bash
eval "$(bin --completion --exe scr --root scripts)"
eval "$(bin --completion --exe dev --root $HOME/scripts/dev)"
```

### Automatic shims

I often use *Bin* to create shims for other executables - for example, [different PHP versions](#automatic-php-version-shim) or [running scripts inside Docker](#docker-shim).

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

### Getting the script name

*Bin* will set the environment variable `$BIN_COMMAND` to the command that was executed, for use in help messages:

```bash
echo "Usage: ${BIN_COMMAND:-$0} [...]"
```

For example, if you ran `bin sample -h`, it would be set to `bin sample`, so would output:

```
Usage: bin sample [...]
```

But if you ran the script manually with `bin/sample -h`, it would output the fallback from `$0` instead:

```
Usage: bin/sample [...]
```

### Debugging

If something doesn't seem to be working (or you're not sure why it works the way it does), add `--debug` at the start to see an explanation:

```bash
$ bin --debug --shim php -v
Bin version 1.2.3
Working directory is /project/public/
Looking for a root config file
  /project/public/.binconfig - not found
  /project/.binconfig - found
Parsing /project/.binconfig
  Root set to /project/scripts/
  Found config for 3 commands
Searching /project/scripts/ for scripts
  Found 1 subdirectory
  Found 5 commands in this directory
Searching /project/scripts/subdir/ for scripts
[...]
Looking for a script or alias matching 'php' - not found
Looking for scripts and aliases with the prefix 'php' - 0 found
Falling back to external 'php' because the --shim option was enabled
Would execute: php -v
```

You can also use `--print` to display only the command that would have been executed:

```bash
$ bin --print sample hello world
/project/bin/sample/hello world
$ bin --print --shim php -v
php -v
$ bin --print php -v
'php' not found in /project/bin/
```

### Automatic exclusions

Scripts starting with `_` (underscore) are excluded from listings, but can be executed. This can be used for helper scripts that are not intended to be executed directly. (Or you could use a separate [`libexec` directory](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s07.html) if you prefer.)

Files starting with `.` (dot / period) are always ignored and cannot be executed with *Bin*.

Files that are not executable (not `chmod +x`) are listed as warnings, and will error if you try to run them. The exception is when using `root=.`, where they are just ignored.

A number of common non-executable file types (`*.json`, `*.md`, `*.yml` and so on) are also excluded from listings when using `root=.`, even if they are executable, to reduce the noise when all files are executable (e.g. on FAT32 filesystems).

The directories `/bin`, `/snap/bin`, `/usr/bin`, `/usr/local/bin` and `~/bin` are ignored when searching parent directories, unless there is a corresponding `.binconfig` file, because they are common locations for global executables.

## Sample scripts

### Hello, World!

This is a very simple script, as listed above:

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

### Running external scripts

*Bin* doesn't change the working directory, for consistency with running scripts manually, so you need to resolve any paths first. For example, this is equivalent to a typical `npm start` script:

```bash
#!/usr/bin/env bash
exec node "$(dirname "$0")/../server.js"
```

Or you can change the working directory to the project root:

```bash
#!/usr/bin/env bash
cd "$(dirname "$0")/.."
exec node server.js
```

Or you may prefer to assign the root path to a variable, for clarity and/or reusability:

```bash
#!/usr/bin/env bash
root="$(dirname "$0")/.."
exec node "$root/server.js"
```

In that case, `$root` will be something like `/path/to/repo/bin/..` - which is valid but a little ugly. You may prefer to use this format instead - the code is a little longer, it will resolve to `/path/to/repo` instead:

```bash
#!/usr/bin/env bash
root=$(dirname "$(dirname "$0")")
exec node "$root/server.js"
```

In all of these, using `exec` tells Bash to replace itself with the given process, rather than running it in a subprocess.

### Automatic installation of dependencies

You could extend the script above to automatically install missing dependencies, rather than requiring the user to do it manually:

```bash
#!/usr/bin/env bash
cd "$(dirname "$0")/.."

if [[ ! -d node_modules ]]; then
    echo 'Installing dependencies...'
    npm ci || exit
    echo
fi

exec node server.js
```

### Automatic PHP version shim

This is a script (`bin/php`) that I use to automatically detect the correct PHP version to use for the current project based on `composer.json`, when multiple versions are installed from the [PHP PPA repository](https://launchpad.net/~ondrej/+archive/ubuntu/php/):

```bash
#!/usr/bin/env bash
root="$(dirname "$0")/.."
version="$(perl -ne '/"php":\s*"(\d+\.\d+)\..*"/ && print $1' "$root/composer.json")"

if [[ -z $version ]]; then
    echo "Cannot determine the PHP version to use for this project" >&2
    exit 1
fi

if ! command -v "php$version" &>/dev/null; then
    echo "Cannot find 'php$version' executable" >&2
    exit 1
fi

exec "php$version" "$@"
```

It is a bit of a hack, because it uses Perl regex to search `composer.json` for a string like `"php": "8.1.*"`, rather than a proper parser - but it works for me.

I can then create additional shims, such as `bin/artisan` for [Laravel](https://laravel.com/), that make use of that script:

```bash
#!/usr/bin/env bash
root="$(dirname "$0")/.."
exec "$root/bin/php" "$root/artisan" "$@"
```

And then use Bash aliases, defined in `~/.bashrc`, to call these shims automatically:

```bash
alias artisan='bin artisan'
alias php='bin php'
```

You can also use that shim to run PHP scripts within the `bin/` directory:

```php
#!/usr/bin/env -S bin php
<?php
echo "Using PHP " . PHP_VERSION . "\n";
```

However, that requires both *Bin* and [Coreutils](https://www.gnu.org/software/coreutils/coreutils.html) 8.30 or above (e.g. Ubuntu 20.04+). This is the [shortest portable alternative](https://stackoverflow.com/a/33225083/167815) I could find, which only requires Perl:

```php
#!/usr/bin/perl -e$_=$ARGV[0];exec(s/[^\/]+$/php/r,@ARGV)
<?php #^ Run this using ./php - https://stackoverflow.com/a/33225083/167815
echo "Using PHP " . PHP_VERSION . "\n";
```

### Docker shim

Similarly, you could create shims for commands that need to be run inside a Docker container:

```bash
#!/usr/bin/env bash
exec docker compose exec web php artisan "$@"
```

### Parameters & help

For more complex scripts, you may want to implement parameter parsing and help text. That is too complex to get into here, but I like to [use Getopt](https://djm.me/getopt) for Bash scripts (including *Bin* itself). Most other languages will have their own libraries.

## CLI reference

<!-- START CLI REFERENCE -->

```
Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]

Options that can be used with a command:
  --exact               Disable unique prefix matching
  --exe NAME            Override the executable name displayed in the command list
  --fallback COMMAND    If the command is not found, run the given global command (implies '--exact')
  --prefix              Enable unique prefix matching (overrides .binconfig)
  --root DIR            Specify the directory name to search for (overrides .binconfig)
  --shim                If the command is not found, run the global command with the same name (implies '--exact')

Options that do something special:
  --completion          Output a tab completion script for the current shell
  --debug               Display debugging information instead of running a command
  --help, -h            Display this help
  --print               Output the command that would have been run, instead of running it
  --shell SHELL         Override the shell to use for '--completion' -- only 'bash' is currently supported
  --version, -v         Display the current version number and exit

Any options must be given before the command, because everything after the command will be passed as parameters to the script.
```

<!-- END CLI REFERENCE -->
