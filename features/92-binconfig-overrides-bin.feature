Feature: .binconfig overrides bin/
  This isn't explained, but (1) it's consistent with how it works when 'dir='
  is specified, and (2) .binconfig is only supposed to be in the root directory
  (or the bin/ directory).

  Scenario: Directories above .binconfig are not searched when .binconfig exists
    Given an empty file '/project/root/.binconfig'
    And a script '/project/bin/hello' that outputs 'Hello, World!'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 127
    And there is no output
    And the error is "bin: Executable 'hello' not found in /project/root/bin"

  Scenario: Directories below .binconfig are not searched when .binconfig exists
    Given an empty file '/project/.binconfig'
    And a script '/project/bin/hello' that outputs 'Right'
    And a script '/project/root/bin/hello' that outputs 'Wrong'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Right'
