Feature: CLI arguments

  Rule: Arguments are parsed correctly

    Scenario: '--' can be placed before executable names
      Given a script '{ROOT}/project/bin/--help' that outputs 'Help'
      When I run 'bin -- --help'
      Then it is successful
      And the output is 'Help'

    Scenario: An invalid argument causes an error
      When I run 'bin --invalid'
      Then it fails with exit code 246
      And the error is "bin: Invalid option '--invalid'"

    Scenario Outline: A helpful message is displayed when running the '<command>' command if it is not defined
      Given a script '{ROOT}/project/bin/dummy'
      When I run 'bin <command>'
      Then it fails with exit code 127
      And the error is:
        """
        bin: Command '<command>' not found in {ROOT}/project/bin/ or {ROOT}/project/.binconfig
        Perhaps you meant to run 'bin --<command>'?
        """

      Examples:
        | command    |
        | completion |
        | create     |
        | edit       |
        | help       |
        | info       |
        | version    |

    Scenario Outline: The <arg1> and <arg2> arguments are incompatible
      When I run 'bin <arg1> <arg2>'
      Then it fails with exit code 246
      And the error is "bin: The '<arg1>' and '<arg2>' arguments are incompatible"

      # I haven't bothered to list all combinations here, just a few combinations
      Examples:
        | arg1         | arg2         |
        | --completion | --help       |
        | --edit       | --completion |
        | --help       | --version    |
        | -c           | -h           |
        | -e           | --completion |
        | --help       | -v           |

    Scenario: Specifying the same argument more than once doesn't cause an error
      Given a script '{ROOT}/usr/bin/editor'
      When I run 'bin -h -h --help --help'
      Then it is successful

  Rule: There is a help command

    Scenario: The help message is displayed when using --help
      When I run 'bin --help'
      Then it is successful
      And the output contains 'Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]'

    Scenario: The help message is displayed when using -h
      When I run 'bin -h'
      Then it is successful
      And the output contains 'Usage: bin [OPTIONS] [--] [COMMAND] [ARGUMENTS...]'

  Rule: There is a version command

    Scenario: The version number is displayed when using --version
      When I run 'bin --version'
      Then it is successful
      And the output is 'Bin CLI v1.2.3-dev'

    Scenario: The version number is displayed when using -v
      When I run 'bin -v'
      Then it is successful
      And the output is 'Bin CLI v1.2.3-dev'

  Rule: There is an info command

    Scenario: Project information is displayed when using --info with a bin/ directory
      Given an empty directory '{ROOT}/project/bin'
      When I run 'bin --info'
      Then it is successful
      And the output is:
        """
        Root:    {ROOT}/project/
        Config:  {ROOT}/project/.binconfig (missing)
        Bin Dir: {ROOT}/project/bin/
        """

    Scenario: Project information is displayed when using --info with a .binconfig file
      Given an empty file '{ROOT}/project/.binconfig'
      When I run 'bin --info'
      Then it is successful
      And the output is:
        """
        Root:    {ROOT}/project/
        Config:  {ROOT}/project/.binconfig
        Bin Dir: {ROOT}/project/bin/ (missing)
        """

    Scenario: Project information is displayed when using --info with a custom directory
      Given an empty directory '{ROOT}/project/scripts'
      And a file '{ROOT}/project/.binconfig' with content 'dir = scripts'
      When I run 'bin --info'
      Then it is successful
      And the output is:
        """
        Root:    {ROOT}/project/
        Config:  {ROOT}/project/.binconfig
        Bin Dir: {ROOT}/project/scripts/
        """
