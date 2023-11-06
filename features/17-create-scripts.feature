Feature: Create scripts
  Not documented yet...

  Scenario: A new script can be created and opened in the editor set in $VISUAL with '--create'
    Given an empty directory '{ROOT}/project/bin'
    And an environment variable 'VISUAL' set to 'myeditor'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    When I run 'bin --create hello world'
    Then it is successful
    And the output is:
      """
      Created script {ROOT}/project/bin/hello/world
      EXECUTED: myeditor {ROOT}/project/bin/hello/world
      """
    And there is a script '{ROOT}/project/bin/hello/world' with content:
      """
      #!/usr/bin/env bash
      set -euo pipefail


      """

  Scenario: A new script can be created and opened in the editor set in $VISUAL with '-c'
    Given an empty directory '{ROOT}/project/bin'
    And an environment variable 'VISUAL' set to 'myeditor'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    When I run 'bin --create hello world'
    Then it is successful
    And the output is:
      """
      Created script {ROOT}/project/bin/hello/world
      EXECUTED: myeditor {ROOT}/project/bin/hello/world
      """
    And there is a script '{ROOT}/project/bin/hello/world' with content:
      """
      #!/usr/bin/env bash
      set -euo pipefail


      """

  Scenario: If the script already exists, an error is displayed
    Given a script '{ROOT}/project/bin/hello/world'
    When I run 'bin --create hello world'
    Then it fails with exit code 246
    And the error is 'bin: {ROOT}/project/bin/hello/world already exists (use --edit to edit it)'

  Scenario: Unique prefix matching is not used when creating a new file
    Given a script '{ROOT}/project/bin/aaa/bbb'
    And an environment variable 'VISUAL' set to 'myeditor'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    When I run 'bin --create a b'
    Then it is successful
    And the output is:
      """
      Created script {ROOT}/project/bin/a/b
      EXECUTED: myeditor {ROOT}/project/bin/a/b
      """
    And there is a script '{ROOT}/project/bin/a/b' with content:
      """
      #!/usr/bin/env bash
      set -euo pipefail


      """

  Scenario: Scripts starting with '.' cannot be created
    Given an empty directory '{ROOT}/project/bin'
    When I run 'bin --create .hidden'
    Then it fails with exit code 246
    And the error is "bin: Command names may not start with '.'"

  Scenario: Scripts in a directory starting with '.' cannot be created
    Given an empty directory '{ROOT}/project/bin'
    When I run 'bin --create .hidden script'
    Then it fails with exit code 246
    And the error is "bin: Command names may not start with '.'"

  Scenario: Running '--create .binconfig' creates a .binconfig file
    Given an empty directory '{ROOT}/project/bin'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --create .binconfig'
    Then it is successful
    And the output is:
      """
      Created file {ROOT}/project/.binconfig
      EXECUTED: myeditor {ROOT}/project/.binconfig
      """
    And there is a file '{ROOT}/project/.binconfig' with content:
      """
      """

  # TODO
#  Scenario: .binconfig is pre-filled with the command names
#    Given a script '{ROOT}/project/bin/hello'
#    And a script '{ROOT}/project/bin/world'
#    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
#    And an environment variable 'VISUAL' set to 'myeditor'
#    When I run 'bin --create .binconfig'
#    Then it is successful
#    And the output is:
#      """
#      Created file {ROOT}/project/.binconfig
#      EXECUTED: myeditor {ROOT}/project/.binconfig
#      """
#    And there is a file '{ROOT}/project/.binconfig' with content:
#      """
#      [hello]
#      help=
#
#      [world]
#      help=
#      """

  Scenario: Running '--create .binconfig' gives an error if .binconfig already exists
    Given an empty directory '{ROOT}/project/bin'
    And an empty file '{ROOT}/project/.binconfig'
    When I run 'bin --create .binconfig'
    Then it fails with exit code 246
    And the error is 'bin: {ROOT}/project/.binconfig already exists (use --edit to edit it)'

  Scenario: If a directory is specified when creating a config file, it is written to the file
    Given an empty directory '{ROOT}/project/scripts'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --dir scripts --create .binconfig'
    Then it is successful
    And the output is:
      """
      Created file {ROOT}/project/.binconfig
      EXECUTED: myeditor {ROOT}/project/.binconfig
      """
    And there is a file '{ROOT}/project/.binconfig' with content:
      """
      dir=scripts
      """

  Scenario: If an absolute directory is specified when creating a config file, a relative path is written to the file
    Given an empty directory '{ROOT}/project/scripts'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --dir {ROOT}/project/scripts --create .binconfig'
    Then it is successful
    And the output is:
      """
      Created file {ROOT}/project/.binconfig
      EXECUTED: myeditor {ROOT}/project/.binconfig
      """
    And there is a file '{ROOT}/project/.binconfig' with content:
      """
      dir=scripts
      """
