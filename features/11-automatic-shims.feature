Feature: Automatic shims
  https://github.com/bin-cli/bin#automatic-shims

  Scenario: Normally, if the command doesn't exist, Bin returns an error
    Given an empty directory '{ROOT}/project/bin'
    And a script '{ROOT}/usr/bin/php' that outputs 'Hello from PHP'
    When I run 'bin php'
    Then it fails with exit code 127
    And the error is "bin: Command 'php' not found in {ROOT}/project/bin"

  Scenario: When specifying --shim, the global command is used as a fallback
    Given an empty directory '{ROOT}/project/bin'
    And a script '{ROOT}/usr/bin/php' that outputs 'Hello from PHP'
    When I run 'bin --shim php'
    Then it is successful
    And the output is 'Hello from PHP'

  Scenario: When specifying --fallback, the given global command is used as a fallback
    Given an empty directory '{ROOT}/project/bin'
    And a script '{ROOT}/usr/bin/php8.1' that outputs 'Hello from PHP 8.1'
    When I run 'bin --fallback php8.1 php'
    Then it is successful
    And the output is 'Hello from PHP 8.1'

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
