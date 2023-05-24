# Introduction to Bin

<!-- This text is also in ../README.md -->

*Bin* is a simple task/script runner, designed to be used in code repositories, with scripts written in any programming language.

It automatically searches in parent directories, so you can run scripts from anywhere in the project tree.

It supports aliases and unique prefix matching, as well as tab completion, reducing the amount you need to type.

It is implemented as a self-contained shell script, small enough to bundle with your dotfiles or projects if you want to.

Its use is completely optional - users who choose not to install *Bin* can run the scripts directly.

*It doesn't natively support Windows - though it can be used via [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), [Git Bash](https://gitforwindows.org/), [MSYS2](https://www.msys2.org/) or [Cygwin](https://www.cygwin.com/).*

## How it works

A project just needs a `bin/` folder and some executable scripts:

```
repo/
├── bin/
│   ├── build
│   ├── deploy
│   └── hello
└── ...
```

The scripts can be written in any language, or can even be compiled binaries. Here is a simple `bin/hello` shell script:

```bash
#!/bin/sh
echo "Hello, ${1:-World}!"
```

To execute it, run:

```bash
$ bin hello
```

Now you may be thinking why not just do this:

```bash
$ bin/hello
```

And you're right, that would do the same thing... But *Bin* will also search in parent directories, so you can use it from anywhere in the project:

```bash
$ cd app/Http/Controllers/
$ bin hello # still works
$ bin/hello # doesn't work!
$ ../../../bin/hello # works, but is rather tedious to type!
```

It also supports unique prefix matching, so if `hello` is the only script starting with `h`, all of these will work too:

```bash
$ bin hell
$ bin hel
$ bin he
$ bin h
```

If you type a prefix that isn't unique, *Bin* will display a list of possible matches. Similarly, if you run `bin` on its own, it will list all available scripts.

There are a few more optional features, but that's all you really need to know to use it.
