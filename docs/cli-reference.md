# CLI reference

```
Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]

Options that can be used with a command:
  --dir DIR             Specify the directory name to search for (overrides .binconfig)
  --exact               Disable unique prefix matching
  --exe NAME            Override the executable name displayed in the command list
  --fallback COMMAND    If the command is not found, run the given global command (implies '--exact')
  --prefix              Enable unique prefix matching (overrides .binconfig)
  --shim                If the command is not found, run the global command with the same name (implies '--exact')

Options that do something special:
  --completion          Output a tab completion script for the current shell
  --debug               Display debugging information instead of running a command
  --help, -h            Display this help
  --print               Output the command that would have been run, instead of running it
  --shell SHELL         Override the shell to use for '--completion' -- only 'bash' is currently supported
  --version, -v         Display the current version number and exit

Any options must be given before the command, because everything after the command will be passed as parameters to the script.
```
