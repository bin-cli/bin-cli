# Files starting with '.' are ignored
scenario "Scripts starting with '.' are excluded from listings"
with-a-script "$TEST_ROOT/project/bin/visible"
with-a-script "$TEST_ROOT/project/bin/.hidden"
run 'bin'
expect-success
expect-output <<END
Available Commands
bin visible
END

scenario "Scripts starting with '.' cannot be executed"
with-a-script "$TEST_ROOT/project/bin/.hidden"
run 'bin .hidden'
expect-failure-with-exit-code 246
expect-error "bin: Command names may not start with '.'"

scenario "Scripts in directories starting with '.' cannot be executed"
with-a-script "$TEST_ROOT/project/bin/.hidden/child"
run 'bin .hidden child'
expect-failure-with-exit-code 246
expect-error "bin: Command names may not start with '.'"

# Files that are not executable are ignored
scenario 'Files that are not executable are not listed'
with-a-script "$TEST_ROOT/project/bin/executable"
with-a-file "$TEST_ROOT/project/bin/not-executable"
run 'bin'
expect-success
expect-output <<END
Available Commands
bin executable
END

scenario 'Files that are not executable cannot be executed'
with-a-file "$TEST_ROOT/project/bin/not-executable"
run 'bin not-executable'
expect-failure-with-exit-code 126
expect-error "bin: '$TEST_ROOT/project/bin/not-executable' is not executable (chmod +x)"

# Common bin directories are ignored
test-bin-dir-ignored() {
    scenario "$1 is ignored when searching parent directories"
    with-a-script "$TEST_ROOT$1/hello"
    with-working-directory "$TEST_ROOT$2"
    run 'bin hello'
    expect-failure-with-exit-code 127
    expect-error "bin: Could not find 'bin/' directory starting from '$TEST_ROOT$2' (ignored '$TEST_ROOT$1')"
}

test-bin-dir-ignored /bin                  /example
test-bin-dir-ignored /usr/bin              /usr/example
test-bin-dir-ignored /snap/bin             /snap/example
test-bin-dir-ignored /usr/local/bin        /usr/local/bin/example
test-bin-dir-ignored /home/user/bin        /home/user/example
test-bin-dir-ignored /home/user/.local/bin /home/user/.local/example
