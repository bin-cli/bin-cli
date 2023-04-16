Feature: Config files
  https://github.com/bin-cli/bin#config-files

  @undocumented
  Scenario: Directories above .binconfig are not searched when .binconfig exists
    Given an empty file '/project/root/.binconfig'
    And a script '/project/bin/hello' that outputs 'Hello, World!'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 127
    And there is no output
    And the error is 'bin: Command "hello" not found in /project/root/bin'

  @undocumented
  Scenario: Directories below .binconfig are not searched when .binconfig exists
    Given an empty file '/project/.binconfig'
    And a script '/project/bin/hello' that outputs 'Right'
    And a script '/project/root/bin/hello' that outputs 'Wrong'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Right'
