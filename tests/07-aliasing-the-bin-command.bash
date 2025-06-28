# alias b='bin ...'
scenario 'The executable name can be overridden with --exe'
with-a-script "$TEST_ROOT/project/bin/hello"
run 'bin --exe b'
expect-success
expect-output <<END
Available Commands
b hello
END

scenario 'The executable name can be overridden with --exe='
with-a-script "$TEST_ROOT/project/bin/hello"
run 'bin --exe=b'
expect-success
expect-output <<END
Available Commands
b hello
END

# ln -s bin b
scenario 'The correct executable name is output when using a symlink'
with-a-symlink "$TEST_ROOT/usr/bin/b" 'bin'
with-a-script "$TEST_ROOT/project/bin/hello"
# This doesn't work with kcov because $0 is set to 'bin' instead of 'b', though I'm not sure why
run-without-kcov 'b'
expect-success
expect-output <<END
Available Commands
b hello
END
