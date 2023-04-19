Feature: Debugging
  https://github.com/bin-cli/bin#debugging

  Scenario: Passing --debug returns detailed debugging information about shims
    Given a file '/project/.binconfig' with content:
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
    And a script '/project/scripts/one'
    And a script '/project/scripts/two'
    And a script '/project/scripts/three'
    And a script '/project/scripts/four'
    And a script '/project/scripts/five'
    And a script '/project/scripts/subdir/six'
    And a script '/usr/bin/php'
    And the working directory is '/project/public'
    When I run 'bin --debug --shim php -v'
    Then it is successful
    And the output is:
      """
      Bin version 1.2.3
      Working directory is /project/public
      Looking for a .binconfig file
        /project/public - not found
        /project - found
      Checking /project/.binconfig for a 'dir' setting
        Found dir=scripts
        Using 'scripts' from the config file
      Parsing /project/.binconfig
        Found [one] section
          Registered help for "one"
        Found [two] section
          Registered help for "two"
          Registered alias "deux"
          Registered alias "dos"
        Found [three] section
          Registered help for "three"
          Registered alias "333"
      'exact' defaulted to 'false'
      Bin directory set to '/project/scripts' from config file
      Searching '/project/scripts' for scripts
        Registered command "five"
        Registered command "four"
        Registered command "one"
        Searching subdirectory '/project/scripts/subdir'
        Registered command "subdir six"
        Registered command "three"
        Registered command "two"
      Processing aliases
      Processing positional parameters
        Looking for command "php" (exact)
          There were 0 matches - not running command
        Looking for command "php" (with-extension)
          There were 0 matches - not running command
        Looking for command "php " (prefix)
      No command found - using shim
      Would execute: php -v
      """

    Scenario: Passing --print displays the command that would have been run (1)
      Given a script '/project/bin/sample/hello'
      When I run 'bin --print sample hello world'
      Then it is successful
      And the output is '/project/bin/sample/hello world'

    Scenario: Passing --print displays the command that would have been run (2)
      Given an empty directory '/project/bin'
      When I run 'bin --print --shim php -v'
      Then it is successful
      And the output is 'php -v'

    Scenario: Passing --print displays the command that would have been run (3)
      Given an empty directory '/project/bin'
      When I run 'bin --print php -v'
      Then the exit code is 127
      And there is no output
      And the error is 'bin: Command "php" not found in /project/bin'
