Feature: Basics
  https://github.com/bin-cli/bin#how-it-works

  Background:
    Given a script '/project/bin/hello' with content:
      """sh
      #!/bin/sh
      echo "Hello, ${1:-World}! [$#]"
      """

  Scenario: A script that is in the bin/ directory can be run without parameters
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World! [0]'

  Scenario: Scripts can be run with one parameter passed through
    When I run 'bin hello everybody'
    Then it is successful
    And the output is 'Hello, everybody! [1]'

  Scenario: Scripts can be run with multiple parameters passed through
    When I run 'bin hello everybody two three four'
    Then it is successful
    And the output is 'Hello, everybody! [4]'

  Scenario: Scripts can be run when in a subdirectory
    Given the working directory is '/project/subdirectory'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World! [0]'

  Scenario: Scripts can be run when in a sub-subdirectory
    Given the working directory is '/project/subdirectory/sub-subdirectory'
    When I run 'bin hello'
    Then it is successful
    And the output is 'Hello, World! [0]'
