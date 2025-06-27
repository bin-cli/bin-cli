Feature: Aliases

  Rule: Symlinks can be used to define aliases

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
      And the error is "bin: The symlink '{ROOT}/project/bin/two' must use a relative path not absolute ('{ROOT}/project/bin/one')"

    Scenario: Broken symlinks are ignored
      Given a symlink '{ROOT}/project/bin/broken' pointing to 'missing'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        None found
        """

  Rule: Aliases are displayed in the command listing

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
        bin deploy ... (alias: publish)
        """

    Scenario: If the alias is used for the parent command, it is used when listing subcommands
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I run 'bin publish'
      Then it is successful
      And the output is:
        """
        Available Subcommands
        bin publish live
        bin publish staging
        """

  Rule: Aliases are considered by unique prefix matching

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
