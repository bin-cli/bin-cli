{
    # Replace the version number
    if ($0 ~ /^readonly VERSION=.*/) {
        print "readonly VERSION='" version "'"
    }

    # Keep the shebang
    else if ($0 ~ /^#!/) {
        print
    }

    # Keep the copyright notice and link to the source
    else if ($0 ~ /^#.{78}#$/) {
        print
    }

    # Remove all comments (except Kcov and ShellCheck directives) to keep
    # the script size to a minimum (reduces it from 49K to 36K at time
    # of writing), but keep the same line numbers for easier debugging
    else if ($0 ~ /^\s*#/ && $0 !~ /# (kcov-|shellcheck )/) {
        if (minified_comment_output) {
            print ""
        } else {
            # Replace the first one with an explanation
            print "# This is the minified version with comments and indentation removed"
            minified_comment_output = 1
        }
    }

    # Remove indentation (reduces size further, from 36K to 29K)
    else {
        sub(/^ +/, "", $0)
        print
    }
}
