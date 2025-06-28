# Generate completion script
scenario 'A tab completion script is available for Bash'
run 'bin --completion'
expect-success
expect-output 'complete -C "bin --complete-bash" -o default bin'

# Basic success cases
scenario 'Tab completion works for simple commands'
with-a-script "$TEST_ROOT/project/bin/hello"
tab-complete 'bin h'
expect-success
expect-output 'hello'

scenario 'Tab completion works for multiple matching commands'
with-a-script "$TEST_ROOT/project/bin/hello"
with-a-script "$TEST_ROOT/project/bin/hi"
tab-complete 'bin h'
expect-success
expect-output <<END
hello
hi
END

# Subcommands
scenario 'Tab completion works for directories with partial match'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
tab-complete 'bin d'
expect-success
expect-output <<END
deploy
END

scenario 'Tab completion works for directories with full match'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
tab-complete 'bin deploy'
expect-success
expect-output <<END
deploy
END

scenario 'Tab completion works for subcommands with blank parameter'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
tab-complete 'bin deploy '
expect-success
expect-output <<END
live
staging
END

scenario 'Tab completion works for subcommands with partial match'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
tab-complete 'bin deploy l'
expect-success
expect-output <<END
live
END

scenario 'Tab completion works for subcommands with full match'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
tab-complete 'bin deploy live'
expect-success
expect-output <<END
live
END

# Special case just to be sure
scenario 'Tab completion works with the cursor in the middle of the string'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
with-a-script "$TEST_ROOT/project/bin/deploy/staging"
tab-complete 'bin d|ep ignored'
expect-success
expect-output <<END
deploy
END

# Failure cases
scenario 'Nothing is output for parameters after the last command'
with-a-script "$TEST_ROOT/project/bin/deploy/live"
tab-complete 'bin deploy live '
expect-success
expect-no-output

scenario 'Nothing is output if a parameter before the last one is ambiguous'
with-a-script "$TEST_ROOT/project/bin/hello/world"
with-a-script "$TEST_ROOT/project/bin/hi/world"
tab-complete 'bin h wor'
expect-success
expect-no-output

# Command aliases
scenario 'Tab completion works for aliases'
with-a-script "$TEST_ROOT/project/bin/deploy"
with-a-script "$TEST_ROOT/project/bin/artisan"
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
with-a-symlink "$TEST_ROOT/project/bin/art" 'artisan'
tab-complete 'bin p'
expect-success
expect-output <<END
publish
END

scenario 'If both the command and the alias match, only the command is listed in tab completion'
with-a-script "$TEST_ROOT/project/bin/deploy"
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
tab-complete 'bin '
expect-success
expect-output <<END
deploy
END

scenario 'If multiple aliases for the same command match, only one is returned in tab completion'
with-a-script "$TEST_ROOT/project/bin/deploy"
with-a-symlink "$TEST_ROOT/project/bin/publish" 'deploy'
with-a-symlink "$TEST_ROOT/project/bin/push" 'deploy'
tab-complete 'bin p'
expect-success
expect-output <<END
publish
END

# Script aliases
scenario 'The executable name for tab completion can be overridden with --exe'
run 'bin --completion --exe b'
expect-success
expect-output <<END
complete -C "bin --exe 'b' --complete-bash" -o default b
END

scenario 'Tab completion supports custom directories'
run 'bin --completion --exe scr --dir scripts'
expect-success
expect-output <<END
complete -C "bin --exe 'scr' --dir 'scripts' --complete-bash" -o default scr
END

scenario 'Tab completion works for custom directories'
with-a-script "$TEST_ROOT/project/scripts/right"
with-a-script "$TEST_ROOT/project/bin/wrong"
tab-complete-with-arguments "--dir 'scripts' --exe 'scr'" 'scr '
expect-success
expect-output 'right'

# Exclusions
scenario 'Scripts starting with '.' are excluded from tab completion'
with-a-script "$TEST_ROOT/project/bin/visible"
with-a-script "$TEST_ROOT/project/bin/.hidden"
tab-complete 'bin '
expect-success
expect-output 'visible'

scenario 'Scripts starting with '.' cannot be tab completed'
with-a-script "$TEST_ROOT/project/bin/.hidden"
tab-complete 'bin .h'
expect-success
expect-no-output

scenario 'Directories starting with '.' cannot be tab completed'
with-a-script "$TEST_ROOT/project/bin/.hidden/command"
tab-complete 'bin .h'
expect-success
expect-no-output

scenario 'Files that are not executable are not tab completed'
with-a-script "$TEST_ROOT/project/bin/executable"
with-a-file "$TEST_ROOT/project/bin/not-executable"
tab-complete 'bin '
expect-success
expect-output 'executable'

test-bin-dir-ignored-when-tab-completing() {
    scenario "$1 is ignored when tab completing"
    with-a-script "$TEST_ROOT$1/hello"
    with-working-directory "$TEST_ROOT$2"
    tab-complete 'bin h'
    expect-success
    expect-no-output
}

test-bin-dir-ignored-when-tab-completing /bin           /example
test-bin-dir-ignored-when-tab-completing /usr/bin       /usr/example
test-bin-dir-ignored-when-tab-completing /snap/bin      /snap/example
test-bin-dir-ignored-when-tab-completing /usr/local/bin /usr/local/bin/example
test-bin-dir-ignored-when-tab-completing /home/user/bin /home/user/example

# Options
test-tab-completion-after-option() {
    scenario "Tab completion works after '$1'"
    with-a-script "$TEST_ROOT/project/bin/hello"
    tab-complete "bin $1 h"
    expect-success
    expect-output 'hello'
}

test-tab-completion-after-option '--exe something'
test-tab-completion-after-option '--exe=something'
test-tab-completion-after-option '--'

test-tab-completion-with-dir() {
    scenario "Tab completion works after '$1' and changes the directory"
    with-a-script "$TEST_ROOT/project/scripts/right"
    with-a-script "$TEST_ROOT/project/bin/wrong"
    tab-complete "bin $1 "
    expect-success
    expect-output 'right'
}

test-tab-completion-with-dir '--dir scripts'
test-tab-completion-with-dir '--dir=scripts'
test-tab-completion-with-dir "--dir $TEST_ROOT/project/scripts"
test-tab-completion-with-dir "--dir=$TEST_ROOT/project/scripts"

test-tab-completion-after-option-aborts() {
    scenario "Tab completion aborts after '$1'"
    with-a-script "$TEST_ROOT/project/bin/hello"
    tab-complete "bin $1 h"
    expect-success
    expect-no-output
}

test-tab-completion-after-option-aborts --complete-bash
test-tab-completion-after-option-aborts --completion
test-tab-completion-after-option-aborts -h
test-tab-completion-after-option-aborts --help
test-tab-completion-after-option-aborts --invalid
test-tab-completion-after-option-aborts -v
test-tab-completion-after-option-aborts --version

scenario 'Option names can be tab-completed (all)'
tab-complete 'bin -'
expect-success
expect-output <<END
--completion
--dir
--exe
--help
-h
--version
-v
--
END

scenario 'Option names can be tab-completed (long options)'
tab-complete 'bin --'
expect-success
expect-output <<END
--completion
--dir
--exe
--help
--version
--
END

scenario 'Option names can be tab-completed (partial match)'
tab-complete 'bin --e'
expect-success
expect-output <<END
--exe
END

scenario "Option names are not tab-completed after '--'"
tab-complete 'bin -- -'
expect-success
expect-no-output
