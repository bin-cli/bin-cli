Feature: Self-update
  Not documented yet...

  @undocumented
  Scenario: The script can update itself using curl
    Given a script '{ROOT}/usr/bin/curl' with content:
      """
      #!/usr/bin/env bash
      echo '#!/usr/bin/env bash'
      echo "# This is the new script downloaded with: curl $@"
      echo 'echo "Executed with: $@"'
      """
    When I run 'bin --self-update'
    Then it is successful
    And there is a script '{ROOT}/usr/bin/bin' with content:
      """
      #!/usr/bin/env bash
      # This is the new script downloaded with: curl -L https://bin-cli.com/bin
      echo "Executed with: $@"
      """
    And the output is:
      # The curl progress output would be in the middle
      """
      Bin v1.2.3-dev

      Downloading the latest version from https://bin-cli.com/bin


      Updated to:
      Executed with: --version
      """
