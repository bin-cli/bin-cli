Feature: Custom script directory
  https://github.com/bin-cli/bin-cli#custom-script-directory

  Scenario: The script directory can be overridden in .binconfig
    Given a file '{ROOT}/project/.binconfig' with content 'dir=scripts'
    And a script '{ROOT}/project/scripts/test' that outputs 'Right'
    And a script '{ROOT}/project/bin/test' that outputs 'Wrong'
    When I run 'bin test'
    Then it is successful
    And the output is 'Right'

  Scenario: Directories above .binconfig are not searched when root is specified in .binconfig
    Given a file '{ROOT}/project/root/.binconfig' with content 'dir=scripts'
    And a script '{ROOT}/project/scripts/hello'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin hello'
    Then it fails with exit code 127
    And the error is "bin: Command 'hello' not found in {ROOT}/project/root/scripts/ or {ROOT}/project/root/.binconfig"

  Scenario: Directories below .binconfig are not searched when root is specified in .binconfig
    Given a file '{ROOT}/project/.binconfig' with content 'dir=scripts'
    And a script '{ROOT}/project/scripts/test' that outputs 'Right'
    And a script '{ROOT}/project/root/scripts/test' that outputs 'Wrong'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin test'
    Then it is successful
    And the output is 'Right'

  Scenario: Scripts can be in the project root
    Given a file '{ROOT}/project/.binconfig' with content 'dir=.'
    And a script '{ROOT}/project/hello' that outputs 'Hello, World!'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Subcommands are not supported in the project root
    Given a file '{ROOT}/project/.binconfig' with content 'dir=.'
    And a script '{ROOT}/project/hello/world'
    When I run 'bin hello world'
    Then it fails with exit code 246
    And the error is "bin: Subcommands are not supported with the config option 'dir=.'"

  Scenario: The root directory can be configured with --dir
    Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
    When I run 'bin --dir scripts hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Setting the root directory with --dir overrides .binconfig
    Given a script '{ROOT}/project/right/script' that outputs 'Right'
    And a script '{ROOT}/project/root/wrong/script' that outputs 'Wrong'
    And a file '{ROOT}/project/root/.binconfig' with content 'dir=wrong'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin --dir right script'
    Then it is successful
    And the output is 'Right'

  Scenario: The root directory can be an absolute path when given with --dir
    Given a script '{ROOT}/project/scripts/dev/hello' that outputs 'Hello, World!'
    When I run 'bin --dir {ROOT}/project/scripts/dev hello'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: The 'root' option cannot be an absolute path when set in .binconfig
    Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
    And a file '{ROOT}/project/.binconfig' with content 'dir=/project/scripts'
    When I run 'bin hello'
    Then it fails with exit code 246
    And the error is "bin: The option 'dir' cannot be an absolute path in {ROOT}/project/.binconfig line 1"

  @undocumented
  Scenario: The 'root' option cannot point to a parent directory in .binconfig
    Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
    And a file '{ROOT}/project/root/.binconfig' with content 'dir=../scripts'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin hello'
    Then it fails with exit code 246
    And the error is "bin: The option 'dir' cannot point to a directory outside {ROOT}/project/root in {ROOT}/project/root/.binconfig line 1"

  @undocumented
  Scenario: The 'root' option cannot point to a symlink to a parent directory in .binconfig
    Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
    And a symlink '{ROOT}/project/root/symlink' pointing to '../scripts'
    And a file '{ROOT}/project/root/.binconfig' with content 'dir=symlink'
    And the working directory is '{ROOT}/project/root'
    When I run 'bin hello'
    Then it fails with exit code 246
    And the error is "bin: The option 'dir' cannot point to a directory outside {ROOT}/project/root in {ROOT}/project/root/.binconfig line 1"

  @undocumented
  Scenario: When --dir is a relative path, that directory is not expected to exist
    When I run 'bin --dir scripts hello'
    Then it fails with exit code 127
    And the error is "bin: Could not find 'scripts/' directory starting from '{ROOT}/project'"

  @undocumented
  Scenario: When --dir is an absolute path, that directory is expected to exist
    When I run 'bin --dir /missing hello'
    Then it fails with exit code 246
    And the error is "bin: Specified directory '/missing/' is missing"

  @undocumented
  Scenario: When --dir matches .binconfig, .binconfig should be parsed as normal
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      dir=scripts

      [hello]
      help=Hello, World!
      """
    And a script '{ROOT}/project/scripts/hello'
    When I run 'bin --dir scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello    Hello, World!
      """

  @undocumented
  Scenario: When --dir doesn't match .binconfig, .binconfig should be ignored
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      help=Hello, World!
      """
    And a script '{ROOT}/project/scripts/hello'
    When I run 'bin --dir scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello
      """
