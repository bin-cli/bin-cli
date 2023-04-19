action=''
bin_dirname=''
debug=false
exact=''
exe=${0##*/}
error=''
fallback=''
shim=false
version=false

set_action() {
    if [[ -n $action ]]; then
        # Don't exit immediately because --exe may come after the parameter with the error
        set_error "The '--$action' and '--$1' arguments are incompatible"
    fi

    action=$1
}

set_error() {
    # Only display the first error encountered, as if we had exited immediately
    if [[ -n $error ]]; then
        error=$1
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --completion)
            set_action completion
            shift
            ;;
        --debug)
            debug=true
            shift
            ;;
        --dir)
            bin_dirname=$2
            shift 2
            ;;
        --exact)
            exact=true
            shift
            ;;
        --exe)
            exe=$2
            shift 2
            ;;
        --fallback)
            fallback=$2
            shift 2
            ;;
        --prefix)
            exact=false
            shift
            ;;
        --print)
            set_action print
            shift
            ;;
        --shim)
            shim=true
            shift
            ;;
        --version)
            version=true
            shift
            ;;
        --)
            shift
            break
            ;;
        --*)
            fail "Invalid option '$1'"
            ;;
        *) break ;;
    esac
done

if [[ -n $error ]]; then
    fail "$error"
fi
