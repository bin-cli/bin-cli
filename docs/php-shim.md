# PHP version shim

This is a script (`bin/php`) that I use to automatically detect the correct PHP version to use for the current project based on `composer.json`, when multiple versions are installed from the [PHP PPA repository](https://launchpad.net/~ondrej/+archive/ubuntu/php/):

```bash
#!/usr/bin/env bash
root="$(dirname "$0")/.."
version="$(perl -ne '/"php":\s*"(\d+\.\d+)\..*"/ && print $1' "$root/composer.json")"

if [[ -z $version ]]; then
    echo "Cannot determine the PHP version to use for this project" >&2
    exit 1
fi

if ! command -v "php$version" &>/dev/null; then
    echo "Cannot find 'php$version' executable" >&2
    exit 1
fi

exec "php$version" "$@"
```

It is a bit of a hack, because it uses Perl regex to search `composer.json` for a string like `"php": "8.1.*"`, rather than a proper parser - but it works for me.

I can then create additional shims, such as `bin/artisan` for [Laravel](https://laravel.com/), that make use of that script:

```bash
#!/usr/bin/env bash
root="$(dirname "$0")/.."
exec "$root/bin/php" "$root/artisan" "$@"
```

And then use Bash aliases, defined in `~/.bashrc`, to call these shims automatically:

```bash
alias artisan='bin --fallback ./artisan artisan'
alias php='bin --shim php'
```

You can also use that shim to run PHP scripts within the `bin/` directory:

```php
#!/usr/bin/env -S bin --exact php
<?php
echo "Using PHP " . PHP_VERSION . "\n";
```

However, that requires both *Bin* and [Coreutils](https://www.gnu.org/software/coreutils/coreutils.html) 8.30 or above (e.g. Ubuntu 20.04+). You could simplify it a little to work with older versions of Coreutils, but only if the `bin` executable is in the same location for all users:

```php
#!/usr/bin/bin php
<?php
echo "Using PHP " . PHP_VERSION . "\n";
```

The [shortest portable alternative](https://stackoverflow.com/a/33225083/167815) I could find, which only requires Perl, is:

```php
#!/usr/bin/perl -e$_=$ARGV[0];exec(s/[^\/]+$/php/r,@ARGV)
<?php #^ Run this using ./php - https://stackoverflow.com/a/33225083/167815
echo "Using PHP " . PHP_VERSION . "\n";
```

This does mess with automatic syntax detection in many editors though, so you may want to [add the `.php` extension](script-extensions.md).
