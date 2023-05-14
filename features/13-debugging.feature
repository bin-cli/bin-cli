Feature: Debugging
  https://github.com/bin-cli/bin#debugging

  Scenario: Passing --debug returns detailed debugging information about shims
    Given a file '{ROOT}/project/.binconfig' with content:
      """
      dir=scripts

      [one]
      help=One

      [two]
      help=Two
      aliases=deux, dos

      [three]
      help=Three
      alias=333
      """
    And a script '{ROOT}/project/scripts/one'
    And a script '{ROOT}/project/scripts/two'
    And a script '{ROOT}/project/scripts/three'
    And a script '{ROOT}/project/scripts/four'
    And a script '{ROOT}/project/scripts/five'
    And a script '{ROOT}/project/scripts/subdir/six'
    And a script '{ROOT}/usr/bin/php'
    And the working directory is '{ROOT}/project/public'
    When I run 'bin --debug --shim php -v'
    Then it is successful
    And the output is:
      # I chose "--" for indenting because it has no special meaning in Markdown
      # (unlike "-" or ">" or spaces), so it should be output correctly when
      # pasted into a GitHub issue without a code fence
      """
      Bin version 1.2.3-dev
      Working directory is {ROOT}/project/public
      Looking for a .binconfig file in:
      -- {ROOT}/project/public - not found
      -- {ROOT}/project - found
      Checking {ROOT}/project/.binconfig for a 'dir' setting
      -- Found dir=scripts
      -- Using 'scripts' from the config file
      Parsing {ROOT}/project/.binconfig
      -- Found [one] section
      ---- Registered help for 'one'
      -- Found [two] section
      ---- Registered help for 'two'
      ---- Registered alias 'deux' for command 'two'
      ---- Registered alias 'dos' for command 'two'
      -- Found [three] section
      ---- Registered help for 'three'
      ---- Registered alias '333' for command 'three'
      'exact' defaulted to 'false'
      Bin directory set to '{ROOT}/project/scripts' from config file
      Searching '{ROOT}/project/scripts' for scripts
      -- Registered command 'five' for executable '{ROOT}/project/scripts/five'
      -- Registered command 'four' for executable '{ROOT}/project/scripts/four'
      -- Registered command 'one' for executable '{ROOT}/project/scripts/one'
      -- Registered subdirectory '{ROOT}/project/scripts/subdir' to parent command 'subdir'
      -- Searching subdirectory '{ROOT}/project/scripts/subdir'
      -- Registered command 'subdir six' for executable '{ROOT}/project/scripts/subdir/six'
      -- Registered command 'three' for executable '{ROOT}/project/scripts/three'
      -- Registered command 'two' for executable '{ROOT}/project/scripts/two'
      Processing symlink aliases
      Processing directory aliases and checking for conflicts
      Processing positional parameters
      -- Looking for command 'php' (exact)
      ---- No match for 'deux'
      ---- No match for 'dos'
      ---- No match for '333'
      ---- No match for 'five'
      ---- No match for 'four'
      ---- No match for 'one'
      ---- No match for 'subdir six'
      ---- No match for 'three'
      ---- No match for 'two'
      ---- There were 0 matches - not running command
      -- Looking for command 'php' (with-extension)
      ---- No match for 'deux'
      ---- No match for 'dos'
      ---- No match for '333'
      ---- No match for 'five'
      ---- No match for 'four'
      ---- No match for 'one'
      ---- No match for 'subdir six'
      ---- No match for 'three'
      ---- No match for 'two'
      ---- There were 0 matches - not running command
      -- Looking for command 'php' (subcommands)
      ---- No match for 'deux'
      ---- No match for 'dos'
      ---- No match for '333'
      ---- No match for 'five'
      ---- No match for 'four'
      ---- No match for 'one'
      ---- No match for 'subdir six'
      ---- No match for 'three'
      ---- No match for 'two'
      No command found - using shim
      Would execute: php -v
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
