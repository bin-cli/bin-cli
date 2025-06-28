scenario 'Code and tests must be high quality'
expect-complete-code-coverage
expect-no-shellcheck-errors "$TEST_DIST/bin"
expect-max-file-size "$TEST_DIST/bin" $((100 * 1024))
