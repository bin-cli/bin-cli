Feature: Edge cases

  @undocumented
  Scenario: Spaces in filenames are converted to dashes when running
    Given a script '/project/bin/hello world script' that outputs 'Hello, World!'
    When I run 'bin hello-world-script'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: Spaces in filenames are converted to dashes when listing
    Given a script '/project/bin/hello world script'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin hello-world-script
      """

  @undocumented
  Scenario: Spaces in directories are converted to dashes when running
    Given a script '/project/bin/hello world/script' that outputs 'Hello, World!'
    When I run 'bin hello-world script'
    Then it is successful
    And the output is 'Hello, World!'

  @undocumented
  Scenario: Spaces in directories are converted to dashes when listing
    Given a script '/project/bin/hello world/script'
    When I run 'bin hello-world'
    Then it is successful
    And the output is:
      """
      Available subcommands
      bin hello-world script
      """
