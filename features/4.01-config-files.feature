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
    | dir=scripts
    | exact=true
    |
    | ; Settings for each command (script)
    | [hello]
    | alias=hi
    | help=Say "Hello, World!"
    |
    | [phpunit]
    | command="$BIN_ROOT/vendor/bin/phpunit" "%@"
    | ```
    |
    | The supported global keys are:
    |
    | - `dir` (string) - Sets a [custom script directory](#custom-script-directory)
    | - `exact` (boolean) - Disables [unique prefix matching](#unique-prefix-matching)
    |
    | The supported per-command keys are:
    |
    | - `alias`/`aliases` (comma-separated strings) - [Aliases](#aliases)
    | - `help` (string) - [Help text](#help-text)
    | - `command` (string) - [Inline commands](#inline-commands)

    Scenario: Directories above .binconfig are not searched when .binconfig exists
      Given an empty file '{ROOT}/project/root/.binconfig'
      And a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
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

    | <details>
    | <summary><em>Do I need to create a <code>.binconfig</code> file?</em></summary>
    |
    | > No - `.binconfig` only needs to exist if you want to use the features described below.
    |
    | </details>

  Rule: .binconfig formatting rules

    | <details>
    | <summary><em>What dialect of INI file is used?</em></summary>
    |
    | > The INI file is parsed according to the following rules:
    | >
    | > - No spaces are allowed before the key names or around the `=` signs. (I may change this in a future release.)
    | > - Values should not be quoted - quotes will be treated as part of the value. This avoids the need to escape inner quotes.
    | > - Boolean values can be set to `true`/`false` (recommended), `yes`/`no`, `on`/`off` or `1`/`0` (case-insensitive). Anything else triggers an error.
    | > - Lines that start with `;` or `#` are comments, which are ignored. No other lines can contain comments.
    |
    | </details>

    Scenario: Both '#' and ';' denote comments
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        ; Comment 1
        # Comment 2

        dir=scripts
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

  Rule: .binconfig can't be inside the bin/ folder

    | <details>
    | <summary><em>Why isn't <code>.binconfig</code> inside <code>bin/</code>?</em></summary>
    |
    | > `.binconfig` can't be inside the `bin/` directory because the [`dir` setting](#custom-script-directory) may change the name of the `bin/` directory, creating a chicken-and-egg problem (how would we find it in the first place?).
    | >
    | > Technically it would be possible to support both locations for every setting _except_ `dir` - and I may if there is demand for it... But then we would have to decide what happens if there are two files - error, or merge them? If merged, how should we handle conflicts? Which one should `bin --edit .binconfig` open? And so on.
    |
    | </details>

  Rule: Invalid key names are ignored

    | <details>
    | <summary><em>What happens if an invalid key name is used?</em></summary>
    |
    | > Invalid keys are ignored, to allow for forwards-compatibility with future versions of Bin CLI which may support additional settings. (The downside of this is you won't be warned if you make a typo, so I may change this in the future.)
    | >
    | > Invalid command names are displayed as a warning when you run `bin`, after the command listing.
    |
    | </details>

    Scenario: Unknown keys are ignored for forwards compatibility
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        ignored=global
        dir=scripts

        [command]
        ignored=command
        """
      And a script '{ROOT}/project/scripts/hello' that outputs 'Hello, World!'
      When I run 'bin hello'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: A warning is displayed if .binconfig contains a command that doesn't exist
      Given a file '{ROOT}/project/.binconfig' with content:
        """
        [my-command]
        help=Description of command
        """
      And a script '{ROOT}/project/bin/sample'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin sample

        Warning: The following commands listed in .binconfig do not exist:
        [my-command]
        """
