Feature: Inline commands
  Not documented yet...

  @undocumented
  Scenario: An inline command can be defined in .binconfig
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo 'Hello, World!'
      """
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: Inline commands can accept positional arguments
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      [hello]
      command=echo "1=$1 2=$2"
      """
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
  Scenario: The bin command is available in $BIN_COMMAND
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
