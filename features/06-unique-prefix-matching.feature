Feature: Unique prefix matching
  https://github.com/bin-cli/bin#unique-prefix-matching

  Background:
    Given a script '/project/bin/hello' that outputs 'Hello, World!'

  Scenario: When entering a unique prefix, the matching command is executed
    When I run 'bin h'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: When entering an ambiguous prefix, the matches are listed
    Given a script '/project/bin/hi'
    And a script '/project/bin/another'
    When I run 'bin h'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      bin hi
      """

  Scenario: Unique prefix matching can be disabled via a config file in the root directory
    Given a file '/project/.binconfig' with content 'exact=true'
    When I run 'bin hel'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      """

  Scenario: Unique prefix matching can be disabled via a config file in the bin/ directory
    Given a file '/project/bin/.binconfig' with content 'exact=true'
    When I run 'bin hel'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      """

  Scenario: Unique prefix matching can't be disabled via a config file in a subdirectory
    Given a file '/project/.binconfig' with content 'exact=true'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "The config option 'exact' cannot be used in /project/bin/subdir/.binconfig"

  Scenario: Unique prefix matching can be disabled with --exact
    When I run 'bin --exact hel'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      """

  Scenario: Unique prefix matching can be enabled with --prefix, overriding the config file
    Given a file '/project/.binconfig' with content 'exact=true'
    When I run 'bin --prefix hel'
    Then it is successful
    And the output is 'Hello, World!'
