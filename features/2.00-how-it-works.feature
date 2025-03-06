Feature: How It Works

  Rule: Commands can be executed

    | ## How It Works
    |
    | A project just needs a `bin/` folder and some executable scripts - for example:
    |
    | ```
    | repo/
    | ├── bin/
    | │   ├── build
    | │   ├── deploy
    | │   └── hello
    | └── ...
    | ```
    |
    | The scripts can be written in [any language](https://github.com/bin-cli/bin-cli/wiki/Hello%2C-World),
    | or can even be compiled binaries, as long as they are executable (`chmod +x`). Here is a very simple
    | `bin/hello` shell script:
    |
    | ```bash
    | #!/bin/sh
    | echo "Hello, ${1:-World}!"
    | ```
    |
    | To execute it, run:
    |
    | ```
    | $ bin hello
    | Hello, World!
    | ```
    |
    | Now you may be thinking why not just run it directly, like this:
    |
    | ```
    | $ bin/hello
    | ```
    |
    | And that would do the same thing - but Bin will also search in parent directories, so you can use it from anywhere in the project:
    |
    | ```bash
    | $ cd app/Http/Controllers/
    | $ bin/hello                # Doesn't work :-(
    | $ ../../../bin/hello       # Works, but is rather tedious to type :-/
    | $ bin hello                # Still works :-)
    | ```

    Scenario: A script that is in the bin/ directory can be run without parameters
      Given a script '{ROOT}/project/bin/hello' that outputs "Hello, ${1:-World}! [$#]"
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World! [0]'

    Scenario: Scripts can be run with one parameter passed through
      Given a script '{ROOT}/project/bin/hello' that outputs "Hello, ${1:-World}! [$#]"
      When I run 'bin hello everybody'
      Then it is successful
      And the output is 'Hello, everybody! [1]'

    Scenario: Scripts can be run with multiple parameters passed through
      Given a script '{ROOT}/project/bin/hello' that outputs "Hello, ${1:-World}! [$#]"
      When I run 'bin hello everybody two three four'
      Then it is successful
      And the output is 'Hello, everybody! [4]'

    Scenario: The exit code from the command is passed through
      Given a script '{ROOT}/project/bin/fail' with content:
      """sh
      #!/bin/sh
      exit 123
      """
      When I run 'bin fail'
      Then it fails with exit code 123
      And there is no error

    Scenario: The error from the command is passed through
      Given a script '{ROOT}/project/bin/warn' with content:
      """sh
      #!/bin/sh
      echo "Something is wrong" >&2
      """
      When I run 'bin warn'
      Then the exit code is 0
      And there is no output
      And the error is 'Something is wrong'

    Scenario: An error is given if the command doesn't exist
      Given a script '{ROOT}/project/bin/hello'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin other'
      Then it fails with exit code 127
      And the error is "bin: Command 'other' not found in {ROOT}/project/bin/ or {ROOT}/project/.binconfig"


  Rule: Security warning

    | > [!WARNING]
    | > Bin CLI executes arbitrary commands/scripts in the current working directory
    | > (or the directory specified by `--dir`) - the same as if you executed them
    | > directly. You should not run commands from untrusted sources.

  Rule: Commands can be executed when in a subdirectory

    Scenario: Scripts can be run when in a subdirectory
      Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
      And the working directory is '{ROOT}/project/subdirectory'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Scripts can be run when in a sub-subdirectory
      Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
      And the working directory is '{ROOT}/project/subdirectory/sub-subdirectory'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: If no bin/ directory is found, an error is displayed
      When I run 'bin'
      Then it fails with exit code 127
      And the error is "bin: Could not find 'bin/' directory or '.binconfig' file starting from '{ROOT}/project'"
