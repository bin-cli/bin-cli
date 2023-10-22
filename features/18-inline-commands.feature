Feature: Inline commands
  https://github.com/bin-cli/bin-cli#inline-commands

  Scenario: An inline command can be defined in .binconfig
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo 'Hello, World!'
      """
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Inline commands can accept positional arguments
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo "1=$1 2=$2"
      """
    When I run 'bin hello one two'
    Then it is successful
    And the output is '1=one 2=two'

  Scenario: Inline commands can contain multiple commands
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo one; echo two
      """
    When I run 'bin hello'
    Then it is successful
    And the output is:
      """
      one
      two
      """

  Scenario: Inline commands can contain logic
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo one || echo two
      """
    When I run 'bin hello'
    Then it is successful
    And the output is 'one'

  Scenario: Additional parameters are not automatically passed to the command
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=helper
      """
    And a script '{ROOT}/usr/bin/helper' that outputs '1=$1 2=$2'
    When I run 'bin hello one two'
    Then it is successful
    And the output is '1= 2='

  Scenario: Additional parameters can be manually automatically passed to the command
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=helper "$@"
      """
    And a script '{ROOT}/usr/bin/helper' that outputs '1=$1 2=$2'
    When I run 'bin hello one two'
    Then it is successful
    And the output is '1=one 2=two'

  @undocumented
  Scenario: The root directory is available in $BIN_ROOT
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [test]
      command=echo "BIN_ROOT=$BIN_ROOT"
      """
    When I run 'bin test'
    Then it is successful
    And the output is 'BIN_ROOT={ROOT}/project'

  @undocumented
  Scenario: The bin directory is available in $BIN_DIR
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [test]
      command=echo "BIN_DIR=$BIN_DIR"
      """
    When I run 'bin test'
    Then it is successful
    And the output is 'BIN_DIR={ROOT}/project/bin'

  @undocumented
  Scenario: The bin executable is available in $BIN_EXE
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [test]
      command=echo "BIN_EXE=$BIN_EXE"
      """
    When I run 'bin test'
    Then it is successful
    And the output is 'BIN_EXE=bin'

  @undocumented
  Scenario: The bin command name is available in $BIN_COMMAND
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [test]
      command=echo "BIN_COMMAND=$BIN_COMMAND"
      """
    When I run 'bin test'
    Then it is successful
    And the output is 'BIN_COMMAND=bin test'

  @undocumented
  Scenario: If an inline command conflicts with a script command, an error is raised
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo 'Hello, World!'
      """
    And a script '{ROOT}/project/bin/hello'
    When I run 'bin hello'
    Then it fails with exit code 246
    And the error is "bin: The command 'hello' defined in {ROOT}/project/.binconfig line 2 conflicts with an existing command"

  @undocumented
  Scenario: Inline commands can have aliases
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      alias=hi
      command=echo 'Hello, World!'
      """
    When I run 'bin hi'
    Then it is successful
    And the output is 'Hello, World!'
