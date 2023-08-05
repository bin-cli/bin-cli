Feature: Help text
  https://github.com/bin-cli/bin-cli#help-text

  Scenario: Help text configured in .binconfig is displayed in command listings
    Given a script '{ROOT}/project/bin/artisan'
    And a script '{ROOT}/project/bin/deploy'
    And a script '{ROOT}/project/bin/php'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [artisan]
      help=Run Laravel Artisan command with the appropriate version of PHP

      [deploy]
      help=Sync the code to the live server

      [php]
      help=Run the appropriate version of PHP for this project
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin artisan    Run Laravel Artisan command with the appropriate version of PHP
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
      help=Run Laravel Artisan command with the appropriate version of PHP

      [php]
      help=Run the appropriate version of PHP for this project
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin artisan    Run Laravel Artisan command with the appropriate version of PHP
      bin deploy
      bin php        Run the appropriate version of PHP for this project
      """

  Scenario: Indentation is adjusted to suit the maximum command length
    Given a script '{ROOT}/project/bin/php'
    And a file '{ROOT}/project/.binconfig' with content:
      """
      [php]
      help=Run the appropriate version of PHP for this project
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin php    Run the appropriate version of PHP for this project
      """
