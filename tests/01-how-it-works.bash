# bin/ in the current directory
scenario 'A script that is in the bin/ directory can be run without parameters'
with-a-script-with-output "$TEST_ROOT/project/bin/hello" 'Hello, ${1:-World}! [$#]'
run 'bin hello'
expect-success
expect-output 'Hello, World! [0]'

scenario 'Scripts can be run with one parameter passed through'
with-a-script-with-output "$TEST_ROOT/project/bin/hello" 'Hello, ${1:-World}! [$#]'
run 'bin hello everybody'
expect-success
expect-output 'Hello, everybody! [1]'

scenario 'Scripts can be run with multiple parameters passed through'
with-a-script-with-output "$TEST_ROOT/project/bin/hello" 'Hello, ${1:-World}! [$#]'
run 'bin hello everybody two three four'
expect-success
expect-output 'Hello, everybody! [4]'

scenario 'The exit code from the command is passed through'
with-a-script-with-code "$TEST_ROOT/project/bin/fail" 'exit 123'
run 'bin fail'
expect-failure-with-exit-code 123
expect-no-error-messages

scenario 'The error from the command is passed through'
with-a-script-with-code "$TEST_ROOT/project/bin/warn" 'echo "Something is wrong" >&2'
run 'bin warn'
expect-exit-code 0
expect-no-output
expect-error 'Something is wrong'

scenario "An error is given if the command doesn't exist"
with-a-script "$TEST_ROOT/project/bin/hello"
with-working-directory "$TEST_ROOT/project/root"
run 'bin other'
expect-failure-with-exit-code 127
expect-error "bin: Command 'other' not found in $TEST_ROOT/project/bin/"

# bin/ in a parent directory
scenario 'Scripts can be run when in a subdirectory'
with-a-script-with-output "$TEST_ROOT/project/bin/hello" 'Hello, World!'
with-working-directory "$TEST_ROOT/project/subdirectory"
run 'bin hello'
expect-success
expect-output 'Hello, World!'

scenario 'Scripts can be run when in a sub-subdirectory'
with-a-script-with-output "$TEST_ROOT/project/bin/hello" 'Hello, World!'
with-working-directory "$TEST_ROOT/project/subdirectory/sub-subdirectory"
run 'bin hello'
expect-success
expect-output 'Hello, World!'

scenario 'If no bin/ directory is found, an error is displayed'
run 'bin'
expect-failure-with-exit-code 127
expect-error "bin: Could not find 'bin/' directory starting from '$TEST_ROOT/project'"
