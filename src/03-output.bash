fail() {
    echo "$exe: $1" >&2
    exit "${2-246}"
}

bug() {
    local lines="${BASH_LINENO[*]}"
    lines=${lines% 0}
    fail "BUG: $1 on line ${lines// /, }"
}

# Helper to output debug data when using the bin/tdd script (development only)
debug() {
    local lines="${BASH_LINENO[*]}"
    lines=${lines% 0}
    echo "[line ${lines// /, }]" "$@" >&3
}
