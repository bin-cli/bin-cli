Feature: Root in both CLI and .binconfig

  Scenario: When --root matches .binconfig, .binconfig should be parsed as normal
    Given a file '/project/.binconfig' with content:
      """
      root=scripts

      [hello]
      help=Hello, World!
      """
    And a script 'scripts/hello'
    When I run 'bin --root=scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello    Hello, World!
      """

  Scenario: When --root doesn't match .binconfig, .binconfig should be ignored
    Given a file '/project/.binconfig' with content:
      """
      [hello]
      help=Hello, World!
      """
    And a script 'scripts/hello'
    When I run 'bin --root=scripts'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello
      """
