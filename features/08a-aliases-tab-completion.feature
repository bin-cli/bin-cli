Feature: Tab completion for aliases
  https://github.com/bin-cli/bin-cli#tab-completion
  https://github.com/bin-cli/bin-cli#aliases

  Scenario: Tab completion works for aliases
    Given a script '{ROOT}/project/bin/deploy'
    And a script '{ROOT}/project/bin/another'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [artisan]
      alias=art

      [deploy]
      alias=publish
      """
    When I tab complete 'bin p'
    Then it is successful
    And the output is:
      """
      publish
      """

  @undocumented
  Scenario: If both the command and the alias match, only the command is listed in tab completion
    Given a script '{ROOT}/project/bin/deploy'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      deploy
      """

  @undocumented
  Scenario: If multiple aliases for the same command match, only one is returned in tab completion
    Given a script '{ROOT}/project/bin/deploy'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      alias=push
      """
    When I tab complete 'bin p'
    Then it is successful
    And the output is:
      """
      publish
      """
