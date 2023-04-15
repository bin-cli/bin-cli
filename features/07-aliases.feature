Feature: Aliases
  https://github.com/bin-cli/bin#aliases

  Scenario: An alias can be defined in .binconfig in the root directory
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: An alias can be defined in .binconfig in the bin/ directory
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/bin/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on one line
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish, push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on one line with the option 'aliases'
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      aliases=publish, push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on separate lines
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      alias=push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for directories
    Given a script '/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=push
      """
    When I run 'bin push live'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for subcommands
    Given a script '/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy live]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for subcommands in .binconfig in a subdirectory
    Given a script '/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '/project/bin/deploy/.binconfig' with content:
      """
      [live]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases are displayed in the command list
    Given a script '/project/bin/artisan'
    And a script '/project/bin/deploy'
    And a file '/project/.binconfig' with content:
      """
      [artisan]
      alias=art

      [deploy]
      alias=publish, push
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin artisan    (alias: art)
      bin deploy     (aliases: publish, push)
      """

  Scenario: Aliases are displayed after the help text
    Given a script '/project/bin/artisan'
    And a script '/project/bin/deploy'
    And a file '/project/.binconfig' with content:
      """
      [artisan]
      alias=art
      help=Run Laravel Artisan command with the appropriate version of PHP

      [deploy]
      alias=publish, push
      help=Sync the code to the live server
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin artisan    Run Laravel Artisan command with the appropriate version of PHP (alias: art)
      bin deploy     Sync the code to the live server (aliases: publish, push)
      """

  Scenario: Aliases are subject to unique prefix matching
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin pub'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases for the same command are treated as one match
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish, push
      """
    When I run 'bin pu'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Defining an alias that conflicts with a script causes an error
    Given a script '/project/bin/one'
    And a script '/project/bin/two'
    And a file '/project/.binconfig' with content:
      """
      [one]
      alias=two
      """
    When I run 'bin'
    Then the exit code is 246
    And there is no output
    And the error is "The alias 'two' conflicts with an existing command in /project/.binconfig line 2"

  Scenario: Defining an alias that conflicts with another alias causes an error
    Given a script '/project/bin/one'
    And a script '/project/bin/two'
    And a file '/project/.binconfig' with content:
      """
      [one]
      alias=number

      [two]
      alias=number
      """
    When I run 'bin'
    Then the exit code is 246
    And there is no output
    And the error is "The alias 'number' conflicts with another alias in /project/.binconfig line 5"
