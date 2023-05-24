# Custom script directory

If you prefer the directory to be named `scripts` (or something else), you can configure that at the top of `.binconfig`:

```ini
root=scripts
```

The root path is relative to the `.binconfig` file - it won't search any parent or child directories.

This option is provided for use in projects that already have a `scripts` directory or similar. I recommend renaming the directory to `bin` if you can, for consistency with the executable name and [standard UNIX naming conventions](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

## Scripts in the root directory

If you have your scripts directly in the project root, you can use this:

```ini
root=.
```

However, subcommands will <u>not</u> be supported, because that would require searching the whole (potentially [very large](https://i.redd.it/tfugj4n3l6ez.png)) directory tree to find all of scripts.

## Overriding it at runtime

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

You can set up [tab completion](installation.md#tab-completion) too:

```bash
eval "$(bin --completion --exe scr --dir scripts)"
eval "$(bin --completion --exe dev --dir $HOME/scripts/dev)"
```
