scenario "If you run 'bin' on its own, it will list all available scripts"
with-a-script "$TEST_ROOT/project/bin/hello"
with-a-script "$TEST_ROOT/project/bin/another"
run 'bin'
expect-success
expect-output <<END
Available Commands
bin another
bin hello
END

scenario 'If there are no scripts, it outputs "None found"'
with-an-empty-directory "$TEST_ROOT/project/bin"
run 'bin'
expect-success
expect-output <<END
Available Commands
None found
END
