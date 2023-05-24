# Getting the command name

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
