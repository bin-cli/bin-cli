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

  @undocumented
  Scenario: Symlink aliases are handled correctly when inside a symlinked root
    # Need to test this because 'readlink -f' will expand paths fully
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a symlink '/project/bin/publish' pointing to 'deploy'
    And a symlink '/symlink' pointing to 'project'
    And the working directory is '/symlink'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin deploy    (alias: publish)
      """

  @undocumented
  Scenario: Directory aliases are handled correctly when inside a symlinked root
    # As above
    Given a script '/project/bin/deploy/live'
    And a script '/project/bin/deploy/staging'
    And a symlink '/project/bin/publish' pointing to 'deploy'
    And a symlink '/symlink' pointing to 'project'
    And the working directory is '/symlink'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin deploy live       (alias: publish live)
      bin deploy staging    (alias: publish staging)
      """
