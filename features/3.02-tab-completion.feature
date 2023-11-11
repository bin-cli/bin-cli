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
        complete -C "{ROOT}/usr/bin/bin --complete-bash" -o default bin
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
      And a script '{ROOT}/project/bin/another'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [artisan]
        alias = art

        [deploy]
        alias = publish
        """
      When I tab complete 'bin p'
      Then it is successful
      And the output is:
        """
        publish
        """

    Scenario: If both the command and the alias match, only the command is listed in tab completion
      Given a script '{ROOT}/project/bin/deploy'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish
        """
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        deploy
        """

    Scenario: If multiple aliases for the same command match, only one is returned in tab completion
      Given a script '{ROOT}/project/bin/deploy'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [deploy]
        alias = publish
        alias = push
        """
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
    | If you have globally disabled [unique prefix matching](#unique-prefix-matching), e.g. `alias bin='bin --exact'`, add the same parameter here:
    |
    | ```bash
    | # e.g. in /usr/share/bash-completion/completions/bin
    | command -v bin &>/dev/null && eval "$(bin --completion --exact)"
    | ```
    |
    | Similarly, if you are using an alias with a [custom script directory](#custom-script-directory), e.g. `alias src='bin --dir scripts'`, add the same parameter here:
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
        complete -C "{ROOT}/usr/bin/bin --complete-bash --exe 'b'" -o default b
        """

    Scenario: Tab completion supports custom directories
      When I run 'bin --completion --exe scr --dir scripts'
      Then it is successful
      And the output is:
        """
        complete -C "{ROOT}/usr/bin/bin --complete-bash --dir 'scripts' --exe 'scr'" -o default scr
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

  Rule: Exclusions

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

    Scenario: Common non-executable file types are not tab completed in the project root even if they are executable
      Given a file '{ROOT}/project/.binconfig' with content 'dir = .'
      And a script '{ROOT}/project/executable1.sh'
      And a script '{ROOT}/project/executable2.json'
      And a script '{ROOT}/project/executable3.md'
      And a script '{ROOT}/project/executable4.txt'
      And a script '{ROOT}/project/executable5.yaml'
      And a script '{ROOT}/project/executable6.yml'
      When I tab complete 'bin '
      Then it is successful
      And the output is:
        """
        executable1
        """

    Scenario Template: Common bin directories are ignored when tab completing
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

    Scenario Template: Common bin directories are not ignored when tab completing if there is a .binconfig directory in the parent directory
      Given a script '{ROOT}<bin>/hello'
      And an empty file '{ROOT}<config>'
      And the working directory is '{ROOT}<workdir>'
      When I tab complete 'bin h'
      Then it is successful
      And the output is:
        """
        hello
        """

      Examples:
        | bin            | config                | workdir                |
        | /bin           | /.binconfig           | /example               |
        | /usr/bin       | /usr/.binconfig       | /usr/example           |
        | /snap/bin      | /snap/.binconfig      | /snap/example          |
        | /usr/local/bin | /usr/local/.binconfig | /usr/local/bin/example |
        | /home/user/bin | /home/user/.binconfig | /home/user/example     |

  Rule: Other shells are not currently supported

    | COLLAPSE: What about other shells (Zsh, Fish, etc)?
    |
    | Only Bash is supported at this time. I will add other shells if there is [demand for it](https://github.com/bin-cli/bin-cli/discussions/categories/ideas), or gladly accept [pull requests](https://github.com/bin-cli/bin-cli/pulls).
