# Subcommands

If you have multiple related commands, you may want to group them together and make subcommands. To do that, just create a subdirectory:

```
repo/
├── bin/
│   └── deploy/
│       ├── live
│       └── staging
└── ...
```

Now `bin deploy live` will run `bin/deploy/live`, and `bin deploy` will list the available subcommands.

In `.binconfig`, use the full command names:

```ini
[deploy live]
help=Deploy to the production site

[deploy staging]
help=Deploy to the staging site
```
