Feature: Custom script directory
  https://github.com/bin-cli/bin#custom-script-directory

  Scenario: The script directory can be overridden in .binconfig
    Given a file '/project/.binconfig' with content 'dir=scripts'
    And a script '/project/scripts/test' that outputs 'Right'
    And a script '/project/bin/test' that outputs 'Wrong'
    When I run 'bin test'
    Then it is successful
    And the output is 'Right'

  Scenario: Directories above .binconfig are not searched when root is specified in .binconfig
    Given a file '/project/root/.binconfig' with content 'dir=scripts'
    And a script '/project/scripts/hello'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: Found '/project/root/.binconfig', but '/project/root/scripts/' directory is missing"

  Scenario: Directories below .binconfig are not searched when root is specified in .binconfig
    Given a file '/project/.binconfig' with content 'dir=scripts'
    And a script '/project/scripts/test' that outputs 'Right'
    And a script '/project/root/scripts/test' that outputs 'Wrong'
    And the working directory is '/project/root'
    When I run 'bin test'
    Then it is successful
    And the output is 'Right'

  Scenario: Scripts can be in the project root
    Given a file '/project/.binconfig' with content 'dir=.'
    And a script '/project/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Subcommands are not supported in the project root
    Given a file '/project/.binconfig' with content 'dir=.'
    And a script '/project/hello/world'
    When I run 'bin hello world'
    Then the exit code is 246
    And there is no output
    And the error is "bin: Subcommands are not supported with the config option 'dir=.'"

  Scenario: The root directory can be configured with --dir
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin --dir scripts hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Setting the root directory with --dir overrides .binconfig
    Given a script '/project/right/script' that outputs 'Right'
    And a script '/project/root/wrong/script' that outputs 'Wrong'
    And a file '/project/root/.binconfig' with content 'dir=wrong'
    And the working directory is '/project/root'
    When I run 'bin --dir right script'
    Then it is successful
    And the output is 'Right'

  Scenario: The root directory can be an absolute path when given with --dir
    Given a script '/project/scripts/dev/hello' that outputs 'Hello, World!'
    When I run 'bin --dir /project/scripts/dev hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Tab completion supports custom directories
    When I run 'bin --completion --exe scr --dir scripts'
    Then it is successful
    And the output contains '_bin_scr()'
    And the output contains '--dir scripts'
    And the output contains 'complete -F _bin_scr scr'

  @undocumented
  Scenario: The 'root' option cannot be an absolute path when set in .binconfig
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    And a file '/project/.binconfig' with content 'dir=/project/scripts'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The option 'dir' cannot be an absolute path in /project/.binconfig line 1"

  @undocumented
  Scenario: The 'root' option cannot point to a parent directory in .binconfig
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    And a file '/project/root/.binconfig' with content 'dir=../scripts'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The option 'dir' cannot point to a directory outside /project/root in /project/root/.binconfig line 1"

  @undocumented
  Scenario: The 'root' option cannot point to a symlink to a parent directory in .binconfig
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    And a symlink '/project/root/symlink' pointing to '/project/scripts'
    And a file '/project/root/.binconfig' with content 'dir=symlink'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The option 'dir' cannot point to a directory outside /project/root in /project/root/.binconfig line 1"

  @undocumented
  Scenario: When --dir matches .binconfig, .binconfig should be parsed as normal
    Given a file '/project/.binconfig' with content:
      """
      dir=scripts

      [hello]
      help=Hello, World!
      """
    And a script '/project/scripts/hello'
    When I run 'bin --dir scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello    Hello, World!
      """

  @undocumented
  Scenario: When --dir doesn't match .binconfig, .binconfig should be ignored
    Given a file '/project/.binconfig' with content:
      """
      [hello]
      help=Hello, World!
      """
    And a script '/project/scripts/hello'
    When I run 'bin --dir scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello
      """
