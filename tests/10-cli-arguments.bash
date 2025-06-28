scenario "'--' can be placed before executable names"
with-a-script-with-output "$TEST_ROOT/project/bin/--help" 'Help'
run 'bin -- --help'
expect-success
expect-output 'Help'

scenario 'An invalid argument causes an error'
run 'bin --invalid'
expect-failure-with-exit-code 246
expect-error "bin: Invalid option '--invalid'"

test-command-suggestion() {
    scenario "A helpful message is displayed when running the '$1' command if it is not defined"
    with-a-script "$TEST_ROOT/project/bin/dummy"
    run "bin $1"
    expect-failure-with-exit-code 127
    expect-error <<END
bin: Command '$1' not found in $TEST_ROOT/project/bin/
Perhaps you meant to run 'bin --$1'?
END
}

test-command-suggestion completion
test-command-suggestion help
test-command-suggestion version

test-incompatible-arguments() {
    scenario "The $1 and $2 arguments are incompatible"
    run "bin $1 $2"
    expect-failure-with-exit-code 246
    expect-error "bin: The '$1' and '$2' arguments are incompatible"
}

test-incompatible-arguments --completion --help
test-incompatible-arguments -h           --version
test-incompatible-arguments --help       -v

scenario "Specifying the same argument more than once doesn't cause an error"
with-a-script "$TEST_ROOT/usr/bin/editor"
run 'bin -h -h --help --help'
expect-success

# Help
scenario 'The help message is displayed when using --help'
run 'bin --help'
expect-success
expect-output-contains 'Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]'

scenario 'The help message is displayed when using -h'
run 'bin -h'
expect-success
expect-output-contains 'Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]'

# Version
scenario 'The version number is displayed when using --version'
run 'bin --version'
expect-success
expect-output 'Bin CLI v1.2.3-dev'

scenario 'The version number is displayed when using -v'
run 'bin -v'
expect-success
expect-output 'Bin CLI v1.2.3-dev'
