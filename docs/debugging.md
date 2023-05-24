# Debugging

If something doesn't seem to be working (or you're not sure why it works the way it does), add `--debug` at the start to see an explanation:

```bash
$ bin --debug --shim php -v
Bin version 1.2.3
Working directory is /local/project/public
Looking for a .binconfig file in:
-- /local/project/public - not found
-- /local/project - found
[...]
No command found - using shim
Would execute: php -v
```

You can also use `--print` to display only the command that would have been executed:

```bash
$ bin --print sample hello world
/project/bin/sample/hello world
$ bin --print --shim php -v
php -v
$ bin --print php -v
bin: Command "php" not found in /project/bin
```
