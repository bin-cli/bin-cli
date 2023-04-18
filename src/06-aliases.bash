aliases=()
declare -A alias_to_command
declare -A alias_sources

register_alias() {
    local alias=$1
    local command=$2
    local source=$3

    if [[ -n ${alias_to_command[$alias]-} ]]; then
        fail "The alias '$alias' conflicts with an existing alias in $source (originally defined in ${alias_sources[$alias]})"
    fi

    aliases+=("$alias")
    alias_to_command[$alias]=$command
    alias_sources[$alias]=$source
}

process_aliases() {
    for alias in "${aliases[@]}"; do
        # Check for conflicts
        if [[ -n "${command_to_executable[$alias]-}" ]]; then
            fail "The alias '$alias' conflicts with an existing command in ${alias_sources[$alias]}"
        fi

        # Expand aliases to cover subcommands (e.g. if 'deploy'='push' then 'deploy live'='push live')
        target=${alias_to_command[$alias]}
        for command in "${commands[@]}"; do
            if [[ "$command" = "$target "* ]]; then
                suffix=${command:${#target}}
                aliases+=("$alias$suffix")
                alias_to_command[$alias$suffix]="$target$suffix"
            fi
        done
    done
}
