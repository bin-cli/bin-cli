Feature: Inline commands

  Rule: Short scripts can be defined in .binconfig

    | ### Inline Commands
    |
    | If you have a really short script, you can instead write it as an inline command in `.binconfig`:
    |
    | ```ini
    | [hello]
    | command = echo "Hello, ${1:-World}!"
    |
    | [phpunit]
    | command = "$BIN_ROOT/vendor/bin/phpunit" "$@"
    |
    | [watch]
    | command = "$BIN_DIR/build" --watch "$@"
    | ```

    Scenario: An inline command can be defined in .binconfig
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = echo 'Hello, World!'
        """
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Additional parameters are not automatically passed to the command
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = helper
        """
      And a script '{ROOT}/usr/bin/helper' that outputs '1=$1 2=$2'
      When I run 'bin hello one two'
      Then it is successful
      And the output is '1= 2='

    Scenario: If an inline command conflicts with a script command, an error is raised
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = echo 'Hello, World!'
        """
      And a script '{ROOT}/project/bin/hello'
      When I run 'bin hello'
      Then it fails with exit code 246
      And the error is "bin: The command 'hello' defined in {ROOT}/project/.binconfig line 2 conflicts with an existing command"

    Scenario: Inline commands can have aliases
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        alias = hi
        command = echo 'Hello, World!'
        """
      When I run 'bin hi'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Inline commands are listed alongside regular commands (alphabetically)
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        alias = hi
        command = echo 'Hello, World!'
        """
      And a script '{ROOT}/project/bin/another'
      And a script '{ROOT}/project/bin/zebra'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin another
        bin hello      (alias: hi)
        bin zebra
        """

  Rule: Variables are passed to inline commands

    | The following variables are available:
    |
    | - `$1`, `$2`, ... and `$@` contain the additional arguments, as normal
    | - `$BIN_ROOT` points to the project root directory (where `.binconfig` is found)
    | - `$BIN_DIR` points to the directory containing the scripts (usually `$BIN_ROOT/bin`, unless configured otherwise)
    | - The [standard environment variables](#environment-variables-to-use-in-scripts) listed below

    Scenario: Inline commands can accept positional arguments
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = echo "1=$1 2=$2"
        """
      When I run 'bin hello one two'
      Then it is successful
      And the output is '1=one 2=two'

    Scenario: Additional parameters can be manually automatically passed to the command
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = helper "$@"
        """
      And a script '{ROOT}/usr/bin/helper' that outputs '1=$1 2=$2'
      When I run 'bin hello one two'
      Then it is successful
      And the output is '1=one 2=two'

    Scenario: The root directory is available in $BIN_ROOT
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [test]
        command = echo "BIN_ROOT=$BIN_ROOT"
        """
      When I run 'bin test'
      Then it is successful
      And the output is 'BIN_ROOT={ROOT}/project'

    Scenario: The bin directory is available in $BIN_DIR
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [test]
        command = echo "BIN_DIR=$BIN_DIR"
        """
      When I run 'bin test'
      Then it is successful
      And the output is 'BIN_DIR={ROOT}/project/bin'

    Scenario: The bin command name is available in $BIN_COMMAND
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [test]
        command = echo "BIN_COMMAND=$BIN_COMMAND"
        """
      When I run 'bin test'
      Then it is successful
      And the output is 'BIN_COMMAND=bin test'

    Scenario: The bin executable is available in $BIN_EXE
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [test]
        command = echo "BIN_EXE=$BIN_EXE"
        """
      When I run 'bin test'
      Then it is successful
      And the output is 'BIN_EXE=bin'

  Rule: Inline commands are executed within a Bash shell

    | COLLAPSE: How complex can the command be?
    |
    | The command is executed within a Bash shell (`bash -c "$command"`), so it may contain logic operators (`&&`, `||`), multiple commands separated by `;`, and pretty much anything else that you can fit into a single line.

    Scenario: Inline commands can contain multiple commands
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = echo one; echo two
        """
      When I run 'bin hello'
      Then it is successful
      And the output is:
        """
        one
        two
        """

    Scenario: Inline commands can contain logic
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        command = echo one || echo two
        """
      When I run 'bin hello'
      Then it is successful
      And the output is 'one'

  Rule: Inline commands are not the recommended way to write commands

    | COLLAPSE: Why is this not the standard / recommended way to write commands?
    |
    | If you're using Bin as a replacement for the one-line tasks typically [defined in package.json](https://docs.npmjs.com/cli/commands/npm-run-script), it might seem perfectly natural to write all tasks this way (and you can do that if you want to).
    |
    | However, I generally recommend writing slightly longer, more robust scripts. For example, checking that dependencies are installed before you attempt to do something that requires them, or even [installing them automatically](https://github.com/bin-cli/bin-cli/wiki/Automatically-installing-dependencies). It's hard to do that when you're limited to a single line of code.
    |
    | It also violates this fundamental principle of Bin, listed in the introduction above:
    |
    | > Collaborators / contributors who choose not to install Bin can run the scripts directly, so you can enjoy the benefits without adding a hard dependency or extra barrier to entry.
    |
    | That's why I recommend only using inline commands for very simple commands, such as calling a third-party script installed by a package manager (as in the `phpunit` example) or creating a shorthand for a command that could easily be run directly (as in the `watch` example).
