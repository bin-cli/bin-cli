Feature: Aliasing `b` to `bin`

  Rule: Aliases can be created in Bash

    Scenario: The executable name can be overridden with --exe
      Given a script '{ROOT}/project/bin/hello'
      When I run 'bin --exe b'
      Then it is successful
      And the output is:
        """
        Available Commands
        b hello
        """

    Scenario: The executable name can be overridden with --exe=
      Given a script '{ROOT}/project/bin/hello'
      When I run 'bin --exe=b'
      Then it is successful
      And the output is:
        """
        Available Commands
        b hello
        """

  Rule: Symlinks to bin work the same as aliases

    # This doesn't work with kcov because $0 is set to 'bin' instead of 'b', though I'm not sure why
    @disable-kcov
    Scenario: The correct executable name is output when using a symlink
      Given a symlink '{ROOT}/usr/bin/b' pointing to 'bin'
      And a script '{ROOT}/project/bin/hello'
      When I run 'b'
      Then it is successful
      And the output is:
        """
        Available Commands
        b hello
        """
