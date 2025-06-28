expect-success() {
    if [[ -n $error ]]; then
        test-failed "${FUNCNAME[0]}: Unexpected stderr (exit code ${LRED}${exit_code}${RESET})."
    fi

    if [[ $exit_code -ne 0 ]]; then
        test-failed "${FUNCNAME[0]}: Unexpected exit code ${LRED}${exit_code}${RESET} (no stderr)."
    fi

    test-passed
}

expect-failure-with-exit-code() {
    if [[ $exit_code -ne $1 ]]; then
        test-failed "${FUNCNAME[0]}: Got exit code ${LRED}${exit_code}${RESET} instead of $1."
    fi

    if [[ -n $output ]]; then
        test-failed "${FUNCNAME[0]}: Unexpected output"
    fi

    test-passed
}

expect-exit-code() {
    if [[ $exit_code -ne $1 ]]; then
        test-failed "${FUNCNAME[0]}: Got exit code ${LRED}${exit_code}${RESET} instead of $1."
    fi

    test-passed
}

expect-no-output() {
    if [[ -n $output ]]; then
        test-failed "${FUNCNAME[0]}: Unexpected output."
    fi

    test-passed
}

expect-output() {
    expected_output=$(arg-or-stdin "${1-}")

    if [[ "$output" != "$expected_output" ]]; then
        test-failed \
            "${FUNCNAME[0]}: Output does not match expectation" \
            "" \
            "$(display-diff "$output" "$expected_output")"
    fi

    test-passed
}

expect-output-contains() {
    expected_output=$(arg-or-stdin "${1-}")

    if [[ "$output" != *"$expected_output"* ]]; then
        test-failed \
            "${FUNCNAME[0]}: Output does not contain expectation" \
            "" \
            "$(display-diff "$output" "$expected_output")"
    fi

    test-passed
}

expect-no-error-messages() {
    if [[ -n $error ]]; then
        test-failed "${FUNCNAME[0]}: Unexpected stderr."
    fi

    test-passed
}

expect-error() {
    expected_error=$(arg-or-stdin "${1-}")

    if [[ "$error" != "$expected_error" ]]; then
        test-failed \
            "${FUNCNAME[0]}: Stderr does not match expectation" \
            "" \
            "$(display-diff "$error" "$expected_error")"
    fi

    test-passed
}

expect-complete-code-coverage() {
    if [[ -n ${DISABLE_KCOV-} ]]; then
        test-skipped
        return
    fi

    kcov \
        --exclude-line=kcov-ignore-line \
        --exclude-region=kcov-ignore-start:kcov-ignore-end \
        --path-strip-level=0 \
        --merge \
        "$TEST_COVERAGE/merged" \
        "$TEST_COVERAGE/result-"*

    result_rounded=$(jq -r '.percent_covered | tonumber | floor' "$TEST_COVERAGE/merged/kcov-merged/coverage.json")
    if [[ $result_rounded -lt 100 ]]; then
        result_float=$(jq -r '.percent_covered | tonumber' "$TEST_COVERAGE/merged/kcov-merged/coverage.json")
        test-failed "${FUNCNAME[0]}: Test coverage dropped to ${result_float}%"
    fi

    test-passed
}

expect-no-shellcheck-errors() {
    if [[ -n ${DISABLE_SHELLCHECK-} ]]; then
        test-skipped
        return
    fi

    # See 'shellcheck --list-optional' for all the optional tests available
    # --enable=check-set-e-suppressed \ # Can't see any good ways to solve these!
    # --enable=quote-safe-variables \ # Too verbose
    # --enable=require-variable-braces \ # Too verbose
    if ! result=$(
        shellcheck \
            --color \
            --enable=add-default-case \
            --enable=avoid-nullary-conditions \
            --enable=check-extra-masked-returns \
            --enable=check-unassigned-uppercase \
            --enable=deprecate-which \
            --enable=require-double-brackets \
            "$TEST_DIST/bin" 2>&1
    ); then
        test-failed "${FUNCNAME[0]}:" "$result"
    fi

    test-passed
}

expect-max-file-size() {
    actual_size=$(wc -c "$1" | cut -d' ' -f1)
    expected_size="$2"

    if [[ "$actual_size" -gt "$expected_size" ]]; then
        test-failed "${FUNCNAME[0]}: The size of '$1' is $actual_size bytes - expected no more than $expected_size bytes"
    fi

    test-passed
}
