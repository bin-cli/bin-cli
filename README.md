<!--







********************************************************************************
********************************************************************************
********************************************************************************

    This file was automatically generated.

    DO NOT EDIT IT DIRECTLY.

    You should edit the source in the features/ directory instead.

    See CONTRIBUTING.md for more details.

********************************************************************************
********************************************************************************
********************************************************************************



















-->

<!-- features/1.00-introduction.md -->

# Bin CLI – A simple task/script runner

Bin is a simple task runner, designed to be used in code repositories, with scripts written in any programming language.

It automatically [searches in parent directories](#how-it-works), so you can run scripts from anywhere in the project tree. It also supports [aliases](#aliases), [unique prefix matching](#unique-prefix-matching) and [tab completion](#tab-completion), reducing the amount you need to type.

It is implemented as a self-contained Bash script, small enough to bundle with your dotfiles or projects if you want to.  It only requires Bash 3+ and a small number of [coreutils](https://www.gnu.org/software/coreutils/manual/) commands, so it should work on almost any Unix-like system (Linux, macOS, etc.). On Windows, it can be used via [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), [Git Bash](https://gitforwindows.org/), [Cygwin](https://www.cygwin.com/) or [MSYS2](https://www.msys2.org/).

Collaborators / contributors who choose not to install Bin can run the scripts directly, so you can enjoy the benefits without adding a hard dependency or extra barrier to entry.

_To see how Bin compares to some of the alternatives (Just, Task, Make, etc.), see [the wiki](https://github.com/bin-cli/bin-cli/wiki/Alternatives-to-Bin-CLI)._

<!-- features/2.00-how-it-works.feature -->

## How It Works

A project just needs a `bin/` folder and some executable scripts - for example:

```
repo/
├── bin/
│   ├── build
│   ├── deploy
│   └── hello
└── ...
```

The scripts can be written in any language, or can even be compiled binaries, as long as they are executable (`chmod +x`). Here is a very simple `bin/hello` shell script:

```bash
#!/bin/sh
echo "Hello, ${1:-World}!"
```

To execute it, run:

```
$ bin hello
Hello, World!
```

Now you may be thinking why not just run it directly, like this:

```
$ bin/hello
```

And that would do the same thing - but Bin will also search in parent directories, so you can use it from anywhere in the project:

```bash
$ cd app/Http/Controllers/
$ bin/hello                # Doesn't work :-(
$ ../../../bin/hello       # Works, but is rather tedious to type :-/
$ bin hello                # Still works :-)
```

<!-- features/2.01-listing-commands.feature -->

### Listing Commands

If you run `bin` on its own, it will list all available commands:

<pre>
$ bin hel
<strong>Available Commands</strong>
bin build
bin deploy
bin hello
</pre>

<details><summary><em>Can I add descriptions to the commands?</em></summary><blockquote>

Yes - see [Help text](#help-text), below.

</blockquote></details>

<!-- features/2.02-subcommands.feature -->

### Subcommands

If you have multiple related commands, you may want to group them together and make subcommands. To do that, just create a subdirectory:

```
repo/
└── bin/
    └── deploy/
        ├── production
        └── staging
```

Now `bin deploy production` will run `bin/deploy/production`, and `bin deploy` will list the available subcommands:

<pre>
$ bin deploy
<strong>Available Subcommands</strong>
bin deploy production
bin deploy staging
</pre>

<!-- features/2.03-unique-prefix-matching.feature -->

### Unique Prefix Matching

Any unique prefix is enough to run a command - so if `bin/hello` is the only script starting with `h`, all of these will work too:

```bash
$ bin hell
$ bin hel
$ bin he
$ bin h
```

This also works with subcommands - e.g. `bin dep prod` might run `bin/deploy/production`.

If you type a prefix that isn't unique, Bin will display a list of matches instead:

<pre>
$ bin hel
<strong>Matching Commands</strong>
bin hello
bin help
</pre>

<details><summary><em>How can I disable unique prefix matching?</em></summary><blockquote>

If you prefer to disable unique prefix matching, use `--exact` on the command line:

```bash
bin --exact hello
```

You'll probably want to set up a shell alias rather than typing it manually:

```bash
alias bin='bin --exact'
```

To disable it for a project, add this at the top of [`.binconfig`](#config-files):

```ini
exact = true
```

To enable it again, overriding the config file, use `--prefix`:

```bash
bin --prefix hel
```

Again, you'll probably want to set up a shell alias:

```bash
alias bin='bin --prefix'
```

</blockquote></details>

<!-- features/3.00-installation.md -->

## Installation

Bin CLI is a single script that you can [download](https://github.com/bin-cli/bin-cli/releases/latest/download/bin) to anywhere in your `$PATH`.

To install it system-wide (for all users) in `/usr/local/bin`:

```bash
sudo wget https://github.com/bin-cli/bin-cli/releases/latest/download/bin -O /usr/local/bin/bin
sudo chmod +x /usr/local/bin/bin
```

To install it for the current user only in `$HOME/.local/bin`:

```bash
mkdir -p ~/.local/bin
wget https://github.com/bin-cli/bin-cli/releases/latest/download/bin -O ~/.local/bin/bin
chmod +x ~/.local/bin/bin

# If $HOME/.local/bin is not already in your $PATH:
echo 'PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
PATH="$HOME/.local/bin:$PATH"
```

<details>
<summary><em>What are the system requirements?</em></summary>

> The requirements are minimal:
>
> - Bash 3.x or above
> - [Core utilities](https://www.gnu.org/software/coreutils/coreutils.html)
>   (specifically `basename`, `chmod`, `dirname`, `mkdir`, `readlink`, `sort`, `tr`, `uniq`)

</details>

<details>
<summary><em>What if <code>wget</code> is not available?</em></summary>

> You can use `curl` instead:
>
> ```bash
> sudo curl https://github.com/bin-cli/bin-cli/releases/latest/download/bin -Lo /usr/local/bin/bin
> curl https://github.com/bin-cli/bin-cli/releases/latest/download/bin -Lo ~/.local/bin/bin
> ```
>
> At least one of `curl` or `wget` are usually installed, or can easily be
> installed, so that covers 99.99% of cases... But just for completeness - you
> can also use [HTTPie](https://httpie.io/docs/cli):
>
> ```bash
> sudo http get https://github.com/bin-cli/bin-cli/releases/latest/download/bin -do /usr/local/bin/bin
> http get https://github.com/bin-cli/bin-cli/releases/latest/download/bin -do ~/.local/bin/bin
> ```
>
> Or [Node.js](https://docs.npmjs.com/cli/commands/npx):
>
> ```bash
> sudo npx download-cli https://github.com/bin-cli/bin-cli/releases/latest/download/bin -o /usr/local/bin/
> npx download-cli https://github.com/bin-cli/bin-cli/releases/latest/download/bin -o ~/.local/bin/
> ```
>
> Or just click [this link](https://github.com/bin-cli/bin-cli/releases/latest/download/bin)
> to download it using your browser.

</details>

<!-- features/3.01-upgrading.md -->

### Upgrading

To upgrade to the latest version at any time, just repeat the same `wget` command as above.

You may want to watch [this repo](https://github.com/bin-cli/bin-cli) to be notified when a new version is released - select Watch > Custom > Releases (or Watch > All Activity if you prefer).

<!-- features/3.02-tab-completion.feature -->

### Tab Completion

To enable tab completion in Bash, add this:

```bash
command -v bin &>/dev/null && eval "$(bin --completion)"
```

To any of the following files:

- `/usr/share/bash-completion/completions/bin` (recommended for system-wide installs)
- `/etc/bash_completion.d/bin`
- `~/.local/share/bash-completion/completions/bin` (recommended for per-user installs)
- `~/.bash_completion`
- `~/.bashrc`

<details><summary><em>How to use tab completion with custom aliases?</em></summary><blockquote>

If you are using a simple [shell alias](#aliasing-the-bin-command), e.g. `alias b=bin`, update the filename to match and add `--exe <name>`:

```bash
# e.g. in /usr/share/bash-completion/completions/b
command -v bin &>/dev/null && eval "$(bin --completion --exe b)"
```

If you have globally disabled [unique prefix matching](#unique-prefix-matching), e.g. `alias bin='bin --exact'`, add the same parameter here:

```bash
# e.g. in /usr/share/bash-completion/completions/bin
command -v bin &>/dev/null && eval "$(bin --completion --exact)"
```

Similarly, if you are using an alias with a [custom script directory](#custom-script-directory), e.g. `alias src='bin --dir scripts'`, add the same parameter here:

```bash
# e.g. in /usr/share/bash-completion/completions/scr
command -v bin &>/dev/null && eval "$(bin --completion --exe scr --dir scripts)"
```

If you have multiple aliases, just create a file for each one (or put them all together in `~/.bash_completion` or `~/.bashrc`).

</blockquote></details>

<details><summary><em>Why use <code>eval</code>?</em></summary><blockquote>

Using `eval` makes it more future-proof - in case I need to change how tab completion works in the future.

If you prefer, you can manually run `bin --completion` and paste the output into the file instead.

</blockquote></details>

<details><summary><em>What about other shells (Zsh, Fish, etc)?</em></summary><blockquote>

Only Bash is supported at this time. I will add other shells if there is [demand for it](https://github.com/bin-cli/bin-cli/discussions/categories/ideas), or gladly accept [pull requests](https://github.com/bin-cli/bin-cli/pulls).

</blockquote></details>

<!-- features/4.00-per-project-setup.md -->

## Per-Project Setup

In the root of the repository, create a `bin/` directory. For example:

```bash
mkdir bin
```

Then create some scripts inside it, in the language of your choice, using the text editor of your choice:

```bash
nano bin/sample
```

And make them executable:

```bash
chmod +x bin/*
```

That's all there is to it. Now you can run them:

```bash
bin sample
```

<details>
<summary><em>Can I change the directory name?</em></summary>

> Yes - see [custom script directory](#custom-script-directory), below.

</details>

<details>
<summary><em>Does the <code>bin/</code> directory have to exist?</em></summary>

> No - if you define all commands [inline in the config file](#inline-commands), you can omit the `bin/` directory.
>
> You can also put the scripts [in the root directory](#custom-script-directory) - but then [subcommands](#subcommands) won't be supported.

</details>

<!-- features/4.01-config-files.feature -->

### Config Files

Some of the features below require you to create a config file. It should be named `.binconfig` and placed in the project root directory, alongside the `bin/` directory:

```
repo/
├── bin/
│   └── ...
└── .binconfig
```

Config files are written in [INI format](https://en.wikipedia.org/wiki/INI_file). Here is an example:

```ini
; Global settings
dir = scripts
exact = true
merge = true
template = #!/bin/sh\n\n

; Settings for each command (script)
[hello]
alias = hi
help = Say "Hello, World!"

[phpunit]
command = "$BIN_ROOT/vendor/bin/phpunit" "%@"
```

The supported global keys are:

- `dir` (string) - Sets a [custom script directory](#custom-script-directory)
- `exact` (boolean) - Disables [unique prefix matching](#unique-prefix-matching)
- `merge` (boolean, or the string `optional`) - Enables [directory merging](#merging-directories)
- `template` (string) - Sets the template for [scripts created with `--create`](#creating--editing-scripts)

The supported per-command keys are:

- `alias`/`aliases` (comma-separated strings) - [Aliases](#aliases)
- `help` (string) - [Help text](#help-text)
- `command` (string) - [Inline commands](#inline-commands)

<details><summary><em>Do I need to create a <code>.binconfig</code> file?</em></summary><blockquote>

No - `.binconfig` only needs to exist if you want to use the features described below.

</blockquote></details>

<details><summary><em>What dialect of INI file is used?</em></summary><blockquote>

The INI file is parsed according to the following rules:

- Spaces are allowed around the `=` signs, and are automatically trimmed from the start/end of lines.
- Values should not be quoted - quotes will be treated as part of the value. This avoids the need to escape inner quotes.
- Boolean values can be set to `true`/`false` (recommended), `yes`/`no`, `on`/`off` or `1`/`0` (all case-insensitive). Anything else triggers an error.
- Lines that start with `;` or `#` are comments, which are ignored. No other lines can contain comments.

</blockquote></details>

<details><summary><em>Why isn&#39;t <code>.binconfig</code> inside <code>bin/</code>?</em></summary><blockquote>

`.binconfig` can't be inside the `bin/` directory because the [`dir` setting](#custom-script-directory) may change the name of the `bin/` directory, creating a chicken-and-egg problem (how would we find it in the first place?).

Technically it would be possible to support both locations for every setting _except_ `dir` - and I may if there is demand for it... But then we would have to decide what happens if there are two files - error, or merge them? If merged, how should we handle conflicts? Which one should `bin --edit .binconfig` open? And so on.

</blockquote></details>

<details><summary><em>What happens if an invalid key name is used?</em></summary><blockquote>

Invalid keys are ignored, to allow for forwards-compatibility with future versions of Bin CLI which may support additional settings. (The downside of this is you won't be warned if you make a typo, so I may change this in the future.)

Invalid command names are displayed as a warning when you run `bin`, after the command listing.

</blockquote></details>

<!-- features/5.00-other-features.md -->

## Other Features

<!-- features/5.01-creating-edit-scripts.feature -->

### Creating / Editing Scripts

You can use these commands to more easily create/edit scripts in your preferred editor (`$VISUAL` or `$EDITOR`, with `editor`, `nano` or `vi` as fallbacks):

```bash
bin --create sample
bin --edit sample
```

The `--create` (`-c`) command will pre-fill the file with a typical Bash script template and make it executable.

The `--edit` (`-e`) command supports [unique prefix matching](#unique-prefix-matching) (e.g. `bin -e sam`).

You can also use `bin --create .binconfig` to create a [config file](#config-files), and `bin --edit .binconfig` to edit it.

<details><summary><em>How can I customise the template for new scripts?</em></summary><blockquote>

Add this to the top of [`.binconfig`](#config-files):

```ini
template = #!/usr/bin/env bash\nset -euo pipefail\n\n
```

It is passed to `echo -e`, so you can use escape sequences such as `\n` for new lines.

</blockquote></details>

<!-- features/5.02-help-text.feature -->

### Help Text

To add a short (one-line) description of each command, enter it in `.binconfig` as follows:

```ini
[deploy]
help = Sync the code to the live server
```

This will be displayed when you run `bin` with no parameters (or with an ambiguous prefix). For example:

<pre>
$ bin
<strong>Available Commands</strong>
bin artisan    Run Laravel Artisan with the appropriate version of PHP
bin deploy     Sync the code to the live server
bin php        Run the appropriate version of PHP for this project
</pre>

I recommend keeping the descriptions short. The scripts could then support a `--help` parameter, or similar, if further explanation is required.

For subcommands, use the full command name, not the filename:

```ini
[deploy live]
help = Deploy to the production site

[deploy staging]
help = Deploy to the staging site
```

<!-- features/5.03-aliases.feature -->

### Aliases

You can define aliases in `.binconfig` like this:

```ini
[deploy]
alias = publish
```

This means `bin publish` is an alias for `bin deploy`, and running either would execute the `bin/deploy` script.

You can define multiple aliases by separating them with commas (and optional spaces). You can use the key `aliases` if you prefer to be pedantic:

```ini
[deploy]
aliases = publish, push
```

Or you can list them on separate lines instead:

```ini
[deploy]
alias = publish
alias = push
```

Alternatively, you can use symlinks to define aliases:

```bash
$ cd bin
$ ln -s deploy publish
```

Be sure to use relative targets, not absolute ones, so they work in any location. (Absolute targets will be rejected, for safety.)

In any case, aliases are listed alongside the help text when you run `bin` with no parameters (or with a non-unique prefix). For example:

<pre>
$ bin
<strong>Available Commands</strong>
bin artisan    Run Laravel Artisan with the appropriate version of PHP <em>(alias: art)</em>
bin deploy     Sync the code to the live server <em>(aliases: publish, push)</em>
</pre>

<details><summary><em>Can I define aliases for commands that have subcommands?</em></summary><blockquote>

Yes - for example, given a script `bin/deploy/live` and this config file:

```ini
[deploy]
alias = push
```

`bin push live` would be an alias for `bin deploy live`, and so on.

</blockquote></details>

<details><summary><em>How do aliases affect unique prefix matching?</em></summary><blockquote>

Aliases are checked when looking for unique prefixes. In this example:

```ini
[deploy]
aliases = publish, push
```

- `bin pub` would match `bin publish`, which is an alias for `bin deploy`, which runs the `bin/deploy` script
- `bin pu` would match both `bin publish` and `bin push` - but since both are aliases for `bin deploy`, that would be treated as a unique prefix and would therefore also run `bin/deploy`

</blockquote></details>

<details><summary><em>What happens if an alias conflicts with another command?</em></summary><blockquote>

Defining an alias that conflicts with a script or another alias will cause Bin to exit with error code 246 and print a message to stderr.

</blockquote></details>

<!-- features/5.04-inline-commands.feature -->

### Inline Commands

If you have a really short script, you can instead write it as an inline command in `.binconfig`:

```ini
[hello]
command = echo "Hello, ${1:-World}!"

[phpunit]
command = "$BIN_ROOT/vendor/bin/phpunit" "$@"

[watch]
command = "$BIN_DIR/build" --watch "$@"
```

The following variables are available:

- `$1`, `$2`, ... and `$@` contain the additional arguments, as normal
- `$BIN_ROOT` points to the project root directory (where `.binconfig` is found)
- `$BIN_DIR` points to the directory containing the scripts (usually `$BIN_ROOT/bin`, unless configured otherwise)
- The [standard environment variables](#environment-variables-to-use-in-scripts) listed below

<details><summary><em>How complex can the command be?</em></summary><blockquote>

The command is executed within a Bash shell (`bash -c "$command"`), so it may contain logic operators (`&&`, `||`), multiple commands separated by `;`, and pretty much anything else that you can fit into a single line.

</blockquote></details>

<details><summary><em>Why is this not the standard / recommended way to write commands?</em></summary><blockquote>

If you're using Bin as a replacement for the one-line tasks typically [defined in package.json](https://docs.npmjs.com/cli/commands/npm-run-script), it might seem perfectly natural to write all tasks this way (and you can do that if you want to).

However, I generally recommend writing slightly longer, more robust scripts. For example, checking that dependencies are installed before you attempt to do something that requires them, or even [installing them automatically](https://github.com/bin-cli/bin-cli/wiki/Automatically-installing-dependencies). It's hard to do that when you're limited to a single line of code.

It also violates this fundamental principle of Bin, listed in the introduction above:

> Collaborators / contributors who choose not to install Bin can run the scripts directly, so you can enjoy the benefits without adding a hard dependency or extra barrier to entry.

That's why I recommend only using inline commands for very simple commands, such as calling a third-party script installed by a package manager (as in the `phpunit` example) or creating a shorthand for a command that could easily be run directly (as in the `watch` example).

</blockquote></details>

<!-- features/5.05-script-extensions.feature -->

### Script Extensions

You can create scripts with an extension to represent the language, if you prefer that:

```
repo/
└── bin/
    ├── sample1.sh
    ├── sample2.py
    └── sample3.rb
```

The extensions will be removed when [listing commands](#listing-commands) and in [tab completion](#tab-completion) (as long as there are no conflicts):

<pre>
$ bin
<strong>Available Commands</strong>
bin sample1
bin sample2
bin sample3
</pre>

You can run them with or without the extension:

```bash
$ bin sample1
$ bin sample1.sh
```

You must include the extension in `.binconfig`:

```ini
[sample1.sh]
help = The extension is required here
```

<!-- features/5.06-custom-script-directory.feature -->

### Custom Script Directory

If you prefer the directory to be named `scripts` (or something else), you can configure that at the top of `.binconfig`:

```ini
dir = scripts
```

The path is relative to the `.binconfig` file - it won't search any parent or child directories.

This option is provided for use in projects that already have a `scripts` directory or similar. I recommend renaming the directory to `bin` if you can, for consistency with the executable name and [standard UNIX naming conventions](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

<details><summary><em>Can I put the scripts in the project root directory?</em></summary><blockquote>

If you have your scripts directly in the project root, you can use this:

```ini
dir = .
```

However, subcommands will **not** be supported, because that would require searching the whole (potentially [very large](https://i.redd.it/tfugj4n3l6ez.png)) directory tree to find all the scripts.

</blockquote></details>

<details><summary><em>What if I can&#39;t create a config file?</em></summary><blockquote>

You can also set the script directory at the command line:

```bash
$ bin --dir scripts
```

Bin will search the parent directories as normal, but ignore any `.binconfig` files it finds. This is mostly useful to support repositories you don't control.

You will probably want to define an alias:

```bash
alias scr='bin --exe scr --dir scripts'
```

</blockquote></details>

<details><summary><em>Can I use an absolute path?</em></summary><blockquote>

Not in a `.binconfig` file, but you can use an absolute path at the command line. For example, you could put your all generic development tools in `~/.local/bin/dev/` and run them as `dev <script>`:

```bash
alias dev="bin --exe dev --dir $HOME/.local/bin/dev"
```

</blockquote></details>

<!-- features/5.07-automatic-shims.feature -->

### Automatic Shims

I often use Bin to create shims for other executables - for example, [different PHP versions](https://github.com/bin-cli/bin-cli/wiki/PHP-version-shim) or [running scripts inside Docker](https://github.com/bin-cli/bin-cli/wiki/Docker-shim).

Rather than typing `bin php` every time, I use a Bash alias to run it automatically:

```bash
alias php='bin php'
```

However, that only works when inside a project directory. The `--shim` parameter tells Bin to run the global command of the same name if no local script is found:

```bash
alias php='bin --shim php'
```

Now typing `php -v` will run `bin/php -v` if available, but fall back to a regular `php -v` if not.

If you want to run a fallback command that is different to the script name, use `--fallback <command>` instead:

```bash
alias php='bin --fallback php8.1 php'
```

Both of these options imply `--exact` - i.e. [unique prefix matching](#unique-prefix-matching) is disabled (otherwise it might call `bin/phpunit`, for example).

<!-- features/5.08-environment-variables.feature -->

### Environment Variables To Use in Scripts

Bin will set the environment variable `$BIN_COMMAND` to the command that was executed, for use in help messages:

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

There is also `$BIN_EXE`, which is set to the name of the executable (typically just `bin`, but that [may be overridden](#aliasing-the-bin-command)).

<!-- features/5.09-aliasing-the-bin-command.feature -->

### Aliasing the `bin` Command

If you prefer to shorten the script prefix from `bin` to `b`, for example, you can create an alias in your shell's config. For example, in `~/.bashrc`:

```bash
alias b='bin --exe b'
```

The `--exe` parameter is used to override the executable name used in the [environment variables](#environment-variables-to-use-in-scripts) (`$BIN_COMMAND`, `$BIN_EXE`) and the [list of commands](#listing-commands):

<pre>
$ b
<strong>Available Commands</strong>
b hello
</pre>

You can skip it (i.e. use `alias b='bin'`) if you prefer it to say `bin`.

<details><summary><em>Alternatively, you can use a symlink</em></summary><blockquote>

System-wide installation:

```bash
$ sudo ln -s bin /usr/local/bin/b
```

Per-user installation:

```bash
$ ln -s bin ~/.local/bin/b
```

</blockquote></details>

<!-- features/5.10-merging-directories.feature -->

### Merging Directories

Occasionally, you may want to define commands that are specific to a certain subdirectory, without losing access to the main (parent) project commands.

For example, you may have several different themes, each with its own `build` command:

```
repo/                  ← parent project
├── bin/
│   └── deploy
└── themes/
    └── one/           ← child project
        ├── bin/
        │   └── build
        └── .binconfig
```

Normally, if you are in the `themes/one/` directory:

- `bin build` runs `themes/one/bin/build`
- `bin deploy` gives an error, because the parent directory is ignored

But if you add this to [`.binconfig`](#config-files) (in the child project):

```ini
merge = true
```

Then the two `bin/` directories are merged, so:

- `bin build` still runs `themes/one/bin/build`
- `bin deploy` runs `bin/deploy`

<details><summary><em>Can child project commands override parent project commands?</em></summary><blockquote>

No - any conflicts will be reported as an error, the same as if they were defined at the same level (e.g. by defining a command and an alias with the same name).

This is mostly because it would make the conflict-checking code too complex - but it has the benefit of enforcing simplicity (parent commands work from anywhere, and accidental conflicts are reported).

</blockquote></details>

<details><summary><em>Does this work with inline commands and aliases?</em></summary><blockquote>

Yes - you can use any combination of scripts, inline commands and aliases in both the parent and child projects.

</blockquote></details>

<details><summary><em>What if no parent project is found?</em></summary><blockquote>

If you set `merge = true` but there is no parent `bin/` directory (or `.binconfig` file), Bin will exit with an error.

To avoid that, set `merge = optional` instead. This may be useful in sub-projects that have separate repositories, so you can't guarantee they will be cloned together.

</blockquote></details>

<details><summary><em>Can three (or more) directories be merged?</em></summary><blockquote>

Yes - just set `merge = true` at each level below the first.

</blockquote></details>

<!-- features/5.11-automatic-exclusions.feature -->

### Automatic Exclusions

Scripts starting with `_` (underscore) are excluded from listings, but can still be executed. This can be used for hidden tools and helper scripts that are not intended to be executed directly. (Or you could use a separate [`libexec` directory](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s07.html) in the project root if you prefer.)

Files starting with `.` (dot / period) are always ignored and cannot be executed with Bin.

Files that are not executable (not `chmod +x`) are listed as warnings in the command listing, and will error if you try to run them. The exception is when using `dir = .`, where they are just ignored.

A number of common non-executable file types (`*.json`, `*.md`, `*.txt`, `*.yaml`, `*.yml`) are also excluded when using `dir = .`, even if they are executable, to reduce the noise when all files are executable (e.g. on FAT32 filesystems).

The directories `/bin`, `/snap/bin`, `/usr/bin`, `/usr/local/bin`, `$HOME/bin` and `$HOME/.local/bin` are ignored when searching parent directories, unless there is a corresponding `.binconfig` file, because they are common locations for global executables (typically in `$PATH`).

<!-- features/6.00-cli-reference.md -->

## CLI Reference

<!-- START auto-update-cli-reference -->

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
  --info                Display information about the current project (root, bin directory and config file location)
  --help, -h            Display this help
  --version, -v         Display the current version number and exit

Any options must be given before the command, because everything after the command will be passed as parameters to the script.

For more details see https://github.com/bin-cli/bin-cli/tree/main#readme
```

<!-- END auto-update-cli-reference -->

<!-- features/6.01-cli-arguments.feature -->

<!-- features/7.00-license.md -->

## License

[MIT License](LICENSE.md)

<!-- features/9.98-edge-cases.feature -->

<!-- features/9.99-code-quality.feature -->
