Feature: Edge cases

  Scenario: Spaces in filenames are converted to dashes when running
    Given a script '{ROOT}/project/bin/hello world script' that outputs 'Hello, World!'
    When I run 'bin hello-world-script'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Spaces in filenames are converted to dashes when listing
    Given a script '{ROOT}/project/bin/hello world script'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available Commands
      bin hello-world-script
      """

  Scenario: Spaces in directories are converted to dashes when running
    Given a script '{ROOT}/project/bin/hello world/script' that outputs 'Hello, World!'
    When I run 'bin hello-world script'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Spaces in directories are converted to dashes when listing
    Given a script '{ROOT}/project/bin/hello world/script'
    When I run 'bin hello-world'
    Then it is successful
    And the output is:
      """
      Available Subcommands
      bin hello-world script
      """

  Scenario: Symlink aliases are handled correctly when inside a symlinked root
    # Need to test this because 'readlink -f' will expand paths fully
    Given a script '{ROOT}/project/bin/deploy' that outputs 'Copying to production...'
    And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
    And a symlink '{ROOT}/symlink' pointing to 'project'
    And the working directory is '{ROOT}/symlink'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available Commands
      bin deploy (alias: publish)
      """

  Scenario: Directory aliases are handled correctly when inside a symlinked root
    # As above
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
    And a symlink '{ROOT}/symlink' pointing to 'project'
    And the working directory is '{ROOT}/symlink'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available Commands
      bin deploy live (alias: publish live)
      bin deploy staging (alias: publish staging)
      """

  Scenario Outline: The '<option><suffix>' option requires a value
    When I run 'bin <option><suffix>'
    Then it fails with exit code 246
    And the error is "bin: The '<option>' option requires a value"

    Examples:
      | option     | suffix |
      | --dir      |        |
      | --dir      | =      |
      | --exe      |        |
      | --exe      | =      |

    Scenario: Associative arrays are emulated in Bash <4
      # On its own this test doesn't really prove anything, but this gets the
      # code coverage back to 100%, then we run tests on macOS on GitHub Actions
      Given an environment variable 'BIN_DEBUG_ASSOC_ARRAYS' set to 'true'
      And a script '{ROOT}/project/bin/hello' that outputs "Hello, ${1:-World}!"
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'
