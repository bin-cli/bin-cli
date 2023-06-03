# Parameters & help

To implement a simple `--help` option:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ ${1-} = '--help' || ${1-} = '-h' ]]; then
    echo "Usage: ${BIN_COMMAND-$0} [name]"
    echo
    echo 'Say "Hello" to the named person, or the world in general."
    exit
fi

echo "Hello, ${1-World}!"
```

For more complex scripts, you may want to implement more complex parameter parsing. I like to [use Getopt](https://djm.me/getopt) for Bash scripts:

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

But that may be a good time to switch to a language with a proper argument parsing library (e.g. [Python](https://docs.python.org/3/howto/argparse.html), [Ruby](https://ruby-doc.org/stdlib-2.7.1/libdoc/optparse/rdoc/OptionParser.html)) or a suitable library/framework ([Symfony Console](https://symfony.com/doc/current/components/console.html), [Laravel Zero](https://laravel-zero.com/), [oclif](https://oclif.io/) and [so on](https://github.com/shadawck/awesome-cli-frameworks)).
