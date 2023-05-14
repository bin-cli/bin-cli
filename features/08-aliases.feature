Feature: Aliases
  https://github.com/bin-cli/bin#aliases

  Scenario: An alias can be defined in .binconfig
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on one line
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish, push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on one line with the option 'aliases'
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      aliases=publish, push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on separate lines
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      alias=push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for directories
    Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=push
      """
    When I run 'bin push live'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for subcommands
    Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy live]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  @undocumented
  Scenario: Aliases can be subcommands
    Given a script '{ROOT}/project/bin/publish' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [publish]
      alias=deploy live
      """
    When I run 'bin deploy live'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases are displayed in the command list
    Given a script '{ROOT}/project/bin/artisan'
    And a script '{ROOT}/project/bin/deploy'
    And a file '{ROOT}/project/.binconfig' with content:
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
    Given a script '{ROOT}/project/bin/artisan'
    And a script '{ROOT}/project/bin/deploy'
    And a file '{ROOT}/project/.binconfig' with content:
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
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin pub'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases for the same command are treated as one match
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [deploy]
      alias=publish, push
      """
    When I run 'bin pu'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Defining an alias that conflicts with a command causes an error
    Given a script '{ROOT}/project/bin/one'
    And a script '{ROOT}/project/bin/two'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [one]
      alias=two
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
      alias=three

      [two]
      alias=three
      """
    When I run 'bin'
    Then it fails with exit code 246
    And the error is "bin: The alias 'three' defined in {ROOT}/project/.binconfig line 5 conflicts with the alias defined in {ROOT}/project/.binconfig line 2"

  Scenario: An alias can be defined by a symlink
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
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
      Available commands
      bin deploy live       (alias: publish live)
      bin deploy staging    (alias: publish staging)
      """

  Scenario: Defining an alias that conflicts with a symlink alias causes an error
    Given a script '{ROOT}/project/bin/one'
    And a script '{ROOT}/project/bin/two'
    And a symlink '{ROOT}/project/bin/three' pointing to 'one'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [two]
      alias=three
      """
    When I run 'bin'
    Then it fails with exit code 246
    And the error is "bin: The alias 'three' defined in {ROOT}/project/bin/three conflicts with the alias defined in {ROOT}/project/.binconfig line 2"

  Scenario: A symlink alias must be relative not absolute
    Given a script '{ROOT}/project/bin/one'
    And a symlink '{ROOT}/project/bin/two' pointing to '{ROOT}/project/bin/one'
    When I run 'bin'
    Then it fails with exit code 246
    And the error is "bin: The symlink '{ROOT}/project/bin/two' must use a relative path, not absolute ('{ROOT}/project/bin/one')"

  @undocumented
  Scenario: A broken symlink
    Given a symlink '{ROOT}/project/bin/broken' pointing to 'missing'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      None found

      Warning: The following symlinks point to targets that don't exist:
      {ROOT}/project/bin/broken => missing
      """
