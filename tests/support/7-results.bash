test-passed() {
    echo -n "$SUCCESS_ICON"
}

test-skipped() {
    ((tests_skipped+=1))
    echo -n "$SKIPPED_ICON"
}

test-failed() {
    echo "$FAIL_ICON"
    echo
    echo "${LRED}${BOLD}Test Failed${RESET}"
    echo "${LWHITE}Test File:${RESET} ${test_file}"
    echo "${LWHITE}Scenario:${RESET}  ${scenario_name}"
    echo
    for line in "$@"; do
        echo "$line"
    done

    if [[ -n $command ]]; then
        echo
        echo "${LMAGENTA}${BOLD}${UNDERLINE}Command${RESET}"
        echo "${command[@]}"
    fi

    if [[ -n $output ]]; then
        echo
        echo "${LGREEN}${BOLD}${UNDERLINE}Output${RESET}"
        echo "$output"
    fi

    if [[ -n $error ]]; then
        echo
        echo "${LRED}${BOLD}${UNDERLINE}Errors${RESET}"
        echo "$error"
    fi

    if [[ -n $debug ]]; then
        echo
        echo "${LCYAN}${BOLD}${UNDERLINE}Debug log${RESET}"
        echo "$debug"
    fi

    exit 1
}

display-final-result() {
    echo
    echo
    if [[ $tests_skipped -eq 0 ]]; then
        echo "${LGREEN}All tests passed.${RESET}"
    elif [[ $tests_skipped -eq 1 ]]; then
        echo "${LYELLOW}WARNING: $tests_skipped test skipped.${RESET}"
    else
        echo "${LYELLOW}WARNING: $tests_skipped tests skipped.${RESET}"
    fi
}
