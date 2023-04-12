# Bin – A simple task runner

*The following is a draft / plan - nothing has actually been implemented yet. Feedback is welcomed.*

## Introduction

*Bin* is a simple task/script runner, designed to be used in code repositories, with scripts written in any programming language.

It serves a similar purpose to `npm run`, `yarn run` and `composer run`, without being tied to a particular language/ecosystem.

It automatically searches in parent directories, so you can run scripts from anywhere in the project tree.

It supports aliases and unique prefix matching, as well as tab completion, reducing the amount you need to type.

It requires minimal configuration, and its use is completely optional. Some users may choose to install it, while others can bypass it and run the scripts directly.

*It doesn't (currently) natively support Windows - though it can be used via [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), [Git Bash](https://gitforwindows.org/), [MSYS2](https://www.msys2.org/) or [Cygwin](https://www.cygwin.com/).*

### How it works

A project just needs a `bin/` folder and some executable scripts:

```
repo/
├── bin/
│   ├── build
│   ├── deploy
│   └── hello
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

#### Interactive installer

```bash
curl https://bin.djm.me/install | bash -
```

This will ask you whether to use `sudo` or not, which installation method to use, and where to install it to (as appropriate). It won't make any changes without confirming them with you first.

#### APT

*TODO*

#### Manual download

*TODO*

### Upgrading

To upgrade, run:

```bash
bin --upgrade
```

*Bin* will attempt to detect the installation method used and run the appropriate command(s) to upgrade itself.

Alternatively, re-run the installer (see above).

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

They can be placed in the project root directory:

```
repo/
├── bin/
│   └── ...
└── .binconfig
```

Or in the `bin/` directory (with the exception of the `root` option):

```
repo/
└── bin/
    ├── .binconfig
    └── ...
```

I recommend the latter, because it keeps the scripts and their configuration together - but it's up to you. If there are multiple config files, they are merged together.

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
help=Deploy to the live site
```

Alternatively, you can put a separate `.binconfig` file in each subdirectory - then all command names are relative to that:

```ini
; bin/deploy/.binconfig

[live]
help=Deploy to the production site

[staging]
help=Deploy to the live site
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

### Tab completion

If you installed *Bin* via APT, a tab completion script will be installed automatically (in `/usr/share/bash-completion/completions/`).

If not, you can add this to your `~/.bashrc` (or `~/.bash_completion`) script:

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

If you prefer the directory to be named `scripts` (or something else), you can configure that at the top of `.binconfig` in the **root** directory:

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

In this case, it will search the parent directories as normal, and ignore the `root` setting in any `.binconfig` files.

This is mostly useful when defining a custom alias:

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
Working directory is /home/dave/project/public/
Looking for a root config file
  /home/dave/project/public/.binconfig - not found
  /home/dave/project/.binconfig - found
Parsing /home/dave/project/.binconfig
  Root set to /home/dave/project/scripts/
  Found config for 3 commands
Searching /home/dave/project/scripts/ for scripts and config files
  Parsing /home/dave/project/scripts/.binconfig
    Found config for 2 commands
  Found 1 subdirectory
  Found 5 commands in this directory
Searching /home/dave/project/scripts/subdir/ for scripts and config files
[...]
Looking for a script or alias matching 'php' - not found
Looking for scripts and aliases with the prefix 'php' - 0 found
Falling back to external 'php' because the --shim option was enabled
Would execute: php -v
```

You can also use `--print` to display only the command that would have been executed:

```bash
$ bin --print sample hello world
/home/dave/project/bin/sample/hello world
$ bin --print --shim php -v
php -v
$ bin --print php -v
'php' not found in /home/dave/project/bin/
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
  --help                Display this help
  --print               Output the command that would have been run, instead of running it
  --shell SHELL         Override the shell to use for '--completion' -- only 'bash' is currently supported
  --upgrade             Attempt to upgrade Bin to the latest version (aliases: --self-update, --update)
  --version             Display the current version number and exit

Any options must be given before the command, because everything after the command will be passed as parameters to the script.
```

<!-- END CLI REFERENCE -->

The following options are for internal use (in unit tests), and may change without warning:

```
  --list-aliases        List defined aliases
  --list-all            List all defined commands and aliases
  --list-commands       List defined commands
  --list-prefixes       List all unique prefixes
  --print-root          Print the full path to the directory that was determined to be the script root
```

