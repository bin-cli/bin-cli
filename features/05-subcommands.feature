Feature: Subcommands
  https://github.com/bin-cli/bin#subcommands

  Scenario: Subcommands are created by scripts in subdirectories
    Given a script '/project/bin/deploy/live' that outputs 'Copying to production...'
    When I run 'bin deploy live'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Subcommands are listed when Bin is run without parameters
    Given a script '/project/bin/deploy/live'
    And a script '/project/bin/deploy/staging'
    And a script '/project/bin/another'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin another
      bin deploy live
      bin deploy staging
      """

  Scenario: Subcommands are listed when Bin is run with the directory name
    Given a script '/project/bin/deploy/live'
    And a script '/project/bin/deploy/staging'
    And a script '/project/bin/another'
    When I run 'bin deploy'
    Then it is successful
    And the output is:
      """
      Available subcommands
      bin deploy live
      bin deploy staging
      """

  Scenario: Help text for subcommands can be provided in .binconfig
    Given a script '/project/bin/deploy/live'
    And a script '/project/bin/deploy/staging'
    And a script '/project/bin/another'
    And a file '/project/.binconfig' with content:
      """
      [deploy live]
      help=Deploy to the production site

      [deploy staging]
      help=Deploy to the staging site
      """
    When I run 'bin deploy'
    Then it is successful
    And the output is:
      """
      Available subcommands
      bin deploy live       Deploy to the production site
      bin deploy staging    Deploy to the staging site
      """
