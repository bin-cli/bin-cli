Feature: Debugging
  https://github.com/bin-cli/bin#debugging

  @auto-update-debugging-docs
  Scenario: Passing --debug returns detailed debugging information
    Given a script '{ROOT}/project/bin/test'
    When I run 'bin --debug test'
    Then it is successful
    And the output contains:
      # I chose "--" for indenting because it has no special meaning in Markdown
      # (unlike "-" or ">" or spaces), so it should be output correctly when
      # pasted into a GitHub issue without a code fence
      """
      Bin CLI v1.2.3-dev
      Working directory is '{ROOT}/project'
      Action is 'run'
      Determining paths...
      -- No directory specified at the command line
      -- Looking for a .binconfig file starting from {ROOT}/project
      ---- Checking in {ROOT}/project - not found
      ---- Checking in {ROOT} - not found
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
