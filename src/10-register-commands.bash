commands=()
non_executable_files=()

declare -A command_to_executable

register_commands() {
    local directory=$1
    local prefix=${2-}

    local file
    local name

    # Loop through the directory to find commands
    for file in "$directory/"*; do
        if [[ ! -e $file ]]; then
            continue
        fi

        name=${file##*/} # Remove path

        if [[ -d $file ]]; then
            # Ignore subdirectories if scripts are in the root directory,
            # because it could take a long time to search a large tree, and it's
            # unlikely someone who keeps scripts in the root would also have
            # some in subdirectories
            if $is_root_dir; then
                debug "  Ignored subdirectory '$file'"
            else
                debug "  Searching subdirectory '$file'"
                register_commands "$file" "$prefix$name "
            fi
        elif [[ ! -x $file ]]; then
            if ! $is_root_dir; then
                non_executable_files+=("$file")
            fi
            debug "  Ignored non-executable file '$file'"
        elif [[ "$name" == *' '* ]]; then
            # Spaces in the name
            commands+=("$prefix'$name'")
            command_to_executable["$prefix'$name'"]=$file
            debug "  Registered command \"$prefix'$name'\""
        else
            commands+=("$prefix$name")
            command_to_executable["$prefix$name"]=$file
            debug "  Registered command \"$prefix$name\""
        fi
    done
}

debug "Searching '$bin_directory' for scripts"
register_commands "$bin_directory"

debug "Processing aliases"
process_aliases
