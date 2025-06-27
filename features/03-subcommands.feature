Feature: Subcommands

  Rule: Subcommands can be executed and listed

    Scenario: Subcommands are created by scripts in subdirectories
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      When I run 'bin deploy live'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Subcommands are not listed when Bin is run without parameters
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a script '{ROOT}/project/bin/another'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin another
        bin deploy ...
        """

    Scenario: Subcommands are listed when Bin is run with the directory name
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a script '{ROOT}/project/bin/another'
      When I run 'bin deploy'
      Then it is successful
      And the output is:
        """
        Available Subcommands
        bin deploy live
        bin deploy staging
        """
