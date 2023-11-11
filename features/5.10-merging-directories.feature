Feature: Merging Directories

  Rule: Commands can be merged with a parent directory

    | ### Merging Directories
    |
    | Occasionally, you may want to define commands that are specific to a certain subdirectory, without losing access to the main (parent) project commands.
    |
    | For example, you may have several different themes, each with its own `build` command:
    |
    | ```
    | repo/                  ← parent project
    | ├── bin/
    | │   └── deploy
    | └── themes/
    |     └── one/           ← child project
    |         ├── bin/
    |         │   └── build
    |         └── .binconfig
    | ```
    |
    | Normally, if you are in the `themes/one/` directory:
    |
    | - `bin build` runs `themes/one/bin/build`
    | - `bin deploy` gives an error, because the parent directory is ignored
    |
    | But if you add this to `.binconfig` (in the child project):
    |
    | ```ini
    | merge=true
    | ```
    |
    | Then the two `bin/` directories are merged, so:
    |
    | - `bin build` still runs `themes/one/bin/build`
    | - `bin deploy` runs `bin/deploy`

    Scenario Template: Commands can be merged with the immediate parent bin/ directory with 'merge=<value>
      Given a file '{ROOT}/project/subdir/.binconfig' with content 'merge=<value>'
      And a script '{ROOT}/project/subdir/bin/child'
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child
        bin parent
        """

      Examples:
        | value |
        | true  |
        | TRUE  |
        | on    |
        | yes   |
        | 1     |

    Scenario: Commands from the parent directory can be executed
      Given a file '{ROOT}/project/subdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/bin/child'
      And a script '{ROOT}/project/bin/parent' that outputs 'Hello, parent!'
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin parent'
      Then it is successful
      And the output is 'Hello, parent!'

    Scenario: Commands can be merged with a higher level bin/ directory
      Given a file '{ROOT}/project/subdir/subsubdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/subsubdir/bin/grandchild'
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir/subsubdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin grandchild
        bin parent
        """

    Scenario: Help text is merged from the relevant config file
      Given a file '{ROOT}/project/subdir/.binconfig' with content:
        """
        merge=true

        [child]
        help=Child help
        """
      And a script '{ROOT}/project/subdir/bin/child'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [parent]
        help=Parent help
        """
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child     Child help
        bin parent    Parent help
        """

    Scenario: Any other value for 'merge=' raises an error
      Given a file '{ROOT}/project/.binconfig' with content 'merge=blah'
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: Invalid value for 'merge' in {ROOT}/project/.binconfig line 1: blah"

    Scenario Template: Common bin directories are ignored when searching parent directories to merge with 'merge=true'
      Given a file '{ROOT}<workdir>/.binconfig' with content 'merge=true'
      And a script '{ROOT}<workdir>/bin/child'
      And a script '{ROOT}<bin>/parent'
      And the working directory is '{ROOT}<workdir>'
      When I run 'bin hello'
      Then it fails with exit code 246
      And the error is "bin: Could not find 'bin/' directory or '.binconfig' file starting from '{ROOT}<root>' (merge=true) (ignored '{ROOT}<bin>')"

      Examples:
        | root       | bin            | workdir            |
        |            | /bin           | /example           |
        | /usr       | /usr/bin       | /usr/example       |
        | /snap      | /snap/bin      | /snap/example      |
        | /usr/local | /usr/local/bin | /usr/local/example |
        | /home/user | /home/user/bin | /home/user/example |

    Scenario Template: Common bin directories are ignored when searching parent directories to merge with 'merge=optional'
      Given a file '{ROOT}<workdir>/.binconfig' with content 'merge=optional'
      And a script '{ROOT}<workdir>/bin/child'
      And a script '{ROOT}<bin>/parent'
      And the working directory is '{ROOT}<workdir>'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child
        """

      Examples:
        | bin            | workdir            |
        | /bin           | /example           |
        | /usr/bin       | /usr/example       |
        | /snap/bin      | /snap/example      |
        | /usr/local/bin | /usr/local/example |
        | /home/user/bin | /home/user/example |

    Scenario: Using '--create' should create a script in the lowest level bin/ directory
      Given an environment variable 'VISUAL' set to 'myeditor'
      And a script '{ROOT}/usr/bin/myeditor' that outputs 'EXECUTED: myeditor "$@"'
      And a file '{ROOT}/project/subdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin --create child'
      Then it is successful
      And the output is:
        """
        Created script {ROOT}/project/subdir/bin/child
        EXECUTED: myeditor {ROOT}/project/subdir/bin/child
        """
      And there is a script '{ROOT}/project/subdir/bin/child' with content:
        """
        #!/usr/bin/env bash
        set -euo pipefail


        """

    Scenario: Error messages should reference the lowest level bin/ directory and .binconfig file
      Given a file '{ROOT}/project/subdir/.binconfig' with content 'merge=true'
      And an empty directory '{ROOT}/project/subdir/bin'
      And an empty directory '{ROOT}/project/bin'
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin hello'
      Then it fails with exit code 127
      And the error is "bin: Command 'hello' not found in {ROOT}/project/subdir/bin/ or {ROOT}/project/subdir/.binconfig"

  Rule: There can't be any conflicts between directories

    | COLLAPSE: Can child project commands override parent project commands?
    |
    | No - any conflicts will be reported as an error, the same as if they were defined at the same level (e.g. by defining a command and an alias with the same name).
    |
    | This is mostly because it would make the conflict-checking code too complex - but it has the benefit of enforcing simplicity (parent commands work from anywhere, and accidental conflicts are reported).

    Scenario: If a child project command conflicts with a parent project command, an error is raised
      Given a file '{ROOT}/project/subdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/bin/mycommand'
      And a script '{ROOT}/project/bin/mycommand'
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: The command 'mycommand' defined in {ROOT}/project/bin/mycommand conflicts with an existing command"

  Rule: Merging works with inline commands

    | COLLAPSE: Does this work with inline commands and aliases?
    |
    | Yes - you can use any combination of scripts, inline commands and aliases in both the parent and child projects.

    Scenario: Commands can be merged with a higher level .binconfig
      Given a file '{ROOT}/project/subdir/subsubdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/subsubdir/bin/grandchild'
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [parent]
        command=inline command
        """
      And the working directory is '{ROOT}/project/subdir/subsubdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin grandchild
        bin parent
        """

    Scenario: Inline commands with no bin/ directories can be merged
      Given a file '{ROOT}/project/subdir/.binconfig' with content:
        """
        merge=true

        [child]
        command=inline command
        """
      And a file '{ROOT}/project/.binconfig' with content:
        """
        [parent]
        command=inline command
        """
      And the working directory is '{ROOT}/project/subdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child
        bin parent
        """

  Rule: The parent directory must exist, unless merge=optional

    | COLLAPSE: What if no parent project is found?
    |
    | If you set `merge=true` but there is no parent `bin/` directory (or `.binconfig` file), Bin will exit with an error.
    |
    | To avoid that, set `merge=optional` instead. This may be useful in sub-projects that have separate repositories, so you can't guarantee they will be cloned together.

    Scenario: If the parent directory doesn't exist and 'merge=true', an error is raised
      Given a file '{ROOT}/project/.binconfig' with content 'merge=true'
      When I run 'bin'
      Then it fails with exit code 246
      And the error is "bin: Could not find 'bin/' directory or '.binconfig' file starting from '{ROOT}' (merge=true)"

    Scenario: If the parent directory doesn't exist and 'merge=optional', no error is raised
      Given a file '{ROOT}/project/.binconfig' with content 'merge=optional'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        None found
        """

  Rule: More than two levels can be merged

    | COLLAPSE: Can three (or more) directories be merged?
    |
    | Yes - just set `merge=true` at each level below the first.

    Scenario: A third level can be merged if enabled
      Given a file '{ROOT}/project/subdir/subsubdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/subsubdir/bin/grandchild'
      And a file '{ROOT}/project/subdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/bin/child'
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir/subsubdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child
        bin grandchild
        bin parent
        """

    Scenario: The third level is not merged if it was not explicitly enabled
      Given a file '{ROOT}/project/subdir/subsubdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/subsubdir/bin/grandchild'
      And an empty file '{ROOT}/project/subdir/.binconfig'
      And a script '{ROOT}/project/subdir/bin/child'
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir/subsubdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child
        bin grandchild
        """

    Scenario Template: The third level is not merged if 'merge=<value>
      Given a file '{ROOT}/project/subdir/subsubdir/.binconfig' with content 'merge=true'
      And a script '{ROOT}/project/subdir/subsubdir/bin/grandchild'
      And a file '{ROOT}/project/subdir/.binconfig' with content 'merge=<value>'
      And a script '{ROOT}/project/subdir/bin/child'
      And a script '{ROOT}/project/bin/parent'
      And the working directory is '{ROOT}/project/subdir/subsubdir'
      When I run 'bin'
      Then it is successful
      And the output is:
        """
        Available commands
        bin child
        bin grandchild
        """

      Examples:
        | value |
        | false |
        | FALSE |
        | off   |
        | no    |
        | 0     |
