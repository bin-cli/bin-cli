# Remove the extensions, as long as they are unique
remove_extension() {
    # Can't use ${command%%.*} because it could remove too much ("a.b c" => "a" instead of "a.b")
    # Can't use ${command%.*} because it could remove too little ("a.b.c" => "a.b" instead of "a")
    local command="$1"

    while [[ "$command" =~ (.*?)(\.[a-zA-Z0-9]+)+ ]]; do
        command=${BASH_REMATCH[1]}
    done

    echo "$command"
}

has_duplicate() {
    local short=$1
    local long=$2

    local command

    for command in "${commands[@]}"; do
        case "$command" in
            # Ignore a match to itself
            "$long") continue ;;
            # Matched to the short command, but not the long one
            "$short") return 0 ;;
            "$short."*) return 0 ;;
        esac
    done

    for alias in "${aliases[@]}"; do
        case "$alias" in
            "$short") return 0 ;;
            "$short."*) return 0 ;;
        esac
    done

    # No matches found
    return 1
}

unique_commands=()

for command in "${list_commands[@]}"; do
    short=$(remove_extension "$command")
    if has_duplicate "$short" "$command"; then
        unique_commands+=("$command")
    else
        unique_commands+=("$short")
    fi
done

# Calculate the maximum length of a command in the list so we can align the help text
maxlength=0
for command in "${unique_commands[@]}"; do
    if [[ ${#command} -gt $maxlength ]]; then
        maxlength=${#command}
    fi
done

# Output the list
get_command_aliases() {
    local command=$1
    local command_aliases=''
    local command_alias_count=0

    for alias in "${aliases[@]}"; do
        local target=${alias_to_command[$alias]}
        if [[ "$target" = "$command" ]]; then
            (( command_alias_count+=1 ))
            command_aliases+=", $alias"
        fi
    done

    if [[ $command_alias_count -eq 1 ]]; then
        echo "alias: ${command_aliases:2}"
    elif [[ $command_alias_count -gt 1 ]]; then
        echo "aliases: ${command_aliases:2}"
    fi
}

echo "$TITLE$list_title$RESET"

for command in "${unique_commands[@]}"; do
    command_help=${help[$command]-}
    command_aliases=$(get_command_aliases "$command")

    if [[ -n $command_help && -n $command_aliases ]]; then
        printf "%s %-${maxlength}s    %s\n" "$exe" "$command" "$command_help $ALIASES($command_aliases)$RESET"
    elif [[ -n $command_help ]]; then
        printf "%s %-${maxlength}s    %s\n" "$exe" "$command" "$command_help"
    elif [[ -n $command_aliases ]]; then
        printf "%s %-${maxlength}s    %s\n" "$exe" "$command" "$ALIASES($command_aliases)$RESET"
    else
        printf "%s %s\n" "$exe" "$command"
    fi
done

# List non-executable files, if any
if [[ ${#non_executable_files[@]} -gt 0 ]]; then
    echo
    echo "Not executable:"
    for file in "${non_executable_files[@]}"; do
        echo "$file"
    done
fi
