commands=()
non_executable_files=()

declare -A command_to_executable

find_commands() {
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

        if [[ $name == _* ]]; then
            : # Files starting with "_"
        elif [[ -d $file ]]; then
            # Ignore subdirectories if scripts are in the root directory,
            # because it could take a long time to search a large tree, and it's
            # unlikely someone who keeps scripts in the root would also have
            # some in subdirectories
            if ! $is_root_dir; then
                find_commands "$file" "$prefix$name "
            fi
        elif [[ ! -x $file ]]; then
            non_executable_files+=("$file")
        elif [[ "$name" == *' '* ]]; then
            # Spaces in the name
            commands+=("$prefix'$name'")
            command_to_executable["$prefix'$name'"]=$file
        else
            commands+=("$prefix$name")
            command_to_executable["$prefix$name"]=$file
        fi
    done
}

find_commands "$bin_directory"
process_aliases
