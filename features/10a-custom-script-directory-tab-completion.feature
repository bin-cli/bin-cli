Feature: Tab completion for custom script directories
  https://github.com/bin-cli/bin-cli#tab-completion
  https://github.com/bin-cli/bin-cli#custom-script-directory

  Scenario: Tab completion supports custom directories
    When I run 'bin --completion --exe scr --dir scripts'
    Then it is successful
    And the output is:
      """
      complete -C "{ROOT}/usr/bin/bin --complete-bash --dir 'scripts' --exe 'scr'" -o default scr
      """

  Scenario: Tab completion works for custom directories
    Given a file '{ROOT}/project/.binconfig' with content 'dir=scripts'
    And a script '{ROOT}/project/scripts/right'
    And a script '{ROOT}/project/bin/wrong'
    When I tab complete 'bin '
    Then it is successful
    And the output is:
      """
      right
      """
