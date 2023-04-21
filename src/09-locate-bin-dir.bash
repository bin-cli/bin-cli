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

    if [[ ! -d $bin_directory ]]; then
        fail "Found '$binconfig', but '$bin_directory/' directory is missing"
    fi

elif [[ $bin_dirname = '/'* ]]; then

    # Absolute path given at the command line
    bin_directory="$bin_dirname"
    debug "Bin directory set to '$bin_directory' (absolute) from CLI"

    if [[ ! -d $bin_directory ]]; then
        fail "Specified directory '$bin_directory/' is missing"
    fi

else

    # If there is no .binconfig, look for a bin/ directory instead (or other name specified with --dir)
    debug "Looking for a $bin_dirname/ directory in"
    if root=$(findup -d "$bin_dirname"); then
        bin_directory="${root%%/}/$bin_dirname"
        debug "Bin directory set to '$bin_directory'"
    else
        fail "Could not find '$bin_dirname/' directory or '.binconfig' file starting from '$PWD'" $ERR_NOT_FOUND
    fi

    # Check for special cases that we only allow with a matching .binconfig file
    if [[
        $bin_directory = '/bin' ||
        $bin_directory = '/usr/bin' ||
        $bin_directory = '/usr/local/bin' ||
        $bin_directory = '/snap/bin' ||
        $bin_directory = "$HOME/bin"
    ]]; then
        fail "Could not find '$bin_dirname/' directory or '.binconfig' file starting from '$PWD' (ignored '$bin_directory')" $ERR_NOT_FOUND
    fi

fi
