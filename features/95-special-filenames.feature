Feature: Special filenames
  The readme doesn't list any restrictions on filenames (other than the prefix),
  so it is reasonable to assume that anything that is a valid filename should work.

  Scenario: Filenames may contain spaces
    Given a script '/project/bin/hello world' that outputs 'Hello, World!'
    When I run 'bin "hello world"'
    Then it is successful
    And the output is 'Hello, World!'
