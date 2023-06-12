# Debugging

If something doesn't seem to be working (or you're not sure why it works the way it does), add `--debug` at the start to see an explanation:

<!-- START auto-update-debugging-docs -->

```bash
Bin version 1.2.3
Working directory is '/example/project'
Action is 'run'
Determining paths...
-- No directory specified at the command line
-- Looking for a .binconfig file starting from /example/project
---- Checking in /example/project - not found
---- Checking in /example - not found
-- Looking for a bin/ directory starting from /example/project
---- Checking in /example/project - found
-- root=/example/project
-- binconfig=
-- bin_dir=/example/project/bin
-- bin_dir_from_root=bin
-- is_root_dir=bin
'exact' defaulted to 'false'
Searching '/example/project/bin/' for scripts to register
-- Registered command 'test' for executable '/example/project/bin/test'
Processing symlink aliases
Processing directory aliases and checking for conflicts
Processing positional parameters
-- Looking for command 'test' (exact)
---- Found matching command 'test'
Would execute: /example/project/bin/test
```

<!-- END auto-update-debugging-docs -->

You can also use `--print` to display only the command that would have been executed:

```bash
$ bin --print sample hello world
/project/bin/sample/hello world
$ bin --print --shim php -v
php -v
$ bin --print php -v
bin: Command "php" not found in /project/bin
```
