Feature: Script extensions
  https://github.com/bin-cli/bin#script-extensions

  Scenario: Scripts with extensions are listed without the extensions
    Given a script '/project/bin/sample1.sh'
    Given a script '/project/bin/sample2.py'
    Given a script '/project/bin/sample3.rb'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin sample1
      bin sample2
      bin sample3
      """

  Scenario: Scripts are listed with the extension if there are conflicts
    Given a script '/project/bin/sample1.py'
    And a script '/project/bin/sample1.sh'
    And a script '/project/bin/sample2.py'
    And a script '/project/bin/sample2a.py'
    And a script '/project/bin/sample3'
    And a script '/project/bin/sample3.py'
    And a script '/project/bin/sample4.py'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin sample1.py
      bin sample1.sh
      bin sample2
      bin sample2a
      bin sample3
      bin sample3.py
      bin sample4
      """

  Scenario: Scripts can be executed without the extension
    Given a script '/project/bin/sample1.sh' that outputs 'Hello, World!'
    When I run 'bin sample1'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Scripts can be executed with the extension
    Given a script '/project/bin/sample1.sh' that outputs 'Hello, World!'
    When I run 'bin sample1.sh'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Scripts cannot be executed without the extension if there are conflicts
    Given a script '/project/bin/sample1.sh'
    And a script '/project/bin/sample1.py'
    And a script '/project/bin/sample2.py'
    And a script '/project/bin/sample3.rb'
    When I run 'bin sample1'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin sample1.py
      bin sample1.sh
      """

  Scenario: Aliases are taken into account when checking for conflicts
    Given a script '/project/bin/sample1.sh'
    And a script '/project/bin/sample2'
    And a file '/project/.binconfig' with content:
      """
      [sample2]
      alias=sample1
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin sample1.sh
      bin sample2       (alias: sample1)
      """

  @undocumented
  Scenario: Multiple extensions may be removed from the filename
    Given a script '/project/bin/sample1.blah.sh'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin sample1
      """
