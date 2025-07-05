# Bin CLI – A simple task/script runner for any language

Bin CLI is a simple task runner, designed to be used in code repositories, with scripts written in any programming language.

It automatically [searches in parent directories](#how-it-works), so you can run scripts from anywhere in the project tree. It also supports [aliases](#aliases), [unique prefix matching](#unique-prefix-matching) and [tab completion](#tab-completion), reducing the amount you need to type.

It is implemented as a self-contained Bash script, small enough to bundle with your dotfiles or projects if you want to.  It only requires Bash 4+ and a small number of [coreutils](https://www.gnu.org/software/coreutils/manual/) commands, so it should work on almost any Unix-like system (Linux, macOS with Homebrew, etc.). On Windows, it can be used on [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), [Git Bash](https://gitforwindows.org/), [Cygwin](https://www.cygwin.com/) or [MSYS2](https://www.msys2.org/).

Collaborators / contributors who choose not to install Bin can run the scripts directly, so you can enjoy the benefits without adding a hard dependency or extra barrier to entry.

## How It Works

A project just needs a `bin/` folder and some executable scripts - for example:

```
repo/
└── bin/
    ├── build
    ├── deploy
    └── hello
```

The scripts can be written in any language, or can even be compiled binaries, as
long as they are executable (`chmod +x`).  To demonstrate, here is a very simple
`bin/hello` shell script:

```bash
#!/bin/sh
echo "Hello, ${1:-World}!"
```

### Running Commands

To execute it, run:

```bash
$ bin hello
Hello, World!
```

Any additional parameters are passed through to the script/executable:

```bash
$ bin hello Dave
Hello, Dave!
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

> [!WARNING]
> Bin CLI executes arbitrary commands/scripts in the current working directory
> (or the directory specified by `--dir`) - the same as if you executed them
> directly. You should not run commands from untrusted sources.

### Listing Commands

If you run `bin` on its own, it will list all available commands:

<pre>
$ bin
<strong>Available Commands</strong>
bin build
bin deploy
bin hello
</pre>

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

## Installation

Bin CLI is a single script that you can simply [download](https://github.com/bin-cli/bin-cli/releases/latest/download/bin) to anywhere in your `$PATH`.

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

To remove it again, just delete the file:

```bash
sudo rm /usr/local/bin/bin
```

Or:

```bash
rm ~/.local/bin/bin
```

<details>
<summary><em>What are the system requirements?</em></summary>

> The requirements are minimal:
>
> - Bash 4.x or above (macOS users can upgrade via [Homebrew](https://formulae.brew.sh/formula/bash))
> - [Core Utilities](https://www.gnu.org/software/coreutils/coreutils.html), [BusyBox](https://busybox.net/) or equivalent
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
> installed, so that covers 99.99% of cases... Or you can click
> [this link](https://github.com/bin-cli/bin-cli/releases/latest/download/bin)
> to download it using your browser.

</details>

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

<details>
<summary><em>Why use <code>eval</code>?</em></summary>

> Using `eval` makes it more future-proof - in case I need to change how tab completion works in the future.
>
> If you prefer, you can manually run `bin --completion` and paste the output into the file instead.

</details>

<details>
<summary><em>What about other shells (Zsh, Fish, etc)?</em></summary>

> Only Bash is supported at this time. I will add other shells if there is [demand for it](https://github.com/bin-cli/bin-cli/issues/12), or gladly accept [pull requests](https://github.com/bin-cli/bin-cli/pulls).

</details>

### Upgrading

To upgrade to the latest version at any time, just repeat the same `wget` command as above.

If you want to be notified when a new version is released, watch [this repo](https://github.com/bin-cli/bin-cli) (select Watch > Custom > Releases, or Watch > All Activity if you prefer).

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

Which creates this directory structure:

```
repo/
└── bin/
    └── sample
```

That's all there is to it. Now you can run them:

```bash
bin sample
```

<details>
<summary><em>Does the directory name need to be <code>bin/</code>?</em></summary>

> You can define an alias using a custom name - see [custom script directory](#custom-script-directory), below.
>
> But you can't configure a different directory name on a per-project basis (except perhaps by writing your own wrapper function - see below).

</details>

## Other Features

### Aliases

You can define aliases by creating symlinks between scripts within the `bin/` directory - for example:

```bash
$ cd bin
$ ln -s deploy publish
```

Which creates this directory structure (symlink targets indicated by `->`):

```
repo/
└── bin/
    ├── deploy
    └── publish -> deploy
```

This means `bin publish` is an alias for `bin deploy`. Aliases are listed alongside the commands when you run `bin` with no parameters (or with a non-unique prefix). For example:

<pre>
$ bin
<strong>Available Commands</strong>
bin artisan <em>(alias: art)</em>
bin deploy <em>(aliases: publish, push)</em>
</pre>

Be sure to use relative targets, not absolute ones, so they work in any location. (Absolute targets will be rejected to prevent mistakes.)

If a symlink points to a script outside `bin/`, or a script within a subdirectory, it will be displayed as a regular command.

<details>
<summary><em>Can I define aliases for commands that have subcommands (i.e. directories)?</em></summary>

> Yes - for example, given this directory structure:
>
> ```
> repo/
> └── bin/
>     ├── deploy
>     │   └── live
>     └── push -> deploy
> ```
>
> `bin push` would be an alias for `bin deploy`, so `bin push live` would be an alias for `bin deploy live`, and so on.

</details>

<details>
<summary><em>How do aliases affect unique prefix matching?</em></summary>

> Aliases are checked when looking for unique prefixes. In this example:
>
> ```
> repo/
> └── bin/
>     ├── deploy
>     ├── publish -> deploy
>     └── push -> deploy
> ```
>
> - `bin pub` would match `bin publish`, which is an alias for `bin deploy`, which runs the `bin/deploy` script
> - `bin pu` would match both `bin publish` and `bin push` - but since both are aliases for `bin deploy`, that would be treated as a unique prefix and would therefore also run `bin/deploy`

</details>

### Custom Script Directory

You can override the directory name at the command line:

```bash
$ bin --dir scripts
```

This is mostly useful to support repositories you don't control. You will probably want to use an alias such as:

```bash
alias scr='bin --exe scr --dir scripts'
```

Or perhaps a wrapper function:

```bash
bin() {
    if [[ $PWD/ == /path/to/repo/* ]]; then
        command bin --dir scripts "$@"
    else
        command bin "$@"
    fi
}
```

You can also use an absolute path - for example, you could put your all generic development tools in `~/.local/bin/dev/` and run them as `dev <script>`:

```bash
alias dev="bin --exe dev --dir $HOME/.local/bin/dev"
```

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

<details>
<summary><em>Alternatively, you can use a symlink</em></summary>

> System-wide installation:
>
> ```bash
> $ sudo ln -s bin /usr/local/bin/b
> ```
>
> Per-user installation:
>
> ```bash
> $ ln -s bin ~/.local/bin/b
> ```

</details>

<details>
<summary><em>How to use tab completion with a custom alias?</em></summary>

> Update the filename to match (if applicable) and add `--exe <name>`:
>
> ```bash
> # e.g. in /usr/share/bash-completion/completions/b
> command -v bin &>/dev/null && eval "$(bin --completion --exe b)"
> ```
>
> If you are using an alias with a [custom script directory](#custom-script-directory), e.g. `alias scr='bin --dir scripts'`, add the same parameter here:
>
> ```bash
> # e.g. in /usr/share/bash-completion/completions/scr
> command -v bin &>/dev/null && eval "$(bin --completion --exe scr --dir scripts)"
> ```

</details>

### Automatic Exclusions

Files starting with `.` (dot / period) are always ignored and cannot be executed with Bin.

Files that are not executable (not `chmod +x`) are listed as warnings in the command listing, and will error if you try to run them.

The directories `/bin`, `/snap/bin`, `/usr/bin`, `/usr/local/bin`, `$HOME/bin` and `$HOME/.local/bin` are ignored when searching parent directories, because they are common locations for global executables (typically in `$PATH`).

## CLI Reference

```
Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]

Options that can be used with a command:
  --dir DIR             Specify the directory name to search for (absolute or relative path)
  --exe NAME            Override the executable name displayed in the command list

Options that do something special:
  --completion          Output a tab completion script for the current shell
  --help, -h            Display this help
  --version, -v         Display the current version number

Any options must be given before the command, because everything after the command will be passed as parameters to the script.

For more details see https://github.com/bin-cli/bin-cli/tree/main#readme
```

## License

[MIT License](LICENSE.md)

