# Development Notes

## Design considerations

This section explains some of the reasons I built *Bin* the way I did...

### Location of scripts

The options I considered are:

- `bin/`
- `scripts/`
- Project root directory

I decided not to use the project root directory because that is often already cluttered with files - `package.json`, `composer.json`, `README.md`, and more.

I looked at a number of open source projects, and found a fairly even split between `bin` and `scripts`. I decided to use `bin` because it is shorter and it follows the [standard UNIX convention (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

**Note:** Despite "bin" technically being short for "binary", the same location is used for executable text-based scripts:

```bash
$ file /usr/bin/* | grep 'text executable' | wc -l
421
```

### Executable name

I didn't find any existing executables named `bin` in Ubuntu:

```bash
$ bin
Command 'bin' not found, did you mean:
  command 'tin' from deb tin (1:2.6.2~20220129-1)
  command 'bing' from deb bing (1.3.5-4)
  command 'ben' from deb ben (0.9.2ubuntu5)
  command 'bip' from deb bip (0.9.3-1)
  command 'dbin' from deb dbmix (0.9.8-8)
  command 'din' from deb din (51.1.1-2build1)
  command 'win' from deb wily (0.13.41-10)
```

So it made sense to have the executable name match the directory name. That way I can write documentation for other people using the full path, but can easily translate to the shorthand version in my head:

```bash
# Full path:
$ bin/hello/world param1 param2

# Using Bin:
$ bin hello world param1 param2

# With the appropriate aliases and/or prefix matches:
$ b h w param1 param2
```

I considered naming it simply "`b`", but I think that would be more confusing and more likely to conflict with users' existing aliases. So I made that an optional alias instead.

I also considered "`run`". Apparently I'm [not the only one](https://www.youtube.com/watch?v=SdmYd5hJISM&t=12s) to think of that, but there don't seem to be any in standard Ubuntu packages. But ultimately I liked `bin` better.

I couldn't use "`do`" because it is a Bash keyword, and "`go`" is used by the [Go programming language](https://go.dev/).

### Config files

I decided to use INI files because they are standard, easy to write and simple to parse (unlike YAML files). The format and filename is loosely based on [EditorConfig](https://editorconfig.org/) files.

I considered having help text and aliases defined in magic comments within the scripts themselves - but that would require modifications to the scripts (which may come from elsewhere), and it wouldn't work for binary executables. I decided not to support both options simultaneously for simplicity and consistency.
