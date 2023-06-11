Feature: Debugging
  https://github.com/bin-cli/bin#debugging

  @auto-update-debugging
  Scenario: Passing --debug returns detailed debugging information about shims
    Given a script '{ROOT}/project/bin/test'
    When I run 'bin --debug test'
    Then it is successful
    And the output contains:
      # I chose "--" for indenting because it has no special meaning in Markdown
      # (unlike "-" or ">" or spaces), so it should be output correctly when
      # pasted into a GitHub issue without a code fence
      """
      Bin version 1.2.3-dev
      Working directory is {ROOT}/project
      Looking for a .binconfig file in:
      -- {ROOT}/project - not found
      -- {ROOT} - not found
      'dir' defaulted to 'bin'
      'exact' defaulted to 'false'
      Looking for a bin/ directory in:
      -- {ROOT}/project - found
      Bin directory set to '{ROOT}/project/bin'
      Searching '{ROOT}/project/bin' for scripts
      -- Registered command 'test' for executable '{ROOT}/project/bin/test'
      Processing symlink aliases
      Processing directory aliases and checking for conflicts
      Processing positional parameters
      -- Looking for command 'test' (exact)
      ---- Found matching command 'test'
      Action is ''
      Would execute: {ROOT}/project/bin/test
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
