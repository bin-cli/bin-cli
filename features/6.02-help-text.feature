Feature: Help text

  Rule: Help text is displayed in command listings

    | ### Help Text
    |
    | To add a short (one-line) description of each command, enter it in `.binconfig` as follows:
    |
    | ```ini
    | [deploy]
    | help = Sync the code to the live server
    | ```
    |
    | This will be displayed when you run `bin` with no parameters (or with an ambiguous prefix). For example:
    |
    | <pre>
    | $ bin
    | <strong>Available Commands</strong>
    | bin artisan    Run Laravel Artisan with the appropriate version of PHP
    | bin deploy     Sync the code to the live server
    | bin php        Run the appropriate version of PHP for this project
    | </pre>
    |
    | I recommend keeping the descriptions short. The scripts could then support a `--help` parameter, or similar, if further explanation is required.

    Scenario: Help text configured in .binconfig is displayed in command listings
      Given a script '{ROOT}/project/bin/artisan'
      And a script '{ROOT}/project/bin/deploy'
      And a script '{ROOT}/project/bin/php'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [artisan]
        help = Run Laravel Artisan with the appropriate version of PHP

        [deploy]
        help = Sync the code to the live server

        [php]
        help = Run the appropriate version of PHP for this project
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin artisan    Run Laravel Artisan with the appropriate version of PHP
        bin deploy     Sync the code to the live server
        bin php        Run the appropriate version of PHP for this project
        """

    Scenario: Help text may be provided for a subset of commands
      Given a script '{ROOT}/project/bin/artisan'
      And a script '{ROOT}/project/bin/deploy'
      And a script '{ROOT}/project/bin/php'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [artisan]
        help = Run Laravel Artisan with the appropriate version of PHP

        [php]
        help = Run the appropriate version of PHP for this project
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin artisan    Run Laravel Artisan with the appropriate version of PHP
        bin deploy
        bin php        Run the appropriate version of PHP for this project
        """

    Scenario: Indentation is adjusted to suit the maximum command length
      Given a script '{ROOT}/project/bin/php'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [php]
        help = Run the appropriate version of PHP for this project
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin php    Run the appropriate version of PHP for this project
        """

    Scenario: Blank help text is ignored
      Given a script '{ROOT}/project/bin/hello'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        help =
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin hello
        """

  Rule: Help text is supported for subcommands

    | For subcommands, use the full command name, not the filename:
    |
    | ```ini
    | [deploy live]
    | help = Deploy to the production site
    |
    | [deploy staging]
    | help = Deploy to the staging site
    | ```

    Scenario: Help text is supported for subcommands
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a script '{ROOT}/project/bin/another'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy live]
        help = Deploy to the production site

        [deploy staging]
        help = Deploy to the staging site

        [another]
        help = Another command
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin another           Another command
        bin deploy live       Deploy to the production site
        bin deploy staging    Deploy to the staging site
        """

  Rule: Arguments are displayed in command listings

    | You can also list the arguments that each command accepts:
    |
    | ```ini
    | [test]
    | args = [suite]
    | help = Run the given test suite, or all test suites
    | ```
    |
    | I recommended keeping this short - one or two arguments - and writing `[...]` if there are many arguments available. For example:
    |
    | <pre>
    | $ bin
    | <strong>Available Commands</strong>
    | bin artisan [...]    Run Laravel Artisan with the appropriate version of PHP
    | bin deploy           Sync the code to the live server
    | bin test [suite]     Run the given test suite, or all test suites
    | </pre>

    Scenario: Command arguments configured in .binconfig are displayed in command listings
      Given a script '{ROOT}/project/bin/artisan'
      And a script '{ROOT}/project/bin/deploy'
      And a script '{ROOT}/project/bin/test'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [artisan]
        args = [...]
        help = Run Laravel Artisan with the appropriate version of PHP

        [deploy]
        help = Sync the code to the live server

        [test]
        args = [suite]
        help = Run the given test suite, or all test suites
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin artisan [...]    Run Laravel Artisan with the appropriate version of PHP
        bin deploy           Sync the code to the live server
        bin test [suite]     Run the given test suite, or all test suites
        """
