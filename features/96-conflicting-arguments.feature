Feature: Conflicting arguments

  Scenario Template: The <arg1> and <arg2> arguments are incompatible
    When I run 'bin <arg1> <arg2>'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The '<arg1>' and '<arg2>' arguments are incompatible"

    Examples:
      | arg1         | arg2    |
      | --completion | --print |
