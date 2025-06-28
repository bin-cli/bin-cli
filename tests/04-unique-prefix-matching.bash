scenario 'When entering a unique prefix, the matching command is executed'
with-a-script-with-output "$TEST_ROOT/project/bin/hello" 'Hello, World!'
run 'bin h'
expect-success
expect-output 'Hello, World!'

scenario 'When entering an ambiguous prefix, the matches are listed'
with-a-script "$TEST_ROOT/project/bin/hello"
with-a-script "$TEST_ROOT/project/bin/hi"
with-a-script "$TEST_ROOT/project/bin/another"
run 'bin h'
expect-success
expect-output <<END
Matching Commands
bin hello
bin hi
END

scenario 'Unique prefix matching works for directories as well as commands'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy/live" 'Copying to production...'
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
run 'bin d l'
expect-success
expect-output 'Copying to production...'

# In the old implementation, there was a risk that it was executed too soon because "d" is a unique prefix
# In the new implementation, this is unlikely, but I've kept the test anyway
scenario 'Unique prefix matching works correctly with a single script in the directory'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy/live" 'deploying with $1'
run 'bin d l --force'
expect-success
expect-output 'deploying with --force'

scenario 'Unique prefix matching works for directories when there are multiple matches'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
with-a-script "$TEST_ROOT/project/bin/dump/config"
with-a-script "$TEST_ROOT/project/bin/do-something"
run 'bin d'
expect-success
expect-output <<END
Matching Commands
bin deploy ...
bin do-something
bin dump ...
END
