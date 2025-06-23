Feature: Tab completion

  Rule: Tab completion works

    | ### Tab Completion
    |
    | To enable tab completion in Bash, add this:
    |
    | ```bash
    | command -v bin &>/dev/null && eval "$(bin --completion)"
    | ```
    |
    | To any of the following files:
    |
    | - `/usr/share/bash-completion/completions/bin` (recommended for system-wide installs)
    | - `/etc/bash_completion.d/bin`
    | - `~/.local/share/bash-completion/completions/bin` (recommended for per-user installs)
    | - `~/.bash_completion`
    | - `~/.bashrc`

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

    | COLLAPSE: How to use tab completion with custom aliases?
    |
    | If you are using a simple [shell alias](#aliasing-the-bin-command), e.g. `alias b=bin`, update the filename to match and add `--exe <name>`:
    |
    | ```bash
    | # e.g. in /usr/share/bash-completion/completions/b
    | command -v bin &>/dev/null && eval "$(bin --completion --exe b)"
    | ```
    |
    | If you are using an alias with a [custom script directory](#custom-script-directory), e.g. `alias scr='bin --dir scripts'`, add the same parameter here:
    |
    | ```bash
    | # e.g. in /usr/share/bash-completion/completions/scr
    | command -v bin &>/dev/null && eval "$(bin --completion --exe scr --dir scripts)"
    | ```
    |
    | If you have multiple aliases, just create a file for each one (or put them all together in `~/.bash_completion` or `~/.bashrc`).

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

  Rule: The completion script needs to be run through 'eval'

    | COLLAPSE: Why use `eval`?
    |
    | Using `eval` makes it more future-proof - in case I need to change how tab completion works in the future.
    |
    | If you prefer, you can manually run `bin --completion` and paste the output into the file instead.

  Rule: Various files are excluded from tab completion

    Scenario: Scripts starting with '_' are excluded from tab completion
      Given a script '{ROOT}/project/bin/visible'
      And a script '{ROOT}/project/bin/_hidden'
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        visible
        """

    Scenario: Scripts starting with '_' can be tab completed by typing the prefix
      Given a script '{ROOT}/project/bin/_hidden'
      When I tab complete 'bin _'
      Then it is successful
      And the output is:
        """
        _hidden
        """

    Scenario: Scripts containing '_' are not excluded from tab completion
      Given a script '{ROOT}/project/bin/not_hidden'
      When I tab complete 'bin not'
      Then it is successful
      And the output is:
        """
        not_hidden
        """

    Scenario: Subcommands starting with '_' are excluded from tab completion
      Given a script '{ROOT}/project/bin/sub/visible'
      And a script '{ROOT}/project/bin/sub/_hidden'
      When I tab complete 'bin sub '
      Then it is successful
      And the output is:
        """
        visible
        """

    Scenario: Parent commands are tab completed even if they only have hidden subcommands
      Given a script '{ROOT}/project/bin/sub/_hidden'
      When I tab complete 'bin s'
      Then it is successful
      And the output is:
        """
        sub
        """

    Scenario: Subcommands starting with '_' can be tab completed by typing the prefix
      Given a script '{ROOT}/project/bin/sub/_hidden'
      When I tab complete 'bin sub _'
      Then it is successful
      And the output is:
        """
        _hidden
        """

    Scenario: Directories starting with '_' are excluded from tab completion
      Given a script '{ROOT}/project/bin/visible'
      And a script '{ROOT}/project/bin/_sub/child'
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        visible
        """

    Scenario: Commands in directories starting with '_' can be tab completed
      Given a script '{ROOT}/project/bin/_sub/child'
      When I tab complete 'bin _sub '
      Then it is successful
      And the output is:
        """
        child
        """

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

  Rule: Other shells are not currently supported

    | COLLAPSE: What about other shells (Zsh, Fish, etc)?
    |
    | Only Bash is supported at this time. I will add other shells if there is [demand for it](https://github.com/bin-cli/bin-cli/issues/12), or gladly accept [pull requests](https://github.com/bin-cli/bin-cli/pulls).
