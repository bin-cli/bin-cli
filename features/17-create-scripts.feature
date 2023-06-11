Feature: Create scripts
  Not documented yet...

  @undocumented
  Scenario: A new script can be created and opened in the editor set in $VISUAL with '--create'
    Given an empty directory '{ROOT}/project/bin'
    And an environment variable 'VISUAL' set to 'myeditor'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    When I run 'bin --create hello world'
    Then it is successful
    And there is a script '{ROOT}/project/bin/hello/world' with content:
      """
      #!/usr/bin/env bash
      set -eno pipefail


      """
    And the output is:
      """
      Created subdirectory {ROOT}/project/bin/hello/
      Created script {ROOT}/project/bin/hello/world
      EXECUTED: myeditor {ROOT}/project/bin/hello/world
      """

  @undocumented
  Scenario: A new script can be created and opened in the editor set in $VISUAL with '-c'
    Given an empty directory '{ROOT}/project/bin'
    And an environment variable 'VISUAL' set to 'myeditor'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    When I run 'bin --create hello world'
    Then it is successful
    And there is a script '{ROOT}/project/bin/hello/world' with content:
      """
      #!/usr/bin/env bash
      set -eno pipefail


      """
    And the output is:
      """
      Created subdirectory {ROOT}/project/bin/hello/
      Created script {ROOT}/project/bin/hello/world
      EXECUTED: myeditor {ROOT}/project/bin/hello/world
      """

  @undocumented
  Scenario: If the script already exists, an error is displayed
    Given a script '{ROOT}/project/bin/hello/world'
    When I run 'bin --create hello world'
    Then it fails with exit code 246
    And the error is 'bin: {ROOT}/project/bin/hello/world already exists (use --edit to edit it)'

  @undocumented
  Scenario: Unique prefix matching is not used when creating a new file
    Given a script '{ROOT}/project/bin/aaa/bbb'
    And an environment variable 'VISUAL' set to 'myeditor'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    When I run 'bin --create a b'
    Then it is successful
    And there is a script '{ROOT}/project/bin/a/b' with content:
      """
      #!/usr/bin/env bash
      set -eno pipefail


      """
    And the output is:
      """
      Created subdirectory {ROOT}/project/bin/a/
      Created script {ROOT}/project/bin/a/b
      EXECUTED: myeditor {ROOT}/project/bin/a/b
      """

