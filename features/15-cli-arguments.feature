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

  @undocumented
  Scenario Template: The <arg1> and <arg2> arguments are incompatible
    When I run 'bin <arg1> <arg2>'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The '<arg1>' and '<arg2>' arguments are incompatible"

    Examples:
      | arg1         | arg2    |
      | --completion | --print |
