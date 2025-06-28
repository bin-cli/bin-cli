# Missing values
test-missing-value() {
    scenario "The '$1${2-}' option requires a value"
    run "bin $1${2-}"
    expect-failure-with-exit-code 246
    expect-error "bin: The '$1' option requires a value"
}

test-missing-value --dir
test-missing-value --dir =
test-missing-value --exe
test-missing-value --exe =

# Spaces are allowed in command names, though not recommended
scenario 'Spaces in command names are allowed'
with-a-script-with-output "$TEST_ROOT/project/bin/hello world" 'Hello, World!'
run 'bin "hello world"'
expect-success
expect-output 'Hello, World!'

scenario 'Commands containing spaces are quoted in listings'
with-a-script "$TEST_ROOT/project/bin/hello world"
run 'bin'
expect-success
expect-output <<END
Available Commands
bin hello\ world
END

scenario 'Spaces in directory names are allowed'
with-a-script-with-output "$TEST_ROOT/project/bin/my directory/hello world" 'Hello, World!'
run 'bin "my directory" "hello world"'
expect-success
expect-output 'Hello, World!'

scenario 'Commands containing spaces are quoted in listings'
with-a-script "$TEST_ROOT/project/bin/my directory/hello world"
run 'bin "my directory"'
expect-success
expect-output <<END
Available Subcommands
bin my\ directory hello\ world
END
