Feature: Tab completion for custom script directories
  https://github.com/bin-cli/bin#tab-completion
  https://github.com/bin-cli/bin#custom-script-directory

  Scenario: Tab completion supports custom directories
    When I run 'bin --completion --exe scr --dir scripts'
    Then it is successful
    And the output is:
      """
      complete -C "/usr/bin/bin --complete-bash --dir 'scripts' --exe 'scr'" -o default scr
      """

  Scenario: Tab completion works for custom directories
    Given a file '/project/.binconfig' with content 'dir=scripts'
    And a script '/project/scripts/right'
    And a script '/project/bin/wrong'
    When I tab complete 'bin'
    Then it is successful
    And the output is:
      """
      right
      """
