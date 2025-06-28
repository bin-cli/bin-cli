scenario 'Subcommands are created by scripts in subdirectories'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy/live" 'Copying to production...'
run 'bin deploy live'
expect-success
expect-output 'Copying to production...'

scenario 'Subcommands are not listed when Bin is run without parameters'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
with-a-script "$TEST_ROOT/project/bin/another"
run 'bin'
expect-success
expect-output <<END
Available Commands
bin another
bin deploy ...
END

scenario 'Subcommands are listed when Bin is run with the directory name'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
with-a-script "$TEST_ROOT/project/bin/another"
run 'bin deploy'
expect-success
expect-output <<END
Available Subcommands
bin deploy live
bin deploy staging
END
