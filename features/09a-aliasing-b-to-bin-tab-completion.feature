Feature: Tab completion for aliasing `b` to `bin`
  https://github.com/bin-cli/bin#tab-completion
  https://github.com/bin-cli/bin#aliasing-b-to-bin

  Scenario: The executable name for tab completion can be overridden with --exe
    When I run 'bin --completion --exe b'
    Then it is successful
    And the output is:
      """
      complete -C "{ROOT}/usr/bin/bin --complete-bash --exe 'b'" -o default b
      """
