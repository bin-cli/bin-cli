Feature: Config files

  Rule: A .binconfig file can exist in the project root

    | ### Config Files
    |
    | Some of the features below require you to create a config file. It should be named `.binconfig` and placed in the project root directory, alongside the `bin/` directory:
    |
    | ```
    | repo/
    | ├── bin/
    | │   └── ...
    | └── .binconfig
    | ```
    |
    | Config files are written in [INI format](https://en.wikipedia.org/wiki/INI_file). Here is an example:
    |
    | ```ini
    | ; Global settings
    | dir = scripts
    | exact = true
    | template = #!/bin/sh\n\n
    |
    | ; Settings for each command (script)
    | [hello]
    | alias = hi
    | args = [name]
    | help = Say "Hello, World!"
    | ```
    |
    | The supported global keys are:
    |
    | - `dir` (string) - Sets a [custom script directory](#custom-script-directory)
    | - `exact` (boolean) - Disables [unique prefix matching](#unique-prefix-matching)
    | - `template` (string) - Sets the template for [scripts created with `--create`](#creating--editing-scripts)
    |
    | The supported per-command keys are:
    |
    | - `alias`/`aliases` (comma-separated strings) - [Aliases](#aliases)
    | - `args` (string) - [List of arguments](#help-text)
    | - `help` (string) - [Help text](#help-text)

    Scenario: Directories above .binconfig are not searched when .binconfig exists
      Given an empty file '{ROOT}/project/root/.binconfig'
      And a script '{ROOT}/project/bin/hello'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin hello'
      Then it fails with exit code 127
      And the error is "bin: Command 'hello' not found in {ROOT}/project/root/bin/ or {ROOT}/project/root/.binconfig"

    Scenario: Directories below .binconfig are not searched when .binconfig exists
      Given an empty file '{ROOT}/project/.binconfig'
      And a script '{ROOT}/project/bin/hello' that outputs 'Right'
      And a script '{ROOT}/project/root/bin/hello' that outputs 'Wrong'
      And the working directory is '{ROOT}/project/root'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Right'

  Rule: .binconfig files are optional

    | COLLAPSE: Do I need to create a `.binconfig` file?
    |
    | No - `.binconfig` only needs to exist if you want to use the features described below.

  Rule: .binconfig formatting rules

    | COLLAPSE: What dialect of INI file is used?
    |
    | The INI file is parsed according to the following rules:
    |
    | - Spaces are allowed around the `=` signs, and are automatically trimmed from the start/end of lines.
    | - Values should not be quoted - quotes will be treated as part of the value. This avoids the need to escape inner quotes.
    | - Boolean values can be set to `true`/`false` (recommended), `yes`/`no`, `on`/`off` or `1`/`0` (all case-insensitive). Anything else triggers an error.
    | - Lines that start with `;` or `#` are comments, which are ignored. No other lines can contain comments.

    Scenario: Spaces around the = sign are optional
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        dir=scripts
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Spaces may appear at the start/end of a key
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        # Indented
          dir = scripts
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Both '#' and ';' denote comments
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        ; Comment 1
        # Comment 2

        dir = scripts
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Comments may be preceeded by white space
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        dir = scripts
          ; Comment 1
          # Comment 2
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Comments may not appear at the end of a value
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [sample1]
        help = Description ; Not a comment

        [sample2]
        help = Description # Not a comment
        """
      And a script '{ROOT}/project/bin/sample1'
      And a script '{ROOT}/project/bin/sample2'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin sample1    Description ; Not a comment
        bin sample2    Description # Not a comment
        """

  Rule: .binconfig can't be inside the bin/ folder

    | COLLAPSE: Why isn't `.binconfig` inside `bin/`?
    |
    | `.binconfig` can't be inside the `bin/` directory because the [`dir` setting](#custom-script-directory) may change the name of the `bin/` directory, creating a chicken-and-egg problem (how would we find it in the first place?).
    |
    | Technically it would be possible to support both locations for every setting _except_ `dir` - and I may if there is demand for it... But then we would have to decide what happens if there are two files - error, or merge them? If merged, how should we handle conflicts? Which one should `bin --edit .binconfig` open? And so on.

  Rule: Invalid key names are ignored

    | COLLAPSE: What happens if an invalid key name is used?
    |
    | Invalid keys are ignored, to allow for forwards-compatibility with future versions of Bin CLI which may support additional settings. (The downside of this is you won't be warned if you make a typo, so I may change this in the future.)
    |
    | Invalid command names are displayed as a warning when you run `bin`, after the command listing.

    Scenario: Unknown keys are ignored for forwards compatibility
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        ignored = global
        dir = scripts

        [command]
        ignored = command
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: A warning is displayed if .binconfig contains a command that doesn't exist
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [my-command]
        help = Description of command
        """
      And a script '{ROOT}/project/bin/sample'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available Commands
        bin sample

        Warning: The following commands listed in .binconfig do not exist:
        [my-command]
        """
