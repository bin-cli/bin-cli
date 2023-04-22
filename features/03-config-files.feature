Feature: Config files
  https://github.com/bin-cli/bin#config-files

  @undocumented
  Scenario: Directories above .binconfig are not searched when .binconfig exists
    Given an empty file '/project/root/.binconfig'
    And a script '/project/bin/hello' that outputs 'Hello, World!'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then it fails with exit code 246
    And the error is "bin: Found '/project/root/.binconfig', but '/project/root/bin/' directory is missing"

  @undocumented
  Scenario: Directories below .binconfig are not searched when .binconfig exists
    Given an empty file '/project/.binconfig'
    And a script '/project/bin/hello' that outputs 'Right'
    And a script '/project/root/bin/hello' that outputs 'Wrong'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Right'

  @undocumented
  Scenario: Both '#' and ';' denote comments
    Given a file '/project/.binconfig' with content:
      """
      ; Comment 1
      # Comment 2

      dir=scripts
      """
    And a script '/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: Unknown keys are ignored for forwards compatibility
    Given a file '/project/.binconfig' with content:
      """
      ignored=global
      dir=scripts

      [command]
      ignored=command
      """
    And a script '/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'
