Feature: Tab completion for automatic exclusions
  https://github.com/bin-cli/bin#tab-completion
  https://github.com/bin-cli/bin#automatic-exclusions

  Scenario: Scripts starting with '_' are excluded from tab completion
    Given a script '/project/bin/visible'
    And a script '/project/bin/_hidden'
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      visible
      """

  Scenario: Scripts starting with '_' can be tab completed by typing the prefix
    Given a script '/project/bin/_hidden'
    When I tab complete 'bin _'
    Then it is successful
    And the output is:
      """
      _hidden
      """

  Scenario: Scripts containing '_' are not excluded from tab completion
    Given a script '/project/bin/not_hidden'
    When I tab complete 'bin not'
    Then it is successful
    And the output is:
      """
      not_hidden
      """

  Scenario: Subcommands starting with '_' are excluded from tab completion
    Given a script '/project/bin/sub/visible'
    And a script '/project/bin/sub/_hidden'
    When I tab complete 'bin sub '
    Then it is successful
    And the output is:
      """
      visible
      """

  Scenario: Parent commands are tab completed even if they only have hidden subcommands
    Given a script '/project/bin/sub/_hidden'
    When I tab complete 'bin s'
    Then it is successful
    And the output is:
      """
      sub
      """

  Scenario: Subcommands starting with '_' can be tab completed by typing the prefix
    Given a script '/project/bin/sub/_hidden'
    When I tab complete 'bin sub _'
    Then it is successful
    And the output is:
      """
      _hidden
      """

  Scenario: Directories starting with '_' are excluded from tab completion
    Given a script '/project/bin/visible'
    And a script '/project/bin/_sub/child'
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      visible
      """

  Scenario: Commands in directories starting with '_' can be tab completed
    Given a script '/project/bin/_sub/child'
    When I tab complete 'bin _sub '
    Then it is successful
    And the output is:
      """
      child
      """

  Scenario: Scripts starting with '.' are excluded from tab completion
    Given a script '/project/bin/visible'
    And a script '/project/bin/.hidden'
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      visible
      """

  Scenario: Scripts starting with '.' cannot be tab completed
    Given a script '/project/bin/.hidden'
    When I tab complete 'bin .h'
    Then it is successful
    And there is no output

  Scenario: Files that are not executable are not tab completed
    Given a script '/project/bin/executable'
    And an empty file '/project/bin/not-executable'
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      executable
      """

  Scenario: Common non-executable file types are not tab completed in the project root even if they are executable
    Given a file '/project/.binconfig' with content 'dir=.'
    And a script '/project/executable1.sh'
    And a script '/project/executable2.json'
    And a script '/project/executable3.md'
    And a script '/project/executable4.txt'
    And a script '/project/executable5.yaml'
    And a script '/project/executable6.yml'
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      executable1
      """

  Scenario Template: Common bin directories are ignored when tab completing
    Given a script '<bin>/hello'
    And the working directory is '<workdir>'
    When I tab complete 'bin h'
    Then it is successful
    And there is no output

    Examples:
      | bin            | workdir                |
      | /bin           | /example               |
      | /usr/bin       | /usr/example           |
      | /snap/bin      | /snap/example          |
      | /usr/local/bin | /usr/local/bin/example |
      | /home/user/bin | /home/user/example     |

  Scenario Template: Common bin directories are not ignored when tab completing if there is a .binconfig directory in the parent directory
    Given a script '<bin>/hello'
    And an empty file '<config>'
    And the working directory is '<workdir>'
    When I tab complete 'bin h'
    Then it is successful
    And the output is:
      """
      hello
      """

    Examples:
      | bin            | config                | workdir                |
      | /bin           | /.binconfig           | /example               |
      | /usr/bin       | /usr/.binconfig       | /usr/example           |
      | /snap/bin      | /snap/.binconfig      | /snap/example          |
      | /usr/local/bin | /usr/local/.binconfig | /usr/local/bin/example |
      | /home/user/bin | /home/user/.binconfig | /home/user/example     |
