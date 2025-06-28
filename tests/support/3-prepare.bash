rm -rf "$TEST_TEMP"
mkdir -p "$TEST_COVERAGE"

scenario() {
    echo -n "$SCENARIO_ICON"

    scenario_name=$1

    # Reset the test directory
    rm -rf "$TEST_ROOT"

    mkdir -p \
        "$TEST_ROOT/project" \
        "$TEST_ROOT/usr/bin"

    # Symlink the executables we need, since we won't be using the global $PATH
    executables=(
        bash # bash
        basename # coreutils
        env # coreutils
        readlink # coreutils
        sort # coreutils
    )

    for executable in "${executables[@]}"; do
        ln -s "$(which "$executable")" "$TEST_ROOT/usr/bin/$executable"
    done

    # And the test version of 'bin' itself
    ln -s "$TEST_DIST/bin" "$TEST_ROOT/usr/bin/bin"

    # On MSYS2 / Git for Windows, we also need the DLLs - otherwise it fails with errors like:
    # bash: error while loading shared libraries: ?: cannot open shared object file: No such file or directory
    for dll in /usr/bin/msys-*.dll; do
        ln -s "$dll" "$TEST_ROOT/usr/bin/"
    done

    # Reset other variables
    working_dir="$TEST_ROOT/project"
    command=''
    exit_code=999
    output=''
    error=''
    debug=''
}
