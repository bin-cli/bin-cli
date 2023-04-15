Feature: Root in both CLI and .binconfig

  Scenario: When --dir matches .binconfig, .binconfig should be parsed as normal
    Given a file '/project/.binconfig' with content:
      """
      dir=scripts

      [hello]
      help=Hello, World!
      """
    And a script 'scripts/hello'
    When I run 'bin --dir=scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello    Hello, World!
      """

  Scenario: When --dir doesn't match .binconfig, .binconfig should be ignored
    Given a file '/project/.binconfig' with content:
      """
      [hello]
      help=Hello, World!
      """
    And a script 'scripts/hello'
    When I run 'bin --dir=scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello
      """
