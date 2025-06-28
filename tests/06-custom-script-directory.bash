# Relative path
scenario 'The script directory can be configured with --dir'
with-a-script-with-output "$TEST_ROOT/project/scripts/hello" 'Hello, World!'
run 'bin --dir scripts hello'
expect-success
expect-output 'Hello, World!'

scenario 'The script directory can be configured with --dir='
with-a-script-with-output "$TEST_ROOT/project/scripts/hello" 'Hello, World!'
run 'bin --dir=scripts hello'
expect-success
expect-output 'Hello, World!'

scenario 'When --dir is a relative path, that directory is not expected to exist'
run 'bin --dir scripts hello'
expect-failure-with-exit-code 127
expect-error "bin: Could not find 'scripts/' directory starting from '$TEST_ROOT/project'"

scenario "When --dir is a relative path, the 'not found' error is adapted accordingly"
with-a-script "$TEST_ROOT/project/scripts/hello"
with-working-directory "$TEST_ROOT/project/root"
run 'bin --dir scripts other'
expect-failure-with-exit-code 127
expect-error "bin: Command 'other' not found in $TEST_ROOT/project/scripts/"

# Absolute path
scenario 'The script directory given by --dir can be an absolute path'
with-a-script-with-output "$TEST_ROOT/project/scripts/dev/hello" 'Hello, World!'
run "bin --dir $TEST_ROOT/project/scripts/dev hello"
expect-success
expect-output 'Hello, World!'

scenario 'When --dir is an absolute path, that directory is expected to exist'
run 'bin --dir /missing hello'
expect-failure-with-exit-code 246
expect-error "bin: Specified directory '/missing/' is missing"

scenario "When --dir is an absolute path, the 'not found' error should be adapted accordingly"
with-a-script "$TEST_ROOT/project/scripts/dev/hello"
run "bin --dir $TEST_ROOT/project/scripts/dev other"
expect-failure-with-exit-code 127
expect-error "bin: Command 'other' not found in $TEST_ROOT/project/scripts/dev/"
