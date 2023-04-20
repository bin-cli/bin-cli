in_array() {
    local needle=$1
    shift

    for value in "$@"; do
        if [[ "$value" = "$needle" ]]; then
            return 0
        fi
    done

    return 1
}

command_matches() {
    local type=$1
    local target=$2
    local command=$3

    # Check for a match of the given type
    if [[ $type = exact ]]; then
        [[ "$command" = "$target" ]]
    elif [[ $type = with-extension ]]; then
        [[ "$command" = "$target".* ]]
    elif [[ $type = subcommands ]]; then
        [[ "$command" = "$target "* ]]
    elif [[ $type = prefix ]]; then
        [[ "$command" = "$target"* ]]
    else
        bug "Invalid \$type '$type' passed to command_matches()"
    fi

    # If it doesn't match, return false
    # shellcheck disable=SC2181
    if [[ $? -gt 0 ]]; then
        debug "    No match for \"$command\""
        return 1
    fi

    # If we're looking for subcommands, we want all of them at this point
    if [[ $type = subcommands ]]; then
        return 0
    fi

    # If it does match, we still need to filter out hidden subcommands
    if is_hidden_command "$command" "$target"; then
        debug "    Ignored hidden subcommand \"$command\""
        return 1
    fi

    return 0
}

is_hidden_command() {
    local command=$1
    local target=${2-}

    # We can't just match on $command, because it may be the parent command that is hidden
    prefix_length=${#target}
    if [[ $prefix_length -gt 0 ]]; then
        command="${command:$prefix_length}"
    else
        command=" $command"
    fi

    # Technically this would break on a command containing a space followed by an underscore,
    # like 'a _b' - but that's such an edge case I'm not going to complicate this any more!
    [[ $command = *" _"* || $command = *" '_"* ]]
}

matching_commands=()

find_matching_commands() {
    local type=$1
    local target=$2

    debug "  Looking for command \"$target\" ($type)"

    local -A commands_matching_aliases
    local command

    for alias in "${aliases[@]}"; do
        if command_matches "$type" "$target" "$alias"; then
            command=${alias_to_command[$alias]}
            commands_matching_aliases[$command]=true
            debug "    Found matching alias \"$alias\" for command \"$command\""
        fi
    done

    matching_commands=()
    for command in "${commands[@]}"; do
        if ${commands_matching_aliases[$command]-false}; then
            debug "    Found matching command \"$command\" (from alias)"
            matching_commands+=("$command")
        elif command_matches "$type" "$target" "$command"; then
            debug "    Found matching command \"$command\""
            matching_commands+=("$command")
        fi
    done
}

matching_commands_shared_prefix() {
    local prefix=$1
    local prefix_length=${#prefix}

    local shared_next_command=''

    for command in "${matching_commands[@]}"; do
        # Remove the common prefix
        local remaining=${command:$prefix_length}

        if [[ ! $remaining = *' '* ]]; then
            continue
        fi

        local next_command=${remaining/ *}

        if [[ -z $shared_next_command ]]; then
            shared_next_command=$next_command
        elif [[ "$next_command" != "$shared_next_command" ]]; then
            # Not unique
            return 1
        fi
    done

    if [[ -n $shared_next_command ]]; then
        echo "$prefix$shared_next_command"
    else
        # No subcommands found
        return 1
    fi
}
