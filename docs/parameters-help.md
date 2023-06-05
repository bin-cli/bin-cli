# Parameters & help

## Simple

To implement a simple `--help` option:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ ${1-} = '--help' || ${1-} = '-h' ]]; then
    echo "Usage: ${BIN_COMMAND-$0} [name]"
    echo
    echo 'Say "Hello" to the named person, or the world in general.'
    exit
fi

echo "Hello, ${1-World}!"
```

If you need something more complex, this may be a good time to switch to a language with a proper argument parsing library built in (e.g. [Python](https://docs.python.org/3/howto/argparse.html), [Ruby](https://ruby-doc.org/stdlib-2.7.1/libdoc/optparse/rdoc/OptionParser.html)) or a suitable library/framework available ([Symfony Console](https://symfony.com/doc/current/components/console.html), [Laravel Zero](https://laravel-zero.com/), [oclif](https://oclif.io/) and [so on](https://github.com/shadawck/awesome-cli-frameworks)) - but here are a couple of options when writing Bash scripts...

## Getopt

For more complex scripts with lots of parameters, I like to use Getopt. It is not part of Bash, and isn't available on macOS, but it is commonly included in Linux distributions.

Here is a template for a script using Getopt:

```bash
#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

help() {
    echo "Usage: $exe [OPTIONS] [--] ARG1 [ARG2...]"
    echo
    echo "Description here..."
    echo
    echo "Arguments:"
    echo "  ARG1                      a required positional argument"
    echo "  ARG2...                   optional positional arguments"
    echo
    echo "Options:"
    echo "  -b, --boolean             boolean flag, no value accepted"
    echo "  -h, --help                display this help"
    echo "  -o, --optional[=VALUE]    option with optional argument"
    echo "      --other               option with no short version"
    echo "  -r, --required=VALUE      option with required argument"
    echo
    echo "Additional explanation and links here if needed..."
}

exe=$(basename "$0")
args=$(getopt -n "$exe" -o 'hbr:o::' -l 'help,boolean,required:,optional,other::' -- "$@")
eval set -- "$args"

boolean=false other=false
unset optional required

while true; do
    case "$1" in
        -b | --boolean) boolean=true; shift ;;
        -h | --help) help; exit ;;
        -o | --optional) optional=$2; shift 2 ;;
        --other) other=true; shift ;;
        -r | --required) required=$2; shift 2 ;;
        --) shift; break ;;
        *) echo "$exe: BUG: option '$1' was not handled" >&2; exit 2 ;;
    esac
done

if [[ $# -lt 1 ]]; then
    help >&2
    exit 1
fi

# The rest of the script goes here...
```

If `getopt` fails due to invalid options, `set -e` (`errexit`) causes the script to exit. If you don't use that, change that line to:

```bash
args=$(getopt -n "$exe" -o 'hbr:o::' -l 'help,boolean,required:,optional,other::' -- "$@") || exit
```

The options passed to `getopt` itself are:

- `-n` - Executable name (*recommended*) - used in error messages
- `-o` - Short options (*required*) - single letters, no separator
- `-l` - Long options (*optional*) - comma-separated

For both `-o` and `-l`:

- The suffix `:` means _required argument_ (`--required=value`, `-rvalue` or `--required value`/`-r value`)
- The suffix `::` means _optional argument_ (`--optional=value`/`-ovalue` but not `--optional value`/`-o value`)
- No suffix means _no argument_ (`--boolean`/`-b`)

We initialise the boolean variables to `false`, and unset the rest to ensure they aren't inherited from the parent process. (Or you could give them default values.)

## Getopts

Getopts is built into Bash, so is more portable than Getopt, but it only supports short parameters, and doesn't support parameters with optional values. Here is an example:

```bash
#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

help() {
    echo "Usage: $exe [OPTIONS] [--] ARG1 [ARG2...]"
    echo
    echo "Description here..."
    echo
    echo "Arguments:"
    echo "  ARG1       a required positional argument"
    echo "  ARG2...    optional positional arguments"
    echo
    echo "Options:"
    echo "  -b         boolean flag, no value accepted"
    echo "  -h         display this help"
    echo "  -r VALUE   option with required argument"
    echo
    echo "Additional explanation and links here if needed..."
}

exe=$(basename "$0")

boolean=false
unset required

while getopts ':hbr:' OPTION; do
    case "$OPTION" in
        b) boolean=true ;;
        r) required=$OPTARG ;;
        h) help; exit ;;
        \?) help >&2; exit 1 ;;
        *) echo "$exe: BUG: option '$OPTION' was not handled" >&2; exit 2 ;;
    esac
done

shift "$((OPTIND - 1))"

if [[ $# -lt 1 ]]; then
    help >&2
    exit 1
fi

# The rest of the script goes here...
```
