ensure-in-test-root() {
    if [[ $1 != /* ]]; then
        invalid-test "Path '$1' must be absolute (use '\$TEST_ROOT')"
    fi

    if [[ $1 != "$TEST_ROOT/"* ]]; then
        invalid-test "Path '$1' must be within $TEST_ROOT (use '\$TEST_ROOT')"
    fi

    if [[ -L "$1" ]]; then
        target=$(realpath "$1")
        if [[ $target != "$TEST_ROOT"* ]]; then
            invalid-test "Symlink target '$target' for '$1' must be within $TEST_ROOT (use '\$TEST_ROOT')"
        fi
    fi
}

ensure-parent-directory-exists() {
    mkdir -p "${1%/*}"
}

arg-or-stdin() {
    if [[ -n $1 ]]; then
        echo "$1"
    else
        cat
    fi
}

write-file() {
    ensure-parent-directory-exists "$1"
    arg-or-stdin "${2-}" > "$1"
}

display-diff() {
    diff \
        --old-line-format="${RED}  ACTUAL:  %L${RESET}" \
        --new-line-format="${GREEN}EXPECTED:  %L${RESET}" \
        --unchanged-line-format='    BOTH:  %L' \
        <(echo "$1") \
        <(echo "$2")
}
