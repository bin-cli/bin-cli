# $BIN_COMMAND is set to the command name
scenario 'The command name is passed in an environment variable'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'Usage: $BIN_COMMAND [...]'
run 'bin sample'
expect-success
expect-output 'Usage: bin sample [...]'

scenario 'The command name passed is the original command, not the unique prefix'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'Usage: $BIN_COMMAND [...]'
run 'bin s'
expect-success
expect-output 'Usage: bin sample [...]'

scenario 'When using an alias, the command name passed is the alias'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'Usage: $BIN_COMMAND [...]'
with-a-symlink "$TEST_ROOT/project/bin/alias" 'sample'
run 'bin alias'
expect-success
expect-output 'Usage: bin alias [...]'

# $0 should be used as a fallback for $BIN_COMMAND
scenario 'It can fall back to the script name when calling the script directly'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'Usage: ${BIN_COMMAND-$0} [...]'
run 'bin/sample'
expect-success
expect-output 'Usage: bin/sample [...]'

# $BIN_EXE is set to the name of the 'bin' executable
scenario 'The `bin` executable name is passed in an environment variable'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'You used: $BIN_EXE'
run 'bin sample'
expect-success
expect-output 'You used: bin'

scenario 'The alternative executable name is passed in an environment variable when passed in explicitly'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'You used: $BIN_EXE'
run 'bin --exe other sample'
expect-success
expect-output 'You used: other'

scenario 'The alternative executable name is passed in an environment variable when symlinked'
with-a-script-with-output "$TEST_ROOT/project/bin/sample" 'You used: $BIN_EXE'
with-a-symlink "$TEST_ROOT/usr/bin/b" 'bin'
# This doesn't work with kcov because $0 is set to 'bin' instead of 'b', though I'm not sure why
run-without-kcov 'b sample'
expect-success
expect-output 'You used: b'
