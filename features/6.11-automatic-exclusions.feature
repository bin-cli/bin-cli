Feature: Automatic exclusions

  Rule: Certain files and directories are automatically excluded

    | ### Automatic Exclusions
    |
    | Scripts starting with `_` (underscore) are excluded from listings, but can still be executed. This can be used for hidden tools and helper scripts that are not intended to be executed directly. (Or you could use a separate [`libexec` directory](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s07.html) in the project root if you prefer.)

    Scenario: Scripts starting with '_' are excluded from listings
      Given a script '{ROOT}/project/bin/visible'
      And a script '{ROOT}/project/bin/_hidden'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin visible
        """

    Scenario: Scripts starting with '_' can be executed
      Given a script '{ROOT}/project/bin/_hidden' that outputs 'Hidden script'
      When I run 'bin _hidden'
      Then it is successful
      And the output is 'Hidden script'

    Scenario: Subcommands starting with '_' are excluded from listings of subcommands
      Given a script '{ROOT}/project/bin/sub/visible'
      And a script '{ROOT}/project/bin/sub/_hidden'
      When I run 'bin sub'
      Then it is successful
      And the output is:
        """
        Available Subcommands
        bin sub visible
        """

    Scenario: Subcommands starting with '_' are not executed even if they are the only match
      Given a script '{ROOT}/project/bin/sub/_hidden'
      When I run 'bin s'
      Then it is successful
      And the output is:
        """
        Matching Commands
        None found
        """

    Scenario: Subcommands starting with '_' are excluded from listings of partial matches
      Given a script '{ROOT}/project/bin/sub/visible'
      And a script '{ROOT}/project/bin/sub/_hidden'
      When I run 'bin s'
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin sub visible
        """

    Scenario: Subcommands starting with '_' can be executed
      Given a script '{ROOT}/project/bin/sub/_hidden' that outputs 'Hidden script'
      When I run 'bin sub _hidden'
      Then it is successful
      And the output is 'Hidden script'

    Scenario: Directories starting with '_' are excluded from listings
      Given a script '{ROOT}/project/bin/visible'
      And a script '{ROOT}/project/bin/_sub/child'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin visible
        """

    Scenario: Commands in directories starting with '_' can be executed
      Given a script '{ROOT}/project/bin/_sub/child' that outputs 'Hidden script'
      When I run 'bin _sub child'
      Then it is successful
      And the output is 'Hidden script'

    Scenario: Commands in directories starting with '_' are listed when the directory name is given
      Given a script '{ROOT}/project/bin/_sub/child'
      Given a script '{ROOT}/project/bin/_sub/_hidden'
      When I run 'bin _sub'
      Then it is successful
      And the output is:
        """
        Available Subcommands
        bin _sub child
        """

    Scenario: Commands in directories starting with '_' are listed when the prefix is given
      Given a script '{ROOT}/project/bin/_sub/child'
      And a script '{ROOT}/project/bin/_sub/_hidden'
      When I run 'bin _'
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin _sub child
        """

  Rule: Files starting with '.' are ignored

    | Files starting with `.` (dot / period) are always ignored and cannot be executed with Bin.

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

    Scenario: Scripts in directories starting with '_' can be executed
      Given a script '{ROOT}/project/bin/.hidden/child'
      When I run 'bin .hidden child'
      Then it fails with exit code 246
      And the error is "bin: Command names may not start with '.'"

  Rule: Files that are not executable are listed as warnings

    | Files that are not executable (not `chmod +x`) are listed as warnings in the command listing, and will error if you try to run them. The exception is when using `dir = .`, where they are just ignored.

    Scenario: Files that are not executable are listed as warnings
      Given a script '{ROOT}/project/bin/executable'
      And an empty file '{ROOT}/project/bin/not-executable'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin executable

        Warning: The following files are not executable (chmod +x):
        {ROOT}/project/bin/not-executable
        """

    Scenario: Files that are not executable cannot be executed
      Given an empty file '{ROOT}/project/bin/not-executable'
      When I run 'bin not-executable'
      Then it fails with exit code 126
      And the error is "bin: '{ROOT}/project/bin/not-executable' is not executable (chmod +x)"

  Rule: Common bin directories are ignored

    | The directories `/bin`, `/snap/bin`, `/usr/bin`, `/usr/local/bin`, `$HOME/bin` and `$HOME/.local/bin` are ignored when searching parent directories, because they are common locations for global executables (typically in `$PATH`).

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
