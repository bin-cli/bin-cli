Feature: Getting the script name
  https://github.com/bin-cli/bin#getting-the-script-name

  Scenario: The command name is passed in an environment variable
    Given a script '/project/bin/sample' that outputs "Usage: ${BIN_COMMAND:-$0} [...]"
    When I run 'bin sample -h'
    Then it is successful
    And the output is 'Usage: bin sample [...]'

  # This is to check the README is accurate, rather than testing Bin itself
  Scenario: It falls back to the script name when calling the script directly
    Given a script '/project/bin/sample' that outputs "Usage: ${BIN_COMMAND:-$0} [...]"
    When I run 'bin/sample -h'
    Then it is successful
    And the output is 'Usage: bin/sample [...]'
