Feature: Aliasing `b` to `bin`

  Rule: Aliases can be created in Bash

    | ### Aliasing the `bin` Command
    |
    | If you prefer to shorten the script prefix from `bin` to `b`, for example, you can create an alias in your shell's config. For example, in `~/.bashrc`:
    |
    | ```bash
    | alias b='bin --exe b'
    | ```
    |
    | The `--exe` parameter is used to override the executable name used in the [environment variables](#environment-variables-to-use-in-scripts) (`$BIN_COMMAND`, `$BIN_EXE`) and the [list of commands](#listing-commands):
    |
    | <pre>
    | $ b
    | <strong>Available Commands</strong>
    | b hello
    | </pre>
    |
    | You can skip it (i.e. use `alias b='bin'`) if you prefer it to say `bin`.

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

    | COLLAPSE: Alternatively, you can use a symlink
    |
    | System-wide installation:
    |
    | ```bash
    | $ sudo ln -s bin /usr/local/bin/b
    | ```
    |
    | Per-user installation:
    |
    | ```bash
    | $ ln -s bin ~/.local/bin/b
    | ```

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
