Feature: Unique prefix matching

  Rule: Any unique prefix is enough to run a command

    | ### Unique Prefix Matching
    |
    | Any unique prefix is enough to run a command - so if `bin/hello` is the only script starting with `h`, all of these will work too:
    |
    | ```bash
    | $ bin hell
    | $ bin hel
    | $ bin he
    | $ bin h
    | ```
    |
    | This also works with subcommands - e.g. `bin dep prod` might run `bin/deploy/production`.
    |
    | If you type a prefix that isn't unique, Bin will display a list of matches instead:
    |
    | <pre>
    | $ bin hel
    | <strong>Matching Commands</strong>
    | bin hello
    | bin help
    | </pre>

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
        Matching Commands
        bin hello
        bin hi
        """

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
        Matching Commands
        bin deploy live
        bin deploy staging
        bin dump config
        """

  Rule: Unique prefix matching can be disabled

    | COLLAPSE: How can I disable unique prefix matching?
    |
    | If you prefer to disable unique prefix matching, use `--exact` on the command line:
    |
    | ```bash
    | bin --exact hello
    | ```
    |
    | You'll probably want to set up a shell alias rather than typing it manually:
    |
    | ```bash
    | alias bin='bin --exact'
    | ```
    |
    | To disable it for a project, add this at the top of [`.binconfig`](#config-files):
    |
    | ```ini
    | exact = true
    | ```
    |
    | To enable it again, overriding the config file, use `--no-exact` or `--prefix`:
    |
    | ```bash
    | bin --no-exact hel
    | bin --prefix hel
    | ```
    |
    | Again, you'll probably want to set up a shell alias:
    |
    | ```bash
    | alias bin='bin --no-exact'
    | ```

    Scenario Outline: Unique prefix matching can be disabled in .binconfig using 'exact = <value>'
      Given a script '{ROOT}/project/bin/hello'
      And a file '{ROOT}/project/.binconfig' with content 'exact = <value>'
      When I run 'bin hel'
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin hello
        """

      Examples:
        | value |
        | true  |
        | TRUE  |
        | on    |
        | yes   |
        | t     |
        | y     |
        | 1     |

    Scenario Outline: Unique prefix matching can be explicitly enabled in .binconfig using 'exact = <value>'
      Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
      And a file '{ROOT}/project/.binconfig' with content 'exact = <value>'
      When I run 'bin hel'
      Then it is successful
      And the output is 'Hello, World!'

      Examples:
        | value |
        | false |
        | FALSE |
        | off   |
        | no    |
        | f     |
        | n     |
        | 0     |

    Scenario: Any other value for 'exact' raises an error
      Given a script '{ROOT}/project/bin/hello'
      And a file '{ROOT}/project/.binconfig' with content 'exact = blah'
      When I run 'bin hel'
      Then it fails with exit code 246
      And the error is "bin: Invalid value for 'exact' in {ROOT}/project/.binconfig: blah"

    Scenario: Unique prefix matching can be disabled with --exact
      Given a script '{ROOT}/project/bin/hello'
      When I run 'bin --exact hel'
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin hello
        """

    Scenario Outline: Unique prefix matching can be enabled with <argument>, overriding the config file
      Given a script '{ROOT}/project/bin/hello' that outputs 'Hello, World!'
      And a file '{ROOT}/project/.binconfig' with content 'exact = true'
      When I run 'bin <argument> hel'
      Then it is successful
      And the output is 'Hello, World!'

      Examples:
        | argument   |
        | --prefix   |
        | --no-exact |

    Scenario: When unique prefix matching is disabled, matching subcommands are listed
      Given a script '{ROOT}/project/bin/hello/world'
      And a script '{ROOT}/project/bin/hello/other'
      When I run 'bin --exact hel world'
      # TODO: Is this the most logical behaviour? Perhaps it should filter the
      #  results using the remaining arguments... Or just for a 'Not found'
      #  error instead of displaying anything at all?
      Then it is successful
      And the output is:
        """
        Matching Commands
        bin hello other
        bin hello world
        """
