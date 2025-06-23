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
    | ```
    |
    | The supported keys are:
    |
    | - `dir` (string) - Sets a [custom script directory](#custom-script-directory)

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

  Rule: .binconfig can't be inside the bin/ folder

    | COLLAPSE: Why isn't `.binconfig` inside `bin/`?
    |
    | `.binconfig` can't be inside the `bin/` directory because the [`dir` setting](#custom-script-directory) may change the name of the `bin/` directory, creating a chicken-and-egg problem (how would we find it in the first place?).

  Rule: Invalid key names are ignored

    | COLLAPSE: What happens if an invalid key name is used?
    |
    | Invalid keys are ignored, to allow for forwards-compatibility with future versions of Bin CLI which may support additional settings. (The downside of this is you won't be warned if you make a typo, so I may change this in the future.)
    |
    | Invalid command names are displayed as a warning when you run `bin`, after the command listing.

    Scenario: Unknown keys are ignored for forwards compatibility
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        ignored = value
        dir = scripts
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'
