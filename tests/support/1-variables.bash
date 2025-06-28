# ANSI colours
RESET=$'\e[0m'
BOLD=$'\e[1m'
UNDERLINE=$'\e[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
GREY=$'\e[90m'
LRED=$'\e[91m'
LGREEN=$'\e[92m'
LYELLOW=$'\e[93m'
LBLUE=$'\e[94m'
LMAGENTA=$'\e[95m'
LCYAN=$'\e[96m'
LWHITE=$'\e[97m'

# Icons
SCENARIO_ICON=$(printf '%s\u25BA%s' "$LBLUE" "$RESET")
SUCCESS_ICON=$(printf '%s\u2713%s' "$LGREEN" "$RESET")
SKIPPED_ICON=$(printf '%s?%s' "$LYELLOW" "$RESET")
FAIL_ICON=$(printf '%s\u2718%s' "$LRED" "$RESET")

# Paths ($PWD should be the repo root)
TEST_DIST="$PWD/dist";

if [[ -z ${TEST_TEMP-} ]]; then
    TEST_TEMP="$PWD/temp";
fi

TEST_COVERAGE="$TEST_TEMP/coverage";
TEST_ROOT="$TEST_TEMP/root";

DEBUG_FILE="$TEST_TEMP/debug.txt"
ERROR_FILE="$TEST_TEMP/error.txt"

# Variables used in tests
test_file='FILENAME NOT SET'
scenario_name='SCENARIO NOT NAMED'
working_dir='/placeholder'
command=''
exit_code=999
output=''
error=''
debug=''
tests_skipped=0
