run_command_if_only_one_match() {
    if [[ ${#matching_commands[@]} -eq 1 ]]; then
        command=${matching_commands[0]}
        executable=${command_to_executable[$command]}
        export BIN_COMMAND="$exe$entered_command"
        run_command "$executable" "$@"
    else
        debug "    There were ${#matching_commands[@]} matches - not running command"
    fi
}

run_command() {
    if [[ $action = 'print' ]]; then
        debug_exit "Would print:" "$@"
        echo "$@"
        exit
    else
        debug_exit "Would execute:" "$@"
        exec "$@"
    fi
}

# If no command is given, we will list all available commands
list_title='Available commands'
list_commands=("${commands[@]}")

# Loop through each argument until we find a matching command
debug "Processing positional parameters"
entered_command=''

while [[ $# -gt 0 ]]; do
    command=$1
    shift

    # Build up the entered command in canonical format
    if [[ $command = *' '* ]]; then
        entered_command+=" '$command'"
    else
        entered_command+=" $command"
    fi

    # Check if there's an exact match
    find_matching_commands exact "${entered_command:1}"
    run_command_if_only_one_match "$@"

    # Check if there's an almost-exact match with an added extension
    find_matching_commands with-extension "${entered_command:1}"
    run_command_if_only_one_match "$@"

    # Check if there are any subcommands
    find_matching_commands prefix "${entered_command:1} "

    if [[ ${#matching_commands[@]} -gt 0 ]]; then
        list_title='Available subcommands'
        list_commands=("${matching_commands[@]}")
        continue
    fi

    # If we haven't matched anything yet, check whether we should run a fallback instead
    if [[ ${#matching_commands[@]} -eq 0 ]]; then
        if $shim; then
            debug "No command found - using shim"
            debug_exit "Would execute:" "${entered_command:1}" "$@"
            # We want word splitting here - commands with spaces are quoted
            # shellcheck disable=SC2086
            run_command ${entered_command:1} "$@"
        elif [[ -n $fallback ]]; then
            debug "No command found - using fallback"
            debug_exit "Would execute:" "$fallback" "$@"
            # We want word splitting here - the fallback command may contain spaces to separate arguments
            # shellcheck disable=SC2086
            run_command $fallback "$@"
        fi
    fi

    # Check if there are any prefix matches
    # We need to check even with --exact so we can list them
    find_matching_commands prefix "${entered_command:1}"

    if parent=$(matching_commands_shared_prefix "${entered_command:1}"); then
        entered_command=" $parent"
        list_title='Available subcommands'
        list_commands=("${matching_commands[@]}")
        continue
    fi

    if $exact; then
        debug "    Not checking matches because 'exact' is $exact"
    else
        run_command_if_only_one_match "$@"
    fi

    # If there were no prefix matches, stop searching
    if [[ ${#matching_commands[@]} -eq 0 ]]; then
        if $is_root_dir && [[ -d "$bin_directory/" ]]; then
            fail "Subcommands are not supported with the config option 'dir=$bin_dirname'"
        fi
        fail "Command \"${entered_command:1}\" not found in $bin_directory" 127
    fi

    # Otherwise display the list of matches
    list_title='Matching commands'
    list_commands=("${matching_commands[@]}")
    break
done
