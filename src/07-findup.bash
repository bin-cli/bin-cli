findup() (
    while true; do
        if [[ $PWD = '/' ]]; then
            debug "  $PWD - ignored"
            return 1
        elif test "$@"; then
            debug "  $PWD - found"
            echo "$PWD"
            return 0
        else
            debug "  $PWD - not found"
            cd ..
        fi
    done
)
