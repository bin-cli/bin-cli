# Help text

To add a short description for a command, enter it in `.binconfig` as follows:

```ini
[deploy]
help=Sync the code to the live server
```

This will be displayed when running `bin` with no parameters (or with an ambiguous prefix). For example:

```bash
$ bin
Available commands
bin artisan    Run Laravel Artisan command with the appropriate version of PHP
bin deploy     Sync the code to the live server
bin php        Run the appropriate version of PHP for this project
```

I recommend keeping the description short, and implementing a `--help` parameter if further explanation is required.
