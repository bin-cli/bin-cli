Feature: Tab completion
  https://github.com/bin-cli/bin#tab-completion

  Scenario: A tab completion script is available for Bash
    When I run 'bin --completion'
    Then it is successful
    And the output is 'complete -C "{ROOT}/usr/bin/bin --complete-bash" -o default bin'

  Scenario: Tab completion works for simple commands
    Given a script '{ROOT}/project/bin/hello'
    When I tab complete 'bin h'
    Then it is successful
    And the output is:
      """
      hello
      """

  Scenario: Tab completion works for multiple matching commands
    Given a script '{ROOT}/project/bin/hello'
    Given a script '{ROOT}/project/bin/hi'
    When I tab complete 'bin h'
    Then it is successful
    And the output is:
      """
      hello
      hi
      """

  Scenario: Tab completion works for directories with partial match
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I tab complete 'bin d'
    Then it is successful
    And the output is:
      """
      deploy
      """

  Scenario: Tab completion works for directories with full match
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I tab complete 'bin deploy'
    Then it is successful
    And the output is:
      """
      deploy
      """

  Scenario: Tab completion works for subcommands with blank parameter
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I tab complete 'bin deploy '
    Then it is successful
    And the output is:
      """
      live
      staging
      """

  Scenario: Tab completion works for subcommands with partial match
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I tab complete 'bin deploy l'
    Then it is successful
    And the output is:
      """
      live
      """

  Scenario: Tab completion works for subcommands with full match
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I tab complete 'bin deploy live'
    Then it is successful
    And the output is:
      """
      live
      """

  Scenario: Tab completion works with the cursor in the middle of the string
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I tab complete 'bin d|eploy '
    Then it is successful
    And the output is:
      """
      deploy
      """

  Scenario: Nothing is output for parameters after the last command
    Given a script '{ROOT}/project/bin/deploy/live'
    When I tab complete 'bin deploy live '
    Then it is successful
    And there is no output
