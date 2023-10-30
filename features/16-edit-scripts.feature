Feature: Edit scripts
  Not documented yet...

  Scenario: A script can be opened in the editor set in $VISUAL using '--edit'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  Scenario: A script can be opened in the editor set in $VISUAL using '-e'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin -e hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  Scenario: A script can be opened in the editor set in $VISUAL without giving the extension
    Given a script '{ROOT}/project/bin/hello/world.sh'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world.sh'

  Scenario: A script can be opened in the editor set in $VISUAL using a unique prefix
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit h w'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  Scenario: If both $VISUAL and $EDITOR are set, $VISUAL takes precedence
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And a script '{ROOT}/usr/bin/fallbackeditor'
    And an environment variable 'VISUAL' set to 'myeditor'
    And an environment variable 'EDITOR' set to 'fallbackeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

  Scenario: If $VISUAL is not set, $EDITOR is used
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/fallbackeditor' that outputs 'EXECUTED: fallbackeditor "$@"'
    And an environment variable 'EDITOR' set to 'fallbackeditor'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: fallbackeditor {ROOT}/project/bin/hello/world'

  Scenario: If neither $VISUAL nor $EDITOR are set, it tries the global 'editor' command
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/editor' that outputs 'EXECUTED: editor "$@"'
    And a script '{ROOT}/usr/bin/nano'
    And a script '{ROOT}/usr/bin/vi'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: editor {ROOT}/project/bin/hello/world'

  Scenario: If 'editor' is not available, it will try 'nano'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/nano' that outputs 'EXECUTED: nano "$@"'
    And a script '{ROOT}/usr/bin/vi'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: nano {ROOT}/project/bin/hello/world'

  Scenario: If 'nano' is not available, it will try 'vi'
    Given a script '{ROOT}/project/bin/hello/world'
    And a script '{ROOT}/usr/bin/vi' that outputs 'EXECUTED: vi "$@"'
    When I run 'bin --edit hello world'
    Then it is successful
    And the output is 'EXECUTED: vi {ROOT}/project/bin/hello/world'

  Scenario: If no editor is available, it will display an error message
    Given a script '{ROOT}/project/bin/hello/world'
    When I run 'bin --edit hello world'
    Then it fails with exit code 246
    And the error is 'bin: No editor configured - please export EDITOR or VISUAL environment variables'

  Scenario: If the script doesn't exist when using '--edit', an error is given
    Given an empty directory '{ROOT}/project/bin'
    When I run 'bin --edit hello world'
    Then it fails with exit code 127
    And the error is "bin: Command 'hello' not found in {ROOT}/project/bin/ or {ROOT}/project/.binconfig"

  Scenario: Scripts starting with '.' cannot be edited
    Given a script '{ROOT}/project/bin/.hidden'
    When I run 'bin --edit .hidden'
    Then it fails with exit code 246
    And the error is "bin: Command names may not start with '.'"

  Scenario: Scripts in a directory starting with '.' cannot be edited
    Given a script '{ROOT}/project/bin/.hidden/script'
    When I run 'bin --edit .hidden script'
    Then it fails with exit code 246
    And the error is "bin: Command names may not start with '.'"

  Scenario: Running '--edit .binconfig' edits the .binconfig file if it exists
    Given an empty directory '{ROOT}/project/bin'
    And an empty file '{ROOT}/project/.binconfig'
    And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    And an environment variable 'VISUAL' set to 'myeditor'
    When I run 'bin --edit .binconfig'
    Then it is successful
    And the output is 'EXECUTED: myeditor {ROOT}/project/.binconfig'

  Scenario: Running '--edit .binconfig' gives an error if .binconfig doesn't exist
    Given an empty directory '{ROOT}/project/bin'
    When I run 'bin --edit .binconfig'
    Then it fails with exit code 246
    And the error is 'bin: No .binconfig file found (use --create to create one)'

  Scenario: Running '--edit .binconfig' with a conflicting '--dir' gives an error
    Given an empty directory '{ROOT}/project/bin'
    And an empty directory '{ROOT}/project/scripts'
    And an empty file '{ROOT}/project/.binconfig'
    When I run 'bin --dir scripts --edit .binconfig'
    Then it fails with exit code 246
    And the error is 'bin: .binconfig belongs to bin/ not scripts/'
