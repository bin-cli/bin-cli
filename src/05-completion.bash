if [[ $action = 'completion' ]]; then
    if [[ $exe = 'bin' ]]; then
        echo '_bin() { TODO; }' # TODO
        echo 'complete -F _bin bin'
    else
        echo "_bin_$exe() { TODO; }" # TODO
        echo "complete -F _bin_$exe $exe"
    fi
    exit
fi
