Feature: Creating/editing scripts

  Rule: There is a command to edit a script

    | ### Creating / Editing Scripts
    |
    | You can use these commands to more easily create/edit scripts in your preferred editor (`$VISUAL` or `$EDITOR`, with `editor`, `nano` or `vi` as fallbacks):
    |
    | ```bash
    | bin --create sample
    | bin --edit sample
    | ```

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

  Rule: There is a command to create a script

    | The `--create` (`-c`) command will pre-fill the script with a typical Bash script template and make it executable.

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

  Rule: The edit command supports unique prefix matching

    | The `--edit` (`-e`) command supports [unique prefix matching](#unique-prefix-matching) (e.g. `bin -e sam`).

    Scenario: A script can be edited using a unique prefix
      Given a script '{ROOT}/project/bin/hello/world'
      And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
      And an environment variable 'VISUAL' set to 'myeditor'
      When I run 'bin --edit h w'
      Then it is successful
      And the output is 'EXECUTED: myeditor {ROOT}/project/bin/hello/world'

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

  Rule: .binconfig files can be created/edited too

    | You can also use `bin --create .binconfig` to create a [config file](#config-files), and `bin --edit .binconfig` to edit it.

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
    #Scenario: .binconfig is pre-filled with the command names
    #  Given a script '{ROOT}/project/bin/hello'
    #  And a script '{ROOT}/project/bin/world'
    #  And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
    #  And an environment variable 'VISUAL' set to 'myeditor'
    #  When I run 'bin --create .binconfig'
    #  Then it is successful
    #  And the output is:
    #    """
    #    Created file {ROOT}/project/.binconfig
    #    EXECUTED: myeditor {ROOT}/project/.binconfig
    #    """
    #  And there is a file '{ROOT}/project/.binconfig' with content:
    #    """
    #    [hello]
    #    help =
    #
    #    [world]
    #    help =
    #    """

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
        dir = scripts
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
        dir = scripts
        """
