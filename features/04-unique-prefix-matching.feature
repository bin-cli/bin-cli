Feature: Unique prefix matching

  Rule: Any unique prefix is enough to run a command

    Scenario: When entering a unique prefix, the matching command is executed
      Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
      When I run 'bin h'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: When entering an ambiguous prefix, the matches are listed
      Given a script '{ROOT}/project/bin/hello'
      And a script '{ROOT}/project/bin/hi'
      And a script '{ROOT}/project/bin/another'
      When I run 'bin h'
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin hello
        bin hi
        """

    Scenario: Unique prefix matching works for directories as well as commands
      Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I run 'bin d l'
      Then it is successful
      And the output is 'Copying to production...'

    Scenario: Unique prefix matching works correctly with a single script in the directory
      # In the old implementation, there was a risk that was executed too soon because "d" is a unique prefix
      # In the new implementation, this is unlikely, but I've kept the test anyway
      Given a script '{ROOT}/project/bin/deploy/live' that outputs "Deploy: $1"
      When I run 'bin d l --force'
      Then it is successful
      And the output is 'Deploy: --force'

    Scenario: Unique prefix matching works for directories when there are multiple matches
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      And a script '{ROOT}/project/bin/dump/config'
      And a script '{ROOT}/project/bin/do-something'
      When I run 'bin d'
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin deploy ...
        bin do-something
        bin dump ...
        """
