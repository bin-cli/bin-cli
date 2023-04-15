Feature: Tab completion
  https://github.com/bin-cli/bin#tab-completion

  Scenario: A tab completion script is available for Bash
    When I run 'bin --completion'
    Then it is successful
    And the output contains '_bin()'
    And the output contains 'complete -F _bin bin'
