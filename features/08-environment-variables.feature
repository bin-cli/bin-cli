Feature: Environment Variables To Use in Scripts

  Rule: $BIN_COMMAND is set to the command name

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

    # TODO: Does this still make sense when using symlink aliases? Perhaps not...
    Scenario: The command name passed is the original command, not the alias
      Given a script '{ROOT}/project/bin/sample' that outputs '$BIN_COMMAND'
      And a symlink '{ROOT}/project/bin/alias' pointing to 'sample'
      When I run 'bin alias'
      Then it is successful
      And the output is 'bin sample'

  Rule: $0 should be used as a fallback for $BIN_COMMAND

    Scenario: It can fall back to the script name when calling the script directly
      Given a script '{ROOT}/project/bin/sample' that outputs 'Usage: ${BIN_COMMAND-$0} [...]'
      When I run 'bin/sample'
      Then it is successful
      And the output is 'Usage: bin/sample [...]'

  Rule: $BIN_EXE is set to the name of the 'bin' executable

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
