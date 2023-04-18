bin_dirname='bin'

binconfig=''
if root=$(findup -f .binconfig); then
    binconfig="$root/.binconfig"
fi

declare -A help

if [[ -n $binconfig ]]; then
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
        elif [[ -z $command && $key = 'dir' ]]; then
            # dir=scripts
            bin_dirname=$value
        elif [[ -z $command && $key = 'exact' && -z $exact ]]; then
            # exact=true
            exact=$value
        elif [[ -n $command && ( $key = 'alias' || $key = 'aliases' ) ]]; then
            # alias=blah
            # aliases=blah1, blah2
            IFS=',' read -ra line_aliases <<< "$value"
            for alias in "${line_aliases[@]}"; do
                alias=${alias// }
                register_alias "$alias" "$command" "$binconfig line $line"
            done
        elif [[ -n $command && $key = 'help' ]]; then
            # help=Description
            help[$command]=$value
        fi
    done < "$binconfig"
fi

if [[ -z $exact ]]; then
    exact=false
fi
