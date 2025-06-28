#!/usr/bin/env bash
set -euo pipefail

prompt=${1:-}

# Display usage info if no prompt is given
if [[ -z $prompt ]]; then
    echo "Usage: $(basename "$0") <prompt> [default]" >&2
    exit 2
fi

# Determine the default value
if [[ ${2:-} = 'Y' || ${2:-} = 'y' ]]; then
    default='Y'
    yn='Y/n'
elif [[ ${2:-} = 'N' || ${2:-} = 'n' ]]; then
    default='N'
    yn='y/N'
else
    default=''
    yn='y/n'
fi

# Ask the question (not using "read -p" as it uses stderr not stdout)
echo -n "$prompt [$yn] "

# Repeat until we get a valid answer
result=

while [[ -z $result ]]; do

    # Read a single character, without echoing it
    read -rsn1 reply

    # If the user pressed enter, use the default value
    if [[ -z $reply ]]; then
        reply=$default
    fi

    # Check if the reply is valid
    case "$reply" in
        Y*|y*) result=0 ;;
        N*|n*) result=1 ;;
    esac

done

# Output the reply, or the default value, so the user can see it
echo "$reply"

# Exit with the relevant code for true or false
exit $result
