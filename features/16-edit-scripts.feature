Feature: Edit scripts
  Not documented yet...

  @undocumented
  Scenario: A script can be opened in the editor set in $VISUAL using '--edit'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: A script can be opened in the editor set in $VISUAL using '-e'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin -e hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: A script can be opened in the editor set in $VISUAL without giving the extension
    Given a script '{ROOT}/project/bin/hello/world.sh'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world.sh'

  @undocumented
  Scenario: A script can be opened in the editor set in $VISUAL using a unique prefix
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit h w'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: If both $VISUAL and $EDITOR are set, $VISUAL takes precedence
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And a script '{ROOT}/usr/bin/fallbackeditor'
    And an environment variable 'VISUAL' set to 'myeditor'
    And an environment variable 'EDITOR' set to 'fallbackeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: If $VISUAL is not set, $EDITOR is used
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/fallbackeditor' that outputs 'EXECUTED: fallbackeditor "$@"'
    And an environment variable 'EDITOR' set to 'fallbackeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: fallbackeditor {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: If neither $VISUAL nor $EDITOR are set, it tries the global 'editor' command
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/editor' that outputs 'EXECUTED: editor "$@"'
    And a script '{ROOT}/usr/bin/nano'
    And a script '{ROOT}/usr/bin/vi'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: editor {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: If 'editor' is not available, it will try 'nano'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/nano' that outputs 'EXECUTED: nano "$@"'
    And a script '{ROOT}/usr/bin/vi'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: nano {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: If 'nano' is not available, it will try 'vi'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/vi' that outputs 'EXECUTED: vi "$@"'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: vi {ROOT}/project/bin/hello/world'

  @undocumented
  Scenario: If no editor is available, it will display an error message
    Given a script '{ROOT}/project/bin/hello/world'
    When I run 'bin --edit hello world'
    Then it fails with exit code 246
    And the error is 'bin: No editor configured - please export EDITOR or VISUAL environment variables'

  @undocumented
  Scenario: If the script doesn't exist when using '--edit', an error is given
    Given an empty directory '{ROOT}/project/bin'
    When I run 'bin --edit hello world'
    Then it fails with exit code 127
    And the error is "bin: Command 'hello' not found in {ROOT}/project/bin"

  @undocumented
  Scenario: Scripts starting with '.' cannot be edited
    Given a script '{ROOT}/project/bin/.hidden'
    When I run 'bin --edit .hidden'
    Then it fails with exit code 246
    And the error is "bin: Command names may not start with '.'"

  @undocumented
  Scenario: Scripts in a directory starting with '.' cannot be edited
    Given a script '{ROOT}/project/bin/.hidden/script'
    When I run 'bin --edit .hidden script'
    Then it fails with exit code 246
    And the error is "bin: Command names may not start with '.'"

  @undocumented
  Scenario: Running '--edit .binconfig' edits the .binconfig file if it exists
    Given an empty directory '{ROOT}/project/bin'
    And an empty file '{ROOT}/project/.binconfig'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit .binconfig'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/.binconfig'

  @undocumented
  Scenario: Running '--edit .binconfig' gives an error if .binconfig doesn't exist
    Given an empty directory '{ROOT}/project/bin'
    When I run 'bin --edit .binconfig'
    Then it fails with exit code 246
    And the error is 'bin: No .binconfig file found (use --create to create one)'

  # TODO: Handle --dir
