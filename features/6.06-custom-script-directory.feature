Feature: Custom script directory

  Rule: The script directory can be set at the command line

    | ### Custom Script Directory
    |
    | You can override the directory name at the command line:
    |
    | ```bash
    | $ bin --dir scripts
    | ```
    |
    | This is mostly useful to support repositories you don't control. You will probably want to use an alias such as:
    |
    | ```bash
    | alias scr='bin --exe scr --dir scripts'
    | ```

    Scenario: The script directory can be configured with --dir
      Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin --dir scripts hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: The script directory can be configured with --dir=
      Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin --dir=scripts hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: When --dir is a relative path, that directory is not expected to exist
      When I run 'bin --dir scripts hello'
      Then it fails with exit code 127
      And the error is "bin: Could not find 'scripts/' directory starting from '{ROOT}/project'"

    Scenario: When --dir is a relative path, the 'not found' error is adapted accordingly
      Given a script '{ROOT}/project/scripts/hello'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin --dir scripts other'
      Then it fails with exit code 127
      And the error is "bin: Command 'other' not found in {ROOT}/project/scripts/"

  Rule: The script directory can be set to an absolute path at the command line

    | You can also use an absolute path - for example, you could put your all generic development tools in `~/.local/bin/dev/` and run them as `dev <script>`:
    |
    | ```bash
    | alias dev="bin --exe dev --dir $HOME/.local/bin/dev"
    | ```

    Scenario: The script directory given by --dir can be an absolute path
      Given a script '{ROOT}/project/scripts/dev/hello' that outputs 'Hello, World!'
      When I run 'bin --dir {ROOT}/project/scripts/dev hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: When --dir is an absolute path, that directory is expected to exist
      When I run 'bin --dir /missing hello'
      Then it fails with exit code 246
      And the error is "bin: Specified directory '/missing/' is missing"

    Scenario: When --dir is an absolute path, the 'not found' error should be adapted accordingly
      Given a script '{ROOT}/project/scripts/dev/hello'
      When I run 'bin --dir {ROOT}/project/scripts/dev other'
      Then it fails with exit code 127
      And the error is "bin: Command 'other' not found in {ROOT}/project/scripts/dev/"
