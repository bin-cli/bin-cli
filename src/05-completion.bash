if [[ $action = 'completion' ]]; then
    if [[ $exe = 'bin' ]]; then
        echo '_bin() { TODO; }' # TODO
        echo 'complete -F _bin bin'
    else
        echo "_bin_$exe() { TODO --dir ${bin_dirname-bin}; }" # TODO
        echo "complete -F _bin_$exe $exe"
    fi
    exit
fi
