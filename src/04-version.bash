debug "Bin version $VERSION"

if $version; then
    debug_exit "Would print version number"
    echo "Bin version $VERSION"
    exit
fi
