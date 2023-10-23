Feature: CLI arguments
  https://github.com/bin-cli/bin-cli#cli-reference

  @auto-update-cli-reference-docs
  Scenario: The help message is displayed when using --help
    When I run 'bin --help'
    Then it is successful
    And the output contains 'Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]'

  Scenario: The help message is displayed when using -h
    When I run 'bin -h'
    Then it is successful
    And the output contains 'Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]'

  Scenario: The version number is displayed when using --version
    When I run 'bin --version'
    Then it is successful
    And the output is 'Bin CLI v1.2.3-dev'

  Scenario: The version number is displayed when using -v
    When I run 'bin -v'
    Then it is successful
    And the output is 'Bin CLI v1.2.3-dev'

  Scenario: '--' can be placed before executable names
    Given a script '{ROOT}/project/bin/--help' that outputs 'Help'
    When I run 'bin -- --help'
    Then it is successful
    And the output is 'Help'

  Scenario: An invalid argument causes an error
    When I run 'bin --invalid'
    Then it fails with exit code 246
    And the error is "bin: Invalid option '--invalid'"

  @undocumented
  Scenario Template: A helpful message is displayed when running the '<command>' command if it is not defined
    Given a script '{ROOT}/project/bin/dummy'
    When I run 'bin <command>'
    Then it fails with exit code 127
    And the error is:
      """
      bin: Command '<command>' not found in {ROOT}/project/bin or {ROOT}/project/.binconfig
           Perhaps you meant to run 'bin --<command>'?
      """

    Examples:
      | command    |
      | completion |
      | create     |
      | edit       |
      | help       |
      | version    |

  @undocumented
  Scenario Template: The <arg1> and <arg2> arguments are incompatible
    When I run 'bin <arg1> <arg2>'
    Then it fails with exit code 246
    And the error is "bin: The '<arg1>' and '<arg2>' arguments are incompatible"

    # I haven't bothered to list all combinations here, just a few combinations
    Scenarios:
      | arg1         | arg2      |
      | --completion | --help    |
      | --completion | --print   |
      | --help       | --version |
