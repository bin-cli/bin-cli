Feature: Aliases

  Rule: Symlinks can be used to define aliases

    | ### Aliases
    |
    | You can define aliases by creating symlinks between scripts within the `bin/` directory - for example:
    |
    | ```bash
    | $ cd bin
    | $ ln -s deploy publish
    | ```
    |
    | Which creates this directory structure (symlink targets indicated by `->`):
    |
    | ```
    | repo/
    | └── bin/
    |     ├── deploy
    |     └── publish -> deploy
    | ```
    |
    | This means `bin publish` is an alias for `bin deploy`, and running either would execute the `bin/deploy` script.
    |
    | Be sure to use relative targets, not absolute ones, so they work in any location. (Absolute targets will be rejected, for safety.)

    Scenario: An alias can be defined by a symlink
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin publish'
      Then it is successful
      And the output is 'Copying to production...'

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

    | Aliases are listed alongside the commands when you run `bin` with no parameters (or with a non-unique prefix). For example:
    |
    | <pre>
    | $ bin
    | <strong>Available Commands</strong>
    | bin artisan <em>(alias: art)</em>
    | bin deploy <em>(aliases: publish, push)</em>
    | </pre>

    Scenario: Aliases are displayed in the command listing
      Given a script '{ROOT}/project/bin/artisan'
      And a script '{ROOT}/project/bin/deploy'
      And a symlink '{ROOT}/project/bin/art' pointing to 'artisan'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      And a symlink '{ROOT}/project/bin/push' pointing to 'deploy'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin artisan (alias: art)
        bin deploy (aliases: publish, push)
        """

  Rule: Aliases work for directories

    | COLLAPSE: Can I define aliases for commands that have subcommands (i.e. directories)?
    |
    | Yes - for example, given a script `bin/deploy/live` and this directory structure:
    |
    | ```
    | repo/
    | └── bin/
    |     ├── deploy
    |     │   └── live
    |     └── push -> deploy
    | ```
    |
    | `bin push live` would be an alias for `bin deploy live`, and so on.

    Scenario: Aliases can be defined for directories and are inherited by all subcommands
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin publish live'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Aliases for directories are displayed in the command listing
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin deploy live (alias: publish live)
        bin deploy staging (alias: publish staging)
        """

  Rule: Aliases are considered by unique prefix matching

    | COLLAPSE: How do aliases affect unique prefix matching?
    |
    | Aliases are checked when looking for unique prefixes. In this example:
    |
    | ```
    | repo/
    | └── bin/
    |     ├── deploy
    |     ├── publish -> deploy
    |     └── push -> deploy
    | ```
    |
    | - `bin pub` would match `bin publish`, which is an alias for `bin deploy`, which runs the `bin/deploy` script
    | - `bin pu` would match both `bin publish` and `bin push` - but since both are aliases for `bin deploy`, that would be treated as a unique prefix and would therefore also run `bin/deploy`

    Scenario: Aliases are subject to unique prefix matching
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin pub'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Multiple aliases for the same command are treated as one match
      Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      And a symlink '{ROOT}/project/bin/push' pointing to 'deploy'
      When I run 'bin pu'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Unique prefix matching works for aliases pointing to subcommands
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy/live'
      When I run 'bin pub'
      Then it is successful
      And the output is 'Copying to production...'
