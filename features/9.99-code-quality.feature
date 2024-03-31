Feature: Code quality

  Scenario: Code and tests must be high quality
    * Code coverage must be at least 100%
    * ShellCheck must report no errors
    # If the code size goes over this, I will need to update the wiki:
    # https://github.com/search?q=repo%3Abin-cli%2Fbin-cli+50+KB&type=wikis
    * Code size must be under 50 KB
