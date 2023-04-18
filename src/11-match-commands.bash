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

matches() {
    local type=$1
    local target=$2
    local command=$3

    if [[ $type = exact ]]; then
        [[ "$command" = "$target" ]]
    elif [[ $type = with-extension ]]; then
        [[ "$command" = "$target".* ]]
    elif [[ $type = prefix ]]; then
        [[ "$command" = "$target"* ]]
    else
        bug "Invalid \$type '$type' passed to matches()"
    fi
}

matching_commands=()

find_matching_commands() {
    local type=$1
    local target=$2

    local -A commands_matching_aliases
    local command

    for alias in "${aliases[@]}"; do
        if matches "$type" "$target" "$alias"; then
            command=${alias_to_command[$alias]}
            commands_matching_aliases[$command]=true
        fi
    done

    matching_commands=()
    for command in "${commands[@]}"; do
        if ${commands_matching_aliases[$command]-false} || matches "$type" "$target" "$command"; then
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
