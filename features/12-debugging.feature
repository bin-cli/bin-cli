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

      [Three]
      help=Three
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
      # TODO: Work out the exact output... And how to handle the version number...
      """
      Bin version 1.2.3
      Working directory is /project/public/
      Looking for a root config file
        /project/public/.binconfig - not found
        /project/.binconfig - found
      Parsing /project/.binconfig
        Root set to /project/scripts/
        Found config for 3 commands
      Searching /project/scripts/ for scripts
        Found 1 subdirectory
        Found 5 commands in this directory
      Searching /project/scripts/subdir/ for scripts
      [...]
      Looking for a script or alias matching 'php' - not found
      Looking for scripts and aliases with the prefix 'php' - 0 found
      Falling back to external 'php' because the --shim option was enabled
      Would execute: php -v
      """

    Scenario: Passing --print displays the command that would have been run (1)
      Given a script '/project/bin/sample/hello'
      When I run 'bin --print sample hello world'
      Then it is successful
      And the output is '/project/bin/sample/hello world'

    Scenario: Passing --print displays the command that would have been run (2)
      Given an empty directory 'bin'
      When I run 'bin --print --shim php -v'
      Then it is successful
      And the output is 'php -v'

    Scenario: Passing --print displays the command that would have been run (3)
      Given an empty directory 'bin'
      When I run 'bin --print php -v'
      Then the exit code is 127
      And there is no output
      And the error is "bin: Executable 'php' not found in /project/bin"
