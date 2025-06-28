kcov_id=0

run() {
    command="$1"
    env="${2-}"

    # Create/empty temp files
    # (Doing this without at least one temp file is non-trivial! https://stackoverflow.com/q/11027679/167815)
    : > "$DEBUG_FILE"
    : > "$ERROR_FILE"

    # Use kcov to measure code coverage
    # (Except on a couple of tests where it doesn't work)
    if [[ -z ${DISABLE_KCOV-} ]]; then
        ((kcov_id+=1))

        # Using '--collect-only' doesn't work in kcov 38:
        #   https://github.com/SimonKagstrom/kcov/issues/342
        # '--debug-force-bash-stderr' seems to be required to pass through the stdout/stderr:
        #   https://github.com/SimonKagstrom/kcov/issues/362#issuecomment-962489973
        command="\"$(which kcov)\" --debug-force-bash-stderr --include-path='$TEST_ROOT/usr/bin/bin' --path-strip-level=0 '$TEST_COVERAGE/result-$kcov_id' $command"
    fi

    # Reset environment variables
    command=$(printf \
        "env -i BIN_DEBUG_LOG=%q BIN_TEST_ROOT=%q HOME=%q PATH=%q %s %s" \
        "$DEBUG_FILE" \
        "$TEST_ROOT" \
        "$TEST_ROOT/home/user" \
        "$TEST_ROOT/usr/bin" \
        "$env" \
        "$command"
    )

    # Run it and capture the output
    exit_code=0
    output=$(cd "$working_dir" && eval "$command" 2>"$ERROR_FILE") || exit_code=$?
    error=$(cat "$ERROR_FILE")
    debug=$(cat "$DEBUG_FILE")

    # Clean up temp files
    rm -f "$DEBUG_FILE" "$ERROR_FILE"
}

run-without-kcov() {
    DISABLE_KCOV=1 run "$@"
}

tab-complete() {
    line=$1
    point=${#line}

    # A '|' in the line marks the cursor - adjust COMP_POINT accordingly, then remove it from COMP_LINE
    if [[ $line = *'|'* ]]; then
        prefix=${line%%|*}
        point=${#prefix}
        line=${line/|}
    fi

    env=$(printf 'COMP_LINE=%q COMP_POINT=%q' "$line" "$point")
    run "bin --complete-bash" "$env"
}

tab-complete-with-arguments() {
    line=$2
    point=${#line}

    # A '|' in the line marks the cursor - adjust COMP_POINT accordingly, then remove it from COMP_LINE
    if [[ $line = *'|'* ]]; then
        prefix=${line%%|*}
        point=${#prefix}
        line=${line/|}
    fi

    env=$(printf 'COMP_LINE=%q COMP_POINT=%q' "$line" "$point")
    run "bin $1 --complete-bash" "$env"
}
