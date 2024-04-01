Feature: Listing commands

  Rule: Commands can be listed

    | ### Listing Commands
    |
    | If you run `bin` on its own, it will list all available commands:
    |
    | <pre>
    | $ bin hel
    | <strong>Available Commands</strong>
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
        Available Commands
        bin another
        bin hello
        """

    Scenario: If there are no scripts, it outputs "None found"
      Given an empty directory '{ROOT}/project/bin'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        None found
        """

  Rule: Help text is also supported

    | COLLAPSE: Can I add descriptions to the commands?
    |
    | Yes - see [Help text](#help-text), below.
