Feature: Automatic exclusions

  Rule: Files starting with '.' are ignored

    Scenario: Scripts starting with '.' are excluded from listings
      Given a script '{ROOT}/project/bin/visible'
      And a script '{ROOT}/project/bin/.hidden'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin visible
        """

    Scenario: Scripts starting with '.' cannot be executed
      Given a script '{ROOT}/project/bin/.hidden'
      When I run 'bin .hidden'
      Then it fails with exit code 246
      And the error is "bin: Command names may not start with '.'"

    Scenario: Scripts in directories starting with '.' cannot be executed
      Given a script '{ROOT}/project/bin/.hidden/child'
      When I run 'bin .hidden child'
      Then it fails with exit code 246
      And the error is "bin: Command names may not start with '.'"

  Rule: Files that are not executable are ignored

    Scenario: Files that are not executable are not listed
      Given a script '{ROOT}/project/bin/executable'
      And an empty file '{ROOT}/project/bin/not-executable'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin executable
        """

    Scenario: Files that are not executable cannot be executed
      Given an empty file '{ROOT}/project/bin/not-executable'
      When I run 'bin not-executable'
      Then it fails with exit code 126
      And the error is "bin: '{ROOT}/project/bin/not-executable' is not executable (chmod +x)"

  Rule: Common bin directories are ignored

    Scenario Outline: Common bin directories are ignored when searching parent directories
      Given a script '{ROOT}<bin>/hello'
      And the working directory is '{ROOT}<workdir>'
      When I run 'bin hello'
      Then it fails with exit code 127
      And the error is "bin: Could not find 'bin/' directory starting from '{ROOT}<workdir>' (ignored '{ROOT}<bin>')"

      Examples:
        | bin                   | workdir                   |
        | /bin                  | /example                  |
        | /usr/bin              | /usr/example              |
        | /snap/bin             | /snap/example             |
        | /usr/local/bin        | /usr/local/bin/example    |
        | /home/user/bin        | /home/user/example        |
        | /home/user/.local/bin | /home/user/.local/example |
