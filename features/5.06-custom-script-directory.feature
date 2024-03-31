Feature: Custom script directory

  Rule: The script directory can be renamed from bin/

    | ### Custom Script Directory
    |
    | If you prefer the directory to be named `scripts` (or something else), you can configure that at the top of `.binconfig`:
    |
    | ```ini
    | dir = scripts
    | ```
    |
    | The path is relative to the `.binconfig` file - it won't search any parent or child directories.
    |
    | This option is provided for use in projects that already have a `scripts` directory or similar. I recommend renaming the directory to `bin` if you can, for consistency with the executable name and [standard UNIX naming conventions](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard).

    Scenario: The script directory can be overridden in .binconfig with 'dir'
      Given a file '{ROOT}/project/.binconfig' with content 'dir = scripts'
      And a script '{ROOT}/project/scripts/test' that outputs 'Right'
      And a script '{ROOT}/project/bin/test' that outputs 'Wrong'
      When I run 'bin test'
      Then it is successful
      And the output is 'Right'

    Scenario: An error is raised if the specified directory does not exist
      Given a file '{ROOT}/project/root/.binconfig' with content 'dir = bin'
      And a script '{ROOT}/project/bin/hello'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin hello'
      Then it fails with exit code 246
      And the error is "bin: The directory specified in {ROOT}/project/root/.binconfig line 1 does not exist: {ROOT}/project/root/bin/"

    Scenario: Directories below .binconfig are not searched when 'dir' is specified in .binconfig
      Given a file '{ROOT}/project/.binconfig' with content 'dir = scripts'
      And a script '{ROOT}/project/scripts/test' that outputs 'Right'
      And a script '{ROOT}/project/root/scripts/test' that outputs 'Wrong'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin test'
      Then it is successful
      And the output is 'Right'

    Scenario: The 'dir' option cannot point to a parent directory
      Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      And a file '{ROOT}/project/root/.binconfig' with content 'dir = ../scripts'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin hello'
      Then it fails with exit code 246
      And the error is "bin: The option 'dir' cannot point to a directory outside {ROOT}/project/root in {ROOT}/project/root/.binconfig line 1"

    Scenario: The 'dir' option cannot point to a symlink to a parent directory
      Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      And a symlink '{ROOT}/project/root/symlink' pointing to '../scripts'
      And a file '{ROOT}/project/root/.binconfig' with content 'dir = symlink'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin hello'
      Then it fails with exit code 246
      And the error is "bin: The option 'dir' cannot point to a directory outside {ROOT}/project/root in {ROOT}/project/root/.binconfig line 1"

  Rule: Scripts can be in the project root

    | COLLAPSE: Can I put the scripts in the project root directory?
    |
    | If you have your scripts directly in the project root, you can use this:
    |
    | ```ini
    | dir = .
    | ```
    |
    | However, subcommands will **not** be supported, because that would require searching the whole (potentially [very large](https://i.redd.it/tfugj4n3l6ez.png)) directory tree to find all the scripts.

    Scenario: Scripts can be in the project root
      Given a file '{ROOT}/project/.binconfig' with content 'dir = .'
      And a script '{ROOT}/project/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Subcommands are not supported in the project root
      Given a file '{ROOT}/project/.binconfig' with content 'dir = .'
      And a script '{ROOT}/project/hello/world'
      When I run 'bin hello world'
      Then it fails with exit code 246
      And the error is "bin: Subcommands are not supported with the config option 'dir = .'"

  Rule: The script directory can be set at the command line

    | COLLAPSE: What if I can't create a config file?
    |
    | You can also set the script directory at the command line:
    |
    | ```bash
    | $ bin --dir scripts
    | ```
    |
    | Bin will search the parent directories as normal, but ignore any `.binconfig` files it finds. This is mostly useful to support repositories you don't control.
    |
    | You will probably want to define an alias:
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

    Scenario: Setting the script directory with --dir overrides .binconfig
      Given a script '{ROOT}/project/right/script' that outputs 'Right'
      And a script '{ROOT}/project/root/wrong/script' that outputs 'Wrong'
      And a file '{ROOT}/project/root/.binconfig' with content 'dir = wrong'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin --dir right script'
      Then it is successful
      And the output is 'Right'

    Scenario: When --dir is a relative path, that directory is not expected to exist
      When I run 'bin --dir scripts hello'
      Then it fails with exit code 127
      And the error is "bin: Could not find 'scripts/' directory starting from '{ROOT}/project'"

    Scenario: When --dir matches .binconfig, .binconfig should be parsed as normal
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        dir = scripts

        [hello]
        help = Hello, World!
        """
      And a script '{ROOT}/project/scripts/hello'
      When I run 'bin --dir scripts'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin hello    Hello, World!
        """

    Scenario: When --dir doesn't match .binconfig, .binconfig should be ignored
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [hello]
        help = Hello, World!
        """
      And a script '{ROOT}/project/scripts/hello'
      When I run 'bin --dir scripts'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin hello
        """

  Rule: The script directory can be set to an absolute path at the command line

    | COLLAPSE: Can I use an absolute path?
    |
    | Not in a `.binconfig` file, but you can use an absolute path at the command line. For example, you could put your all generic development tools in `~/bin/dev/` and run them as `dev <script>`:
    |
    | ```bash
    | alias dev="bin --exe dev --dir $HOME/bin/dev"
    | ```

    Scenario: The 'dir' option cannot be an absolute path when set in .binconfig
      Given a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      And a file '{ROOT}/project/.binconfig' with content 'dir = /project/scripts'
      When I run 'bin hello'
      Then it fails with exit code 246
      And the error is "bin: The option 'dir' cannot be an absolute path in {ROOT}/project/.binconfig line 1"

    Scenario: The script directory can be an absolute path when given with --dir
      Given a script '{ROOT}/project/scripts/dev/hello' that outputs 'Hello, World!'
      When I run 'bin --dir {ROOT}/project/scripts/dev hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: When --dir is an absolute path, that directory is expected to exist
      When I run 'bin --dir /missing hello'
      Then it fails with exit code 246
      And the error is "bin: Specified directory '/missing/' is missing"
