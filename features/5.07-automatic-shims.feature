Feature: Automatic shims

  Rule: A per-project shim can be created

    | ### Automatic Shims
    |
    | I often use Bin to create shims for other executables - for example, [different PHP versions](https://github.com/bin-cli/bin-cli/wiki/PHP-version-shim) or [running scripts inside Docker](https://github.com/bin-cli/bin-cli/wiki/Docker-shim).
    |
    | Rather than typing `bin php` every time, I use a Bash alias to run it automatically:
    |
    | ```bash
    | alias php='bin php'
    | ```
    |
    | However, that only works when inside a project directory. The `--shim` parameter tells Bin to run the global command of the same name if no local script is found:
    |
    | ```bash
    | alias php='bin --shim php'
    | ```
    |
    | Now typing `php -v` will run `bin/php -v` if available, but fall back to a regular `php -v` if not.

    Scenario: Normally, if the command doesn't exist, Bin returns an error
      Given an empty directory '{ROOT}/project/bin'
      And a script '{ROOT}/usr/bin/php' that outputs 'Hello from PHP'
      When I run 'bin php'
      Then it fails with exit code 127
      And the error is "bin: Command 'php' not found in {ROOT}/project/bin/ or {ROOT}/project/.binconfig"

    Scenario: When specifying --shim, the global command is used as a fallback
      Given an empty directory '{ROOT}/project/bin'
      And a script '{ROOT}/usr/bin/php' that outputs 'Hello from PHP'
      When I run 'bin --shim php'
      Then it is successful
      And the output is 'Hello from PHP'

  Rule: A different fallback command can be specified

    | If you want to run a fallback command that is different to the script name, use `--fallback <command>` instead:
    |
    | ```bash
    | alias php='bin --fallback php8.1 php'
    | ```

    Scenario: When specifying --fallback, the given global command is used as a fallback
      Given an empty directory '{ROOT}/project/bin'
      And a script '{ROOT}/usr/bin/php8.1' that outputs 'Hello from PHP 8.1'
      When I run 'bin --fallback php8.1 php'
      Then it is successful
      And the output is 'Hello from PHP 8.1'

    Scenario: When specifying --fallback=, the given global command is used as a fallback
      Given an empty directory '{ROOT}/project/bin'
      And a script '{ROOT}/usr/bin/php8.1' that outputs 'Hello from PHP 8.1'
      When I run 'bin --fallback=php8.1 php'
      Then it is successful
      And the output is 'Hello from PHP 8.1'

  Rule: Shims disable unique prefix matching

    | Both of these options imply `--exact` - i.e. [unique prefix matching](#unique-prefix-matching) is disabled (otherwise it might call `bin/phpunit`, for example).

    Scenario: Specifying --shim disables unique prefix matching
      Given a script '{ROOT}/project/bin/hello-world-123'
      And a script '{ROOT}/usr/bin/hello-world' that outputs 'Hello, World!'
      When I run 'bin --shim hello-world'
      Then it is successful
      And the output is 'Hello, World!'

    Scenario: Specifying --fallback disables unique prefix matching
      Given a script '{ROOT}/project/bin/hello-world-123'
      And a script '{ROOT}/usr/bin/my-fallback' that outputs 'Hello, World!'
      When I run 'bin --fallback my-fallback hello-world'
      Then it is successful
      And the output is 'Hello, World!'
