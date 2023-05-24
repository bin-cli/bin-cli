# Script extensions

If you prefer, you can create scripts with an extension to represent the language:

```
repo/
└── bin/
    ├── sample1.sh
    ├── sample2.py
    └── sample3.rb
```

The extensions will be removed when listing scripts and in [tab completion](installation.md#tab-completion) (as long as there are no conflicts):

```bash
$ bin
Available commands
bin sample1
bin sample2
bin sample3
```

You can run them with or without the extension:

```bash
$ bin sample1
$ bin sample1.sh
```
