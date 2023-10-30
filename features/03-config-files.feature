Feature: Config files
  https://github.com/bin-cli/bin-cli#config-files

  Scenario: Directories above .binconfig are not searched when .binconfig exists
    Given an empty file '{ROOT}/project/root/.binconfig'
    And a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin hello'
    Then it fails with exit code 127
    And the error is "bin: Command 'hello' not found in {ROOT}/project/root/bin/ or {ROOT}/project/root/.binconfig"

  Scenario: Directories below .binconfig are not searched when .binconfig exists
    Given an empty file '{ROOT}/project/.binconfig'
    And a script '{ROOT}/project/bin/hello' that outputs 'Right'
    And a script '{ROOT}/project/root/bin/hello' that outputs 'Wrong'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Right'

  Scenario: Both '#' and ';' denote comments
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      ; Comment 1
      # Comment 2

      dir=scripts
      """
    And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Unknown keys are ignored for forwards compatibility
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      ignored=global
      dir=scripts

      [command]
      ignored=command
      """
    And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: A warning is displayed if .binconfig contains a command that doesn't exist
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [my-command]
      help=Description of command
      """
    And a script '{ROOT}/project/bin/sample'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin sample

      Warning: The following commands listed in {ROOT}/project/.binconfig do not exist:
      [my-command]
      """
