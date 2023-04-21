if [[ -t 1 ]]; then
    TITLE=$(printf "\e[97;1;4m") # White, bold, underline
    ALIASES=$(printf "\e[90m") # Grey
    RESET=$(printf "\e[0m")
else
    TITLE=''
    ALIASES=''
    RESET=''
fi

# The debug output always goes to a terminal, but indirectly
DEBUG_LINE=$(printf "\e[90m")
DEBUG_RESET=$(printf "\e[0m")

# This is a bit of a hack so we can use 'debug' from 'findup' without writing to stdout
exec 4>&1

debug() {
    # Display debug data when using --debug (only after parsing parameters)
    if ${debug-}; then
        echo "$@" >&4
    fi

    # Output debug data to FD 3 when using the 'bin tdd' script in development
    if { true >&3; } 2>/dev/null; then
        local lines="${BASH_LINENO[*]}"
        lines=${lines% 0}
        echo "$@" "$DEBUG_LINE[line ${lines// /, }]$DEBUG_RESET" >&3
    fi
}

debug_exit() {
    debug "$@"
    if $debug; then
        exit
    fi
}

ERR_NOT_EXECUTABLE=126
ERR_NOT_FOUND=127
ERR_GENERIC=246

fail() {
    local message=$1
    local code=${2-$ERR_GENERIC}

    debug "Failed with message: $message"
    debug_exit "Exit code: $code"

    echo "$exe: $message" >&2
    exit "$code"
}

bug() {
    local lines="${BASH_LINENO[*]}"
    lines=${lines% 0}
    fail "BUG: $1 on line ${lines// /, }"
}
