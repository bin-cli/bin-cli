Feature: Edge cases

  Rule: Missing options are handled correctly

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

  Rule: Spaces (and other unusual characters) are allowed in command names (though not recommended)

    Scenario: Spaces in command names are allowed
      Given a script '{ROOT}/project/bin/hello world' that outputs 'Hello, World!'
      When I run 'bin "hello world"'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Commands containing spaces are quoted in listings
      Given a script '{ROOT}/project/bin/hello world'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin hello\ world
        """

    Scenario: Spaces in directory names are allowed
      Given a script '{ROOT}/project/bin/my directory/hello world' that outputs 'Hello, World!'
      When I run 'bin "my directory" "hello world"'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Commands containing spaces are quoted in listings
      Given a script '{ROOT}/project/bin/my directory/hello world'
      When I run 'bin "my directory"'
      Then it is successful
      And the output is:
        """
        Available Subcommands
        bin my\ directory hello\ world
        """
