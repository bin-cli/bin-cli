Feature: Code quality

  Scenario: Code and tests must be high quality
    * Code coverage must be at least 100%
    * ShellCheck must report no errors
    # If the code size goes over this, I will need to update the wiki:
    # https://github.com/bin-cli/bin-cli/wiki/Just-vs-Bin-CLI
    # https://github.com/bin-cli/bin-cli/wiki/Task-vs-Bin-CLI
    * Code size must be under 100 KB
