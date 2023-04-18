is_root_dir=false

# Locate the bin/ directory
if [[ -n $binconfig ]]; then
    # If a .binconfig file exists, that takes precedence
    if [[ $bin_dirname = '.' ]]; then
        bin_directory=$root
        is_root_dir=true
    else
        bin_directory="$root/$bin_dirname"
    fi
elif root=$(findup -d bin); then
    # If there is no .binconfig, look for a bin/ directory instead
    bin_directory="$root/bin"
else
    fail "'bin' directory not found" 127
fi
