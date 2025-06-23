Feature: Subcommands

  Rule: Subcommands can be executed and listed

    | ### Subcommands
    |
    | If you have multiple related commands, you may want to group them together and make subcommands. To do that, just create a subdirectory:
    |
    | ```
    | repo/
    | └── bin/
    |     └── deploy/
    |         ├── production
    |         └── staging
    | ```
    |
    | Now `bin deploy production` will run `bin/deploy/production`, and `bin deploy` will list the available subcommands:
    |
    | <pre>
    | $ bin deploy
    | <strong>Available Subcommands</strong>
    | bin deploy production
    | bin deploy staging
    | </pre>

    Scenario: Subcommands are created by scripts in subdirectories
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      When I run 'bin deploy live'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Subcommands are listed when Bin is run without parameters
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a script '{ROOT}/project/bin/another'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin another
        bin deploy live
        bin deploy staging
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
