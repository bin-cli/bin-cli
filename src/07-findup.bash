findup() (
    while true; do
        if test "$@"; then
            debug "  $PWD - found"
            echo "$PWD"
            return 0
        else
            debug "  $PWD - not found"
        fi

        if [[ $PWD = '/' ]]; then
            return 1
        fi

        cd ..

    done
)
