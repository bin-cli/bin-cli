Feature: Edge cases

  @undocumented
  Scenario: Filenames may contain spaces
    Given a script '/project/bin/hello world' that outputs 'Hello, World!'
    When I run 'bin "hello world"'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: Scripts with spaces are listed correctly
    Given a script '/project/bin/hello world'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin 'hello world'
      """

  @undocumented
  Scenario: Directories may contain spaces
    Given a script '/project/bin/hello world/script' that outputs 'Hello, World!'
    When I run 'bin "hello world" script'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: Scripts with spaces are listed correctly
    Given a script '/project/bin/hello world/script'
    When I run 'bin "hello world"'
    Then it is successful
    And the output is:
      """
      Available subcommands
      bin 'hello world' script
      """
