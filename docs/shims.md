# Automatic shims

I often use *Bin* to create shims for other executables - for example, [different PHP versions](php-shim.md) or [running scripts inside Docker](docker-shim.md).

Rather than typing `bin php` every time, I use a Bash alias to run it automatically:

```bash
alias php='bin php'
```

However, that only works when inside a project directory. The `--shim` parameter tells *Bin* to run the global command of the same name if no local script is found:

```bash
alias php='bin --shim php'
```

Now typing `php -v` will run `bin/php -v` if available, but fall back to a regular `php -v` if not.

If you want to run a fallback command that is different to the script name, use `--fallback <command>` instead:

```bash
alias php='bin --fallback php8.1 php'
```

Both of these options imply `--exact` - i.e. [unique prefix matching](unique-prefix-matching.md) is disabled.
