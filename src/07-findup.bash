# Helper to search parent directories
findup() (
    while ! test "$@"; do
        if [[ $PWD = '/' ]]; then
            return 1
        fi
        cd ..
    done
    echo "$PWD"
)
