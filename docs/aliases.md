# Aliases

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
