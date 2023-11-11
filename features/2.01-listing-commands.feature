Feature: Listing commands

  Rule: Commands can be listed

    | ### Listing Commands
    |
    | If you run `bin` on its own, it will list all available commands:
    |
    | <pre>
    | $ bin hel
    | <strong>Available commands</strong>
    | bin build
    | bin deploy
    | bin hello
    | </pre>

    Scenario: If you run 'bin' on its own, it will list all available scripts
      Given a script '{ROOT}/project/bin/hello'
      And a script '{ROOT}/project/bin/another'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin another
        bin hello
        """

    Scenario: If there are no scripts, it outputs "None found"
      Given an empty directory '{ROOT}/project/bin'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        None found
        """
