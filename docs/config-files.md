# Config files

*Bin* config files are named `.binconfig`, and are written in [INI format](https://en.wikipedia.org/wiki/INI_file).

They are entirely **optional** - you don't need to create a config file unless you want to use [aliases](aliases.md), [help text](help-text.md), a [custom script directory](custom-script-directory.md) or disable [unique prefix matching](unique-prefix-matching.md). Here is an example with all of these:

```ini
root=scripts
exact=true

[hello]
alias=hi
help=Say "Hello, World!"
```

They should be placed in the project root directory, alongside the `bin/` directory:

```
repo/
├── bin/
│   └── ...
└── .binconfig
```
