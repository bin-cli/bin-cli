Feature: Automatic shims
  https://github.com/bin-cli/bin#automatic-shims

  Scenario: Normally, if the command doesn't exist, Bin returns an error
    Given an empty directory 'bin'
    And a script '/usr/bin/php' that outputs 'Hello from PHP'
    When I run 'bin php'
    Then the exit code is 127
    And there is no output
    And the error is "Executable 'php' not found in /project/bin"

  Scenario: When specifying --shim, the global command is used as a fallback
    Given an empty directory 'bin'
    And a script '/usr/bin/php' that outputs 'Hello from PHP'
    When I run 'bin --shim php'
    Then it is successful
    And the output is 'Hello from PHP'

  Scenario: When specifying --fallback, the given global command is used as a fallback
    Given an empty directory 'bin'
    And a script '/usr/bin/php8.1' that outputs 'Hello from PHP 8.1'
    When I run 'bin --fallback php8.1 php'
    Then it is successful
    And the output is 'Hello from PHP 8.1'

  Scenario: Specifying --shim disables unique prefix matching
    Given a script '/project/bin/hello-world-123'
    When I run 'bin --shim hello-world'
    Then the exit code is 127
    And there is no output
    And the error is "Executable 'hello-world' not found in /project/bin"


  Scenario: Specifying --fallback disables unique prefix matching
    Given a script '/project/bin/hello-world-123'
    And a script '/usr/bin/my-fallback' that outputs 'Hello, World!'
    When I run 'bin --fallback my-fallback hello-world'
    Then it is successful
    And the output is 'Hello, World!'
