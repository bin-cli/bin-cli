Feature: Environment Variables To Use in Scripts

  Rule: $BIN_COMMAND

    | ### Environment Variables To Use in Scripts
    |
    | Bin will set the environment variable `$BIN_COMMAND` to the command that was executed, for use in help messages:
    |
    | ```bash
    | echo "Usage: ${BIN_COMMAND-$0} [...]"
    | ```
    |
    | For example, if you ran `bin sample -h`, it would be set to `bin sample`, so would output:
    |
    | ```
    | Usage: bin sample [...]
    | ```

    Scenario: The command name is passed in an environment variable
      Given a script '{ROOT}/project/bin/sample' that outputs 'Usage: $BIN_COMMAND [...]'
      When I run 'bin sample'
      Then it is successful
      And the output is 'Usage: bin sample [...]'

    Scenario: The command name passed is the original command, not the unique prefix
      Given a script '{ROOT}/project/bin/sample' that outputs '$BIN_COMMAND'
      When I run 'bin s'
      Then it is successful
      And the output is 'bin sample'

    Scenario: The command name passed is the original command, not the alias
      Given a script '{ROOT}/project/bin/sample' that outputs '$BIN_COMMAND'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [sample]
        alias=alias
        """
      When I run 'bin alias'
      Then it is successful
      And the output is 'bin sample'

  Rule: $BIN_COMMAND fallback

    | But if you ran the script manually with `bin/sample -h`, it would output the fallback from `$0` instead:
    |
    | ```
    | Usage: bin/sample [...]
    | ```

    Scenario: It can fall back to the script name when calling the script directly
      Given a script '{ROOT}/project/bin/sample' that outputs 'Usage: ${BIN_COMMAND-$0} [...]'
      When I run 'bin/sample'
      Then it is successful
      And the output is 'Usage: bin/sample [...]'

  Rule: $BIN_EXE

    | There is also `$BIN_EXE`, which is set to the name of the executable (typically just `bin`, but that [may be overridden](#aliasing-the-bin-command)).

    Scenario: The `bin` executable name is passed in an environment variable
      Given a script '{ROOT}/project/bin/sample' that outputs 'You used: $BIN_EXE'
      When I run 'bin sample'
      Then it is successful
      And the output is 'You used: bin'

    Scenario: The alternative executable name is passed in an environment variable when aliased
      Given a script '{ROOT}/project/bin/sample' that outputs 'You used: $BIN_EXE'
      When I run 'bin --exe other sample'
      Then it is successful
      And the output is 'You used: other'
