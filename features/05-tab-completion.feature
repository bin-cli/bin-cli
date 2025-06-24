Feature: Tab completion

  Rule: Tab completion works

    Scenario: A tab completion script is available for Bash
      When I run 'bin --completion'
      Then it is successful
      And the output is:
        """
        complete -C "bin --complete-bash" -o default bin
        """

    Scenario: Tab completion works for simple commands
      Given a script '{ROOT}/project/bin/hello'
      When I tab complete 'bin h'
      Then it is successful
      And the output is:
        """
        hello
        """

    Scenario: Tab completion works for multiple matching commands
      Given a script '{ROOT}/project/bin/hello'
      Given a script '{ROOT}/project/bin/hi'
      When I tab complete 'bin h'
      Then it is successful
      And the output is:
        """
        hello
        hi
        """

    Scenario: Tab completion works for directories with partial match
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I tab complete 'bin d'
      Then it is successful
      And the output is:
        """
        deploy
        """

    Scenario: Tab completion works for directories with full match
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I tab complete 'bin deploy'
      Then it is successful
      And the output is:
        """
        deploy
        """

    Scenario: Tab completion works for subcommands with blank parameter
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I tab complete 'bin deploy '
      Then it is successful
      And the output is:
        """
        live
        staging
        """

    Scenario: Tab completion works for subcommands with partial match
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I tab complete 'bin deploy l'
      Then it is successful
      And the output is:
        """
        live
        """

    Scenario: Tab completion works for subcommands with full match
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I tab complete 'bin deploy live'
      Then it is successful
      And the output is:
        """
        live
        """

    Scenario: Tab completion works with the cursor in the middle of the string
      Given a script '{ROOT}/project/bin/deploy/live'
      And a script '{ROOT}/project/bin/deploy/staging'
      When I tab complete 'bin d|eploy '
      Then it is successful
      And the output is:
        """
        deploy
        """

    Scenario: Nothing is output for parameters after the last command
      Given a script '{ROOT}/project/bin/deploy/live'
      When I tab complete 'bin deploy live '
      Then it is successful
      And there is no output

    Scenario: Tab completion works for aliases
      Given a script '{ROOT}/project/bin/deploy'
      And a script '{ROOT}/project/bin/artisan'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      And a symlink '{ROOT}/project/bin/art' pointing to 'artisan'
      When I tab complete 'bin p'
      Then it is successful
      And the output is:
        """
        publish
        """

    Scenario: If both the command and the alias match, only the command is listed in tab completion
      Given a script '{ROOT}/project/bin/deploy'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        deploy
        """

    Scenario: If multiple aliases for the same command match, only one is returned in tab completion
      Given a script '{ROOT}/project/bin/deploy'
      And a symlink '{ROOT}/project/bin/publish' pointing to 'deploy'
      And a symlink '{ROOT}/project/bin/push' pointing to 'deploy'
      When I tab complete 'bin p'
      Then it is successful
      And the output is:
        """
        publish
        """

  Rule: Tab completion works with custom (Bash) aliases

    Scenario: The executable name for tab completion can be overridden with --exe
      When I run 'bin --completion --exe b'
      Then it is successful
      And the output is:
        """
        complete -C "bin --exe 'b' --complete-bash" -o default b
        """

    Scenario: Tab completion supports custom directories
      When I run 'bin --completion --exe scr --dir scripts'
      Then it is successful
      And the output is:
        """
        complete -C "bin --exe 'scr' --dir 'scripts' --complete-bash" -o default scr
        """

    Scenario: Tab completion works for custom directories
      And a script '{ROOT}/project/scripts/right'
      And a script '{ROOT}/project/bin/wrong'
      When I tab complete 'scr ' with arguments "--dir 'scripts' --exe 'scr'"
      Then it is successful
      And the output is:
        """
        right
        """

  Rule: Various files are excluded from tab completion

    Scenario: Scripts starting with '.' are excluded from tab completion
      Given a script '{ROOT}/project/bin/visible'
      And a script '{ROOT}/project/bin/.hidden'
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        visible
        """

    Scenario: Scripts starting with '.' cannot be tab completed
      Given a script '{ROOT}/project/bin/.hidden'
      When I tab complete 'bin .h'
      Then it is successful
      And there is no output

    Scenario: Directories starting with '.' cannot be tab completed
      Given a script '{ROOT}/project/bin/.hidden/command'
      When I tab complete 'bin .h'
      Then it is successful
      And there is no output

    Scenario: Files that are not executable are not tab completed
      Given a script '{ROOT}/project/bin/executable'
      And an empty file '{ROOT}/project/bin/not-executable'
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        executable
        """

    Scenario Outline: Common bin directories are ignored when tab completing
      Given a script '{ROOT}<bin>/hello'
      And the working directory is '{ROOT}<workdir>'
      When I tab complete 'bin h'
      Then it is successful
      And there is no output

      Examples:
        | bin            | workdir                |
        | /bin           | /example               |
        | /usr/bin       | /usr/example           |
        | /snap/bin      | /snap/example          |
        | /usr/local/bin | /usr/local/bin/example |
        | /home/user/bin | /home/user/example     |

  Rule: Options are supported in tab completion

    Scenario Outline: Tab completion works after '<option>'
      Given a script '{ROOT}/project/bin/hello'
      When I tab complete 'bin <option> h'
      Then it is successful
      And the output is:
        """
        hello
        """

      Examples:
        | option               |
        | --exe something      |
        | --exe=something      |
        | --                   |

    Scenario Outline: Tab completion works after '<option>' and changes the directory
      And a script '{ROOT}/project/scripts/right'
      And a script '{ROOT}/project/bin/wrong'
      When I tab complete 'bin <option> '
      Then it is successful
      And the output is:
        """
        right
        """

      Examples:
        | option        |
        | --dir scripts |
        | --dir=scripts |

    Scenario Outline: Tab completion aborts after '<option>'
      Given a script '{ROOT}/project/bin/hello'
      When I tab complete 'bin <option> h'
      Then it is successful
      And there is no output

      Examples:
        | option          |
        | --complete-bash |
        | --completion    |
        | -h              |
        | --help          |
        | --invalid       |
        | -v              |
        | --version       |

    Scenario: Option names can be tab-completed (all)
      When I tab complete 'bin -'
      Then it is successful
      And the output is:
        """
        --completion
        --dir
        --exe
        --help
        -h
        --version
        -v
        --
        """

    Scenario: Option names can be tab-completed (long options)
      When I tab complete 'bin --'
      Then it is successful
      And the output is:
        """
        --completion
        --dir
        --exe
        --help
        --version
        --
        """

    Scenario: Option names can be tab-completed (partial match)
      When I tab complete 'bin --e'
      Then it is successful
      And the output is:
        """
        --exe
        """

    Scenario: Option names are not tab-completed after '--'
      When I tab complete 'bin -- -'
      Then it is successful
      And there is no output
