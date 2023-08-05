Feature: Unique prefix matching
  https://github.com/bin-cli/bin-cli#unique-prefix-matching

  Scenario: When entering a unique prefix, the matching command is executed
    Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
    When I run 'bin h'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: When entering an ambiguous prefix, the matches are listed
    Given a script '{ROOT}/project/bin/hello'
    And a script '{ROOT}/project/bin/hi'
    And a script '{ROOT}/project/bin/another'
    When I run 'bin h'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      bin hi
      """

  Scenario Template: Unique prefix matching can be disabled in .binconfig using 'exact=<value>'
    Given a script '{ROOT}/project/bin/hello'
    And a file '{ROOT}/project/.binconfig' with content 'exact=<value>'
    When I run 'bin hel'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      """

    Examples:
      | value |
      | true  |
      | TRUE  |
      | on    |
      | yes   |
      | 1     |

  Scenario Template: Unique prefix matching can be explicitly enabled in .binconfig using 'exact=<value>'
    Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
    And a file '{ROOT}/project/.binconfig' with content 'exact=<value>'
    When I run 'bin hel'
    Then it is successful
    And the output is 'Hello, World!'

    Examples:
      | value |
      | false |
      | FALSE |
      | off   |
      | no    |
      | 0     |

  Scenario: Unique prefix matching can be disabled with --exact
    Given a script '{ROOT}/project/bin/hello'
    When I run 'bin --exact hel'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin hello
      """

  Scenario: Unique prefix matching can be enabled with --prefix, overriding the config file
    Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
    And a file '{ROOT}/project/.binconfig' with content 'exact=true'
    When I run 'bin --prefix hel'
    Then it is successful
    And the output is 'Hello, World!'

  Scenario: Unique prefix matching works for directories as well as commands
    Given a script '{ROOT}/project/bin/deploy/live' that outputs 'Copying to production...'
    And a script '{ROOT}/project/bin/deploy/staging'
    When I run 'bin d l'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Unique prefix matching works correctly with a single script in the directory
    # There is a risk that it is executed too soon because "d" is a unique prefix
    Given a script '{ROOT}/project/bin/deploy/live' that outputs "Deploy: $1"
    When I run 'bin d l --force'
    Then it is successful
    And the output is 'Deploy: --force'

  Scenario: Unique prefix matching works for directories when there are multiple matches
    Given a script '{ROOT}/project/bin/deploy/live'
    And a script '{ROOT}/project/bin/deploy/staging'
    And a script '{ROOT}/project/bin/dump/config'
    When I run 'bin d'
    Then it is successful
    And the output is:
      """
      Matching commands
      bin deploy live
      bin deploy staging
      bin dump config
      """
