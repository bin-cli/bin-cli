Feature: Aliases

  Rule: Aliases can be defined in .binconfig

    | ### Aliases
    |
    | You can define aliases in `.binconfig` like this:
    |
    | ```ini
    | [deploy]
    | alias = publish
    | ```
    |
    | This means `bin publish` is an alias for `bin deploy`, and running either would execute the `bin/deploy` script.

    Scenario: An alias can be defined in .binconfig
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish
        """
      When I run 'bin publish'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Aliases can be defined for subcommands
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy live]
        alias = publish
        """
      When I run 'bin publish'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Aliases can be subcommands
      Given a script '{ROOT}/project/bin/publish' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [publish]
        alias = deploy live
        """
      When I run 'bin deploy live'
      Then it is successful
      And the output is 'Copying to production...'

  Rule: Commands can have multiple aliases

    | You can define multiple aliases by separating them with commas (and optional spaces). You can use the key `aliases` if you prefer to be pedantic:
    |
    | ```ini
    | [deploy]
    | aliases = publish, push
    | ```
    |
    | Or you can list them on separate lines instead:
    |
    | ```ini
    | [deploy]
    | alias = publish
    | alias = push
    | ```

    Scenario: Multiple aliases can be defined on one line
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish, push
        """
      When I run 'bin push'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Multiple aliases can be defined on one line with the option 'aliases'
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        aliases = publish, push
        """
      When I run 'bin push'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Multiple aliases can be defined on separate lines
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish
        alias = push
        """
      When I run 'bin push'
      Then it is successful
      And the output is 'Copying to production...'

  Rule: Symlinks can be used to define aliases

    | Alternatively, you can use symlinks to define aliases:
    |
    | ```bash
    | $ cd bin
    | $ ln -s deploy publish
    | ```
    |
    | Be sure to use relative targets, not absolute ones, so they work in any location. (Absolute targets will be rejected, for safety.)

    Scenario: An alias can be defined by a symlink
      Given a script '{ROOT}/project/bin/deploy'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin deploy    (alias: publish)
        """

    Scenario: A directory alias can be defined by a symlink
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin deploy live       (alias: publish live)
        bin deploy staging    (alias: publish staging)
        """

    Scenario: Symlink aliases are combined with config aliases
      Given a script '{ROOT}/project/bin/deploy'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        aliases = alpha, zappa
        """
      When I run 'bin'
      Then it is successful
      # I considered sorting them alphabetically, but it's not a good idea to combine the
      # two methods, and keeping the order set in .binconfig gives the user more control
      And the output is:
        """
        Available Commands
        bin deploy    (aliases: publish, alpha, zappa)
        """

    Scenario: A symlink alias must be relative not absolute
      Given a script '{ROOT}/project/bin/one'
      And a symlink '{ROOT}/project/bin/two' pointing to '{ROOT}/project/bin/one'
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: The symlink '{ROOT}/project/bin/two' must use a relative path, not absolute ('{ROOT}/project/bin/one')"

    Scenario: A broken symlink is displayed as a warning
      Given a symlink '{ROOT}/project/bin/broken' pointing to 'missing'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        None found

        Warning: The following symlinks point to targets that don't exist:
        {ROOT}/project/bin/broken => missing
        """

  Rule: Aliases are displayed in the command listing

    | In any case, aliases are listed alongside the help text when you run `bin` with no parameters (or with a non-unique prefix). For example:
    |
    | <pre>
    | $ bin
    | <strong>Available Commands</strong>
    | bin artisan    Run Laravel Artisan with the appropriate version of PHP <em>(alias: art)</em>
    | bin deploy     Sync the code to the live server <em>(aliases: publish, push)</em>
    | </pre>

    Scenario: Aliases are displayed in the command list
      Given a script '{ROOT}/project/bin/artisan'
      And a script '{ROOT}/project/bin/deploy'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [artisan]
        alias = art

        [deploy]
        alias = publish, push
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin artisan    (alias: art)
        bin deploy     (aliases: publish, push)
        """

    Scenario: Aliases are displayed after the help text
      Given a script '{ROOT}/project/bin/artisan'
      And a script '{ROOT}/project/bin/deploy'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [artisan]
        alias = art
        help = Run Laravel Artisan with the appropriate version of PHP

        [deploy]
        alias = publish, push
        help = Sync the code to the live server
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin artisan    Run Laravel Artisan with the appropriate version of PHP (alias: art)
        bin deploy     Sync the code to the live server (aliases: publish, push)
        """

    Scenario: Blank aliases are ignored
      Given a script '{ROOT}/project/bin/hello'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        alias =
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin hello
        """

  Rule: Aliases work for directories

    | COLLAPSE: Can I define aliases for commands that have subcommands?
    |
    | Yes - for example, given a script `bin/deploy/live` and this config file:
    |
    | ```ini
    | [deploy]
    | alias = push
    | ```
    |
    | `bin push live` would be an alias for `bin deploy live`, and so on.

    Scenario: Aliases can be defined for directories
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = push
        """
      When I run 'bin push live'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Aliases defined for directories are displayed in command listings
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = push
        """
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin deploy live       (alias: push live)
        bin deploy staging    (alias: push staging)
        """

  Rule: Aliases are considered by unique prefix matching

    | COLLAPSE: How do aliases affect unique prefix matching?
    |
    | Aliases are checked when looking for unique prefixes. In this example:
    |
    | ```ini
    | [deploy]
    | aliases = publish, push
    | ```
    |
    | - `bin pub` would match `bin publish`, which is an alias for `bin deploy`, which runs the `bin/deploy` script
    | - `bin pu` would match both `bin publish` and `bin push` - but since both are aliases for `bin deploy`, that would be treated as a unique prefix and would therefore also run `bin/deploy`

    Scenario: Aliases are subject to unique prefix matching
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish
        """
      When I run 'bin pub'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Multiple aliases for the same command are treated as one match
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish, push
        """
      When I run 'bin pu'
      Then it is successful
      And the output is 'Copying to production...'

  Rule: Alias conflicts cause an error

    | COLLAPSE: What happens if an alias conflicts with another command?
    |
    | Defining an alias that conflicts with a script or another alias will cause Bin to exit with error code 246 and print a message to stderr.

    Scenario: Defining an alias that conflicts with a command causes an error
      Given a script '{ROOT}/project/bin/one'
      And a script '{ROOT}/project/bin/two'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [one]
        alias = two
        """
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: The alias 'two' defined in {ROOT}/project/.binconfig line 2 conflicts with an existing command"

    Scenario: Defining an alias that conflicts with another alias causes an error
      Given a script '{ROOT}/project/bin/one'
      And a script '{ROOT}/project/bin/two'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [one]
        alias = three

        [two]
        alias = three
        """
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: The alias 'three' defined in {ROOT}/project/.binconfig line 5 conflicts with the alias defined in {ROOT}/project/.binconfig line 2"

    Scenario: Defining an alias that conflicts with a symlink alias causes an error
      Given a script '{ROOT}/project/bin/one'
      And a script '{ROOT}/project/bin/two'
      And a symlink '{ROOT}/project/bin/three' pointing to 'one'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [two]
        alias = three
        """
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: The alias 'three' defined in {ROOT}/project/.binconfig line 2 conflicts with the alias defined in {ROOT}/project/bin/three"
