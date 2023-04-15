Feature: Handling errors in scripts

  This isn't explained anywhere, but it is implied that error codes from the
  script and stderr are passed through unchanged.

  Scenario: The exit code from the command is passed through
    Given a script '/project/bin/fail' with content:
      """sh
      #!/bin/sh
      exit 123
      """
    When I run 'bin fail'
    Then the exit code is 123
    And there is no output
    And there is no error

  Scenario: The error from the command is passed through
    Given a script '/project/bin/warn' with content:
      """sh
      #!/bin/sh
      echo "Something is wrong" >&2
      """
    When I run 'bin warn'
    Then the exit code is 0
    And there is no output
    And the error is 'Something is wrong'
