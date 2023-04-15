Feature: Custom script directory
  https://github.com/bin-cli/bin#custom-script-directory

  Scenario: The script directory can be overridden in .binconfig in the root directory
    Given a file '/project/.binconfig' with content 'root=scripts'
    And a script '/project/scripts/test' that outputs 'Right'
    And a script '/project/bin/test' that outputs 'Wrong'
    When I run 'bin test'
    Then it is successful
    And the output is 'Right'

  Scenario: Directories above .binconfig are not searched when root is specified in .binconfig
    Given a file '/project/root/.binconfig' with content 'root=scripts'
    And a script '/project/scripts/hello'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 127
    And there is no output
    And the error is "Executable 'hello' not found in /project/scripts"

  Scenario: Directories below .binconfig are not searched when root is specified in .binconfig
    Given a file '/project/.binconfig' with content 'root=scripts'
    And a script '/project/scripts/test' that outputs 'Right'
    And a script '/project/root/scripts/test' that outputs 'Wrong'
    And the working directory is '/project/root'
    When I run 'bin test'
    Then it is successful
    And the output is 'Right'

  Scenario: Scripts can be in the project root
    Given a file '/project/.binconfig' with content 'root=.'
    And a script '/project/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Subcommands are not supported in the project root
    Given a file '/project/.binconfig' with content 'root=.'
    And a script '/project/hello/world'
    When I run 'bin hello world'
    Then the exit code is 246
    And there is no output
    And the error is "Subcommands are not supported with the config option 'root=.'"

  Scenario: The root directory can be configured with --root
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin --root scripts hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Setting the root directory with --root overrides .binconfig
    Given a script '/project/right/script' that outputs 'Right'
    And a script '/project/root/wrong/script' that outputs 'Wrong'
    And a file '/project/root/.binconfig' with content 'root=wrong'
    And the working directory is '/project/root'
    When I run 'bin --root right script'
    Then it is successful
    And the output is 'Right'

  Scenario: The root directory can be an absolute path when given with --root
    Given a script '/project/scripts/dev/hello' that outputs 'Hello, World!'
    When I run 'bin --root /project/scripts/dev hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Tab completion supports custom directories
    When I run 'bin --completion --exe scr --root scripts'
    Then it is successful
    And the output contains '_bin_scr()'
    And the output contains '--root scripts'
    And the output contains 'complete -F _bin_scr scr'
