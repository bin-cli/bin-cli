# Unique prefix matching

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
