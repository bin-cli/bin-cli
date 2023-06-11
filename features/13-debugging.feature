Feature: Debugging
  https://github.com/bin-cli/bin#debugging

  @auto-update-debugging
  Scenario: Passing --debug returns detailed debugging information
    Given a script '{ROOT}/project/bin/test'
    When I run 'bin --debug test'
    Then it is successful
    And the output contains:
      # I chose "--" for indenting because it has no special meaning in Markdown
      # (unlike "-" or ">" or spaces), so it should be output correctly when
      # pasted into a GitHub issue without a code fence
      """
      Bin version 1.2.3-dev
      Action set to 'run'
      Working directory is {ROOT}/project
      Looking for a .binconfig file in:
      -- {ROOT}/project - not found
      -- {ROOT} - not found
      """

    Scenario: Passing --print displays the command that would have been run (1)
      Given a script '{ROOT}/project/bin/sample/hello'
      When I run 'bin --print sample hello world'
      Then it is successful
      And the output is '{ROOT}/project/bin/sample/hello world'

    Scenario: Passing --print displays the command that would have been run (2)
      Given an empty directory '{ROOT}/project/bin'
      When I run 'bin --print --shim php -v'
      Then it is successful
      And the output is 'php -v'

    Scenario: Passing --print displays the command that would have been run (3)
      Given an empty directory '{ROOT}/project/bin'
      When I run 'bin --print php -v'
      Then the exit code is 127
      And there is no output
      And the error is "bin: Command 'php' not found in {ROOT}/project/bin"
