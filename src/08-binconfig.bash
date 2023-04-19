binconfig=''
declare -A help

debug "Working directory is $PWD"

# Initial search & parse to find the dir= setting only
# That way we don't need to "undo" everything we did if it doesn't match
debug "Looking for a .binconfig file"

if root=$(findup -f .binconfig); then
    binconfig="$root/.binconfig"
    bin_dirname_from_config=''

    debug "Checking $binconfig for a 'dir' setting"

    line=0
    while IFS='=' read -r key value; do
        (( line+=1 ))

        if [[ $key = '' || $key = '#'* ]]; then
            # Skip blank lines & comments
            :
        elif [[ $key =~ ^\[(.+)]$ ]]; then
            # [command]
            debug "  Reached section $key - giving up"
            break
        elif [[ $key = 'dir' ]]; then
            # dir=scripts
            debug "  Found $key=$value"
            bin_dirname_from_config=$value
            break
        fi
    done < "$binconfig"

    if [[ -z $bin_dirname_from_config ]]; then
        debug "  Not found"
    fi

    if [[ $bin_dirname_from_config = /* ]]; then
        fail "The option 'dir' cannot be an absolute path in $binconfig line $line"
    elif [[ "$(realpath "$root/$bin_dirname_from_config")/" != "$root/"* ]]; then
        fail "The option 'dir' cannot point to a directory outside $root in $binconfig line $line"
    elif [[ -z $bin_dirname ]]; then
        # If no directory was given at the command line, use the one from the config file
        debug "  Using '$bin_dirname_from_config' from the config file"
        bin_dirname=$bin_dirname_from_config
    elif [[ "$bin_dirname_from_config" != "$bin_dirname" ]]; then
        # If the directory given at the command line doesn't match the config file,
        # ignore the rest of the config file, and don't treat this as the root
        debug "  The config file setting '$bin_dirname_from_config' doesn't match the CLI setting '$bin_dirname' - ignoring config file"
        binconfig=''
    fi
fi

# If the config file was found, and there was no conflict, parse it fully now
if [[ -n $binconfig ]]; then
    debug "Parsing $binconfig"

    command=''

    line=0
    while IFS='=' read -r key value; do
        (( line+=1 ))

        if [[ $key = '' || $key = '#'* ]]; then
            # Skip blank lines & comments
            :
        elif [[ $key =~ ^\[(.+)]$ ]]; then
            # [command]
            command=${BASH_REMATCH[1]}
            debug "  Found [$command] section"
        elif [[ -z $command && $key = 'dir' ]]; then
            # Already handled
            :
        elif [[ -z $command && $key = 'exact' ]]; then
            # exact=true
            if [[ -z $exact ]]; then
                exact=$value
                debug "  Set 'exact' to $exact"
            else
                debug "  Ignoring 'exact=$value' because it has already been set (in the CLI or config file)"
            fi
        elif [[ -z $command ]]; then
            # Unknown keys don't trigger an error for forwards compatibility
            debug "  Unknown key '$key'"
        elif [[ ( $key = 'alias' || $key = 'aliases' ) ]]; then
            # alias=blah
            # aliases=blah1, blah2
            IFS=',' read -ra line_aliases <<< "$value"
            for alias in "${line_aliases[@]}"; do
                alias=${alias// }
                register_alias "$alias" "$command" "$binconfig line $line"
                debug "    Registered alias \"$alias\""
            done
        elif [[ $key = 'help' ]]; then
            # help=Description
            help[$command]=$value
            debug "    Registered help for \"$command\""
        else
            debug "    Unknown key '$key'"
        fi
    done < "$binconfig"
fi

# Default values, if not given at the command line or in the config file
if [[ -z $bin_dirname ]]; then
    bin_dirname=bin
    debug "'dir' defaulted to '$bin_dirname'"
fi

if [[ -z $exact ]]; then
    exact=false
    debug "'exact' defaulted to '$exact'"
fi
