is_root_dir=false

# Locate the bin/ directory
if [[ -n $binconfig ]]; then
    # If a .binconfig file exists, that takes precedence
    if [[ ${bin_dirname%%/} = '.' ]]; then
        # Special case for the root directory (see docs)
        bin_directory=$root
        is_root_dir=true
        debug "Bin directory set to '$bin_directory' (root) from config file"
    else
        bin_directory="${root%%/}/$bin_dirname"
        debug "Bin directory set to '$bin_directory' from config file"
    fi
elif [[ $bin_dirname = '/'* ]]; then
    # Absolute path
    bin_directory="$bin_dirname"
    debug "Bin directory set to '$bin_directory' (absolute) from CLI"
else
    debug "Looking for a $bin_dirname/ directory in"
    if root=$(findup -d "$bin_dirname"); then
        # If there is no .binconfig, look for a bin/ directory instead (or other name specified with --dir)
        bin_directory="${root%%/}/$bin_dirname"
        debug "Bin directory set to '$bin_directory'"
    else
        fail "'$bin_dirname' directory not found" 127
    fi
fi
