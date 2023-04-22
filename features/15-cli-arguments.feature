Feature: CLI arguments
  https://github.com/bin-cli/bin#cli-reference

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
    And the output contains 'Bin version '

  Scenario: The version number is displayed when using -v
    When I run 'bin -v'
    Then it is successful
    And the output contains 'Bin version '

  Scenario: '--' can be placed before executable names
    Given a script '/project/bin/--help' that outputs 'Help'
    When I run 'bin -- --help'
    Then it is successful
    And the output is 'Help'

  Scenario: An invalid argument causes an error
    When I run 'bin --invalid'
    Then the exit code is 246
    And there is no output
    And the error is "bin: Invalid option '--invalid'"

  @undocumented
  Scenario Template: The <arg1> and <arg2> arguments are incompatible
    When I run 'bin <arg1> <arg2>'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The '<arg1>' and '<arg2>' arguments are incompatible"

    # I haven't bothered to list all combinations here, just a few combinations
    Examples:
      | arg1         | arg2    |
      | --completion | --help |
      | --completion | --print |
      | --help       | --version |
