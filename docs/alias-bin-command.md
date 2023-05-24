# Aliasing the `bin` command

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

You can set up [tab completion](installation.md#tab-completion) too:

```bash
eval "$(bin --completion --exe b)"
```
