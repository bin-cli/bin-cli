Feature: Getting the script name
  https://github.com/bin-cli/bin#getting-the-script-name

  Background:
    Given a script '/project/bin/sample' with content:
      """sh
      #!/usr/bin/sh
      echo "Usage: ${BIN_COMMAND:-$0} [...]"
      """

  Scenario: The command name is passed in an environment variable
    When I run 'bin sample -h'
    Then it is successful
    And the output is 'Usage: bin sample [...]'

  # This is to check the README is accurate, rather than testing Bin itself
  Scenario: It falls back to the script name when calling the script directly
    When I run 'bin/sample -h'
    Then it is successful
    And the output is 'Usage: bin/sample [...]'
