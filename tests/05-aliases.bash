# Symlinks can be used to define aliases
scenario 'An alias can be defined by a symlink'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy" 'Copying to production...'
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
run 'bin publish'
expect-success
expect-output 'Copying to production...'

scenario 'A symlink alias must be relative not absolute'
with-a-script "$TEST_ROOT/project/bin/one"
with-a-symlink "$TEST_ROOT/project/bin/two" "$TEST_ROOT/project/bin/one"
run 'bin'
expect-failure-with-exit-code 246
expect-error "bin: The symlink '$TEST_ROOT/project/bin/two' must use a relative path not absolute ('$TEST_ROOT/project/bin/one')"

scenario 'Broken symlinks are ignored'
with-a-symlink "$TEST_ROOT/project/bin/broken" 'missing'
run 'bin'
expect-success
expect-output <<END
Available Commands
None found
END

# Aliases are displayed in the command listing
scenario 'Aliases are displayed in the command listing'
with-a-script "$TEST_ROOT/project/bin/artisan"
with-a-script "$TEST_ROOT/project/bin/deploy"
with-a-symlink "$TEST_ROOT/project/bin/art" 'artisan'
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
with-a-symlink "$TEST_ROOT/project/bin/push" 'deploy'
run 'bin'
expect-success
expect-output <<END
Available Commands
bin artisan (alias: art)
bin deploy (aliases: publish, push)
END

# Aliases work for directories
scenario 'Aliases can be defined for directories and are inherited by all subcommands'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy/live" 'Copying to production...'
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
run 'bin publish live'
expect-success
expect-output 'Copying to production...'

scenario 'Aliases for directories are displayed in the command listing'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
run 'bin'
expect-success
expect-output <<END
Available Commands
bin deploy ... (alias: publish)
END

scenario 'If the alias is used for the parent command, it is used when listing subcommands'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
run 'bin publish'
expect-success
expect-output <<END
Available Subcommands
bin publish live
bin publish staging
END

# Aliases are considered by unique prefix matching
scenario 'Aliases are subject to unique prefix matching'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy" 'Copying to production...'
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
run 'bin pub'
expect-success
expect-output 'Copying to production...'

scenario 'Multiple aliases for the same command are treated as one match'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy" 'Copying to production...'
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
with-a-symlink "$TEST_ROOT/project/bin/push" 'deploy'
run 'bin pu'
expect-success
expect-output 'Copying to production...'

scenario 'Unique prefix matching works for aliases pointing to subcommands'
with-a-script-with-output "$TEST_ROOT/project/bin/deploy/live" 'Copying to production...'
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy/live'
run 'bin pub'
expect-success
expect-output 'Copying to production...'
