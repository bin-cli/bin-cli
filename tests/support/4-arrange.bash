with-an-empty-directory() {
    ensure-in-test-root "$1"
    mkdir -p "$1"
}

with-a-script() {
    ensure-in-test-root "$1"
    write-file "$1" <<END
#!/bin/sh
echo "This script ($0) should not be executed" >&2
exit 222
END
    chmod +x "$1"
}

with-a-script-with-code() {
    ensure-in-test-root "$1"
    write-file "$1" <<END
#!/bin/sh
$(arg-or-stdin "${2-}")
END
    chmod +x "$1"
}

with-a-script-with-output() {
    ensure-in-test-root "$1"
    write-file "$1" <<END
#!/bin/sh
echo "$(arg-or-stdin "${2-}")"
END
    chmod +x "$1"
}

with-a-file() {
    ensure-in-test-root "$1"
    write-file "$1" "Plain file"
}

with-a-symlink() {
    ensure-in-test-root "$1"
    ensure-parent-directory-exists "$1"
    ln -s "$2" "$1"
}

with-working-directory() {
    ensure-in-test-root "$1"
    mkdir -p "$1"
    working_dir=$1
}