## Design considerations

This section explains some of the reasons I built *Bin* the way I did.

### Location of scripts

The options I considered are:

- `bin/`
- `scripts/`
- Project root directory

I decided not to use the project root directory because that is often already cluttered with files - `package.json`, `composer.json`, `README.md`, and more.

I looked at a number of open source projects, and found a fairly even split between `bin` and `scripts`. I decided to use `bin` because it is shorter and it follows the [standard UNIX convention (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

**Note:** Despite "bin" technically being short for "binary", the same location is used for executable text-based scripts:

```bash
$ file /usr/bin/* | grep 'text executable' | wc -l
421
```

### Executable name

I didn't find any existing executables named `bin` in Ubuntu:

```bash
$ bin
Command 'bin' not found, did you mean:
  command 'tin' from deb tin (1:2.6.2~20220129-1)
  command 'bing' from deb bing (1.3.5-4)
  command 'ben' from deb ben (0.9.2ubuntu5)
  command 'bip' from deb bip (0.9.3-1)
  command 'dbin' from deb dbmix (0.9.8-8)
  command 'din' from deb din (51.1.1-2build1)
  command 'win' from deb wily (0.13.41-10)
```

So it made sense to have the executable name match the directory name. That way I can write documentation for other people using the full path, but can easily translate to the shorthand version in my head:

```bash
# Full path:
$ bin/hello/world param1 param2

# Using Bin:
$ bin hello world param1 param2

# With the appropriate aliases and/or prefix matches:
$ b h w param1 param2
```

I considered naming it simply "`b`", but I think that would be more confusing and more likely to conflict with users' existing aliases. So I made that an optional alias instead.

I also considered "`run`". Apparently I'm [not the only one](https://www.youtube.com/watch?v=SdmYd5hJISM&t=12s) to think of that, but there don't seem to be any in standard Ubuntu packages. But ultimately I liked `bin` better.

I couldn't use "`do`" because it is a Bash keyword, and "`go`" is used by the [Go programming language](https://go.dev/).

### Config files

I decided to use INI files because they are standard, easy to write and simple to parse (unlike YAML files). The format and filename is loosely based on [EditorConfig](https://editorconfig.org/) files.

I considered having help text and aliases defined in magic comments within the scripts themselves - but that would require modifications to the scripts (which may come from elsewhere), and it wouldn't work for binary executables. I decided not to support both options simultaneously for simplicity and consistency.

### Comparison with alternatives

The reasons I decided to write Bin, rather than using one of the existing options, are:

1. It works from any project subdirectory (unlike manually running shell scripts)
2. Scripts can accept arbitrary arguments (unlike [Make](https://makefiletutorial.com/), [Just](https://just.systems/)) - useful when writing a [shim](https://en.wikipedia.org/wiki/Shim_(computing)) for another program
3. It isn't tied to any particular language, and it has no dependencies (unlike [npm](https://docs.npmjs.com/cli/v7/commands/npm-run-script), [Yarn](https://classic.yarnpkg.com/lang/en/docs/cli/run/), [Composer](https://getcomposer.org/doc/articles/scripts.md), [Rake](https://ruby.github.io/rake/), [Grunt](https://gruntjs.com/)) - so I can safely use it for all my projects
4. Installing it is completely optional (unlike [Task](https://taskfile.dev/)) - collaborators can run the scripts directly if they prefer (they don't even need to know I'm using it)
5. It is standalone and small enough to include in my [dotfiles](https://github.com/d13r/dotfiles), for use on systems where I don't have root access

The alternatives I considered include:

[^make]: Can be used as a task runner by marking every target as [`.PHONY`](https://stackoverflow.com/a/2145605/167815), but that feels a bit hacky to me!
[^grunt]: Can be used as a basic task runner via [grunt-shell](https://www.npmjs.com/package/grunt-shell).
[^alias]: By defining a script/task that just calls another script/task.

|                      | Bin        | Scripts         | [npm](https://docs.npmjs.com/cli/v7/commands/npm-run-script) | [Yarn](https://classic.yarnpkg.com/lang/en/docs/cli/run/) | [Composer](https://getcomposer.org/doc/articles/scripts.md)  | [Task](https://taskfile.dev/)                                | [Just](https://just.systems/)                          | [Rake](https://ruby.github.io/rake/)                   | [Make](https://makefiletutorial.com/)                  | [Grunt](https://gruntjs.com/)                   |
| -------------------- | ---------- | --------------- | ------------------------------------------------------------ | --------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------ | ----------------------------------------------- |
| **Type**             | **Runner** | **N/A**         | **Runner**                                                   | **Runner**                                                | **Runner**                                                   | **Both**                                                     | **Both**                                               | **Both**                                               | Builder[^make]                                         | Builder[^grunt]                                 |
| **Written in**       | Shell      | N/A             | JavaScript                                                   | TypeScript                                                | PHP                                                          | Go                                                           | Rust                                                   | Ruby                                                   | C                                                      | JavaScript                                      |
| **Requires**         | **Shell**  | **Shell**       | Node.js                                                      | Node.js                                                   | PHP                                                          | **Nothing**                                                  | **Shell**                                              | Ruby                                                   | **Nothing**                                            | JavaScript                                      |
| **Standalone**       | **Yes**    | **N/A**         | No                                                           | No                                                        | Kind of (2.8 MB)                                             | **Yes** (5 MB)                                               | **Yes** (5 MB)                                         | No                                                     | No                                                     | No                                              |
| **Scripts in**       | **Any**    | **Any**         | **Any**                                                      | **Any**                                                   | **Any**                                                      | **Any**                                                      | **Any**                                                | **[Any](https://stackoverflow.com/a/14360488/167815)** | **Any**                                                | JavaScript                                      |
| **Config in**        | INI        | N/A             | JSON                                                         | JSON                                                      | JSON                                                         | YAML                                                         | Custom                                                 | Ruby                                                   | Custom                                                 | JavaScript                                      |
| **Linux/Mac/WSL**    | Yes        | Yes             | Yes                                                          | Yes                                                       | Yes                                                          | Yes                                                          | Yes                                                    | Yes                                                    | Yes                                                    | Yes                                             |
| **Windows (native)** | No         | No              | **Yes**                                                      | **Yes**                                                   | **Yes**                                                      | **Yes**                                                      | **Yes**                                                | **Yes**                                                | [Maybe](https://stackoverflow.com/a/32127632/167815)   | **Yes**                                         |
| **Search parents**   | **Yes**    | No              | **Yes**                                                      | **Yes**                                                   | Prompts first                                                | **Yes**                                                      | **Yes**                                                | **Yes**                                                | No                                                     | **Yes**                                         |
| **Arguments**        | **Yes**    | **Yes**         | **Yes**                                                      | **Yes**                                                   | **Yes**                                                      | [Prefixed](https://taskfile.dev/usage/#forwarding-cli-arguments-to-commands) | Limited                                                | Limited                                                | Limited                                                | Limited                                         |
| **CLI optional**     | **Yes**    | **N/A**         | No                                                           | No                                                        | No                                                           | No                                                           | No                                                     | No                                                     | No                                                     | No                                              |
| **Tab completion**   | **Yes**    | **Yes**         | **[Yes](https://docs.npmjs.com/cli/v7/commands/npm-completion)** | [Third party](https://github.com/mklabs/yarn-completions) | [Third party](https://github.com/bramus/composer-autocomplete) | **[Yes](https://taskfile.dev/installation/#bash)**           | **[Yes](https://just.systems/man/en/chapter_63.html)** | **Yes**                                                | **Yes**                                                | **[Yes](https://github.com/gruntjs/grunt-cli)** |
| **Prefix matches**   | **Yes**    | No              | No                                                           | No                                                        | No                                                           | No                                                           | No                                                     | No                                                     | No                                                     | No                                              |
| **Aliases**          | **Yes**    | Kind of[^alias] | Kind of[^alias]                                              | Kind of[^alias]                                           | Kind of[^alias]                                              | [Yes](https://taskfile.dev/usage/#task-aliases)              | **[Yes](https://github.com/casey/just#aliases)**       | [Kind of](https://stackoverflow.com/a/7661613/167815)  | [Kind of](https://stackoverflow.com/a/33594470/167815) | Kind of[^alias]                                 |

Of these, [Task](https://taskfile.dev/) would be my second choice - but I find shell scripts more suitable for the majority of my own use cases. YMMV.
