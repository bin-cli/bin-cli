Feature: Self-update
  Not documented yet...

  @undocumented
  Scenario: The script can update itself using wget
    Given a script '{ROOT}/usr/bin/wget' with content:
      """
      #!/usr/bin/env bash
      (
        echo '#!/usr/bin/env bash'
        echo "# This is the new script downloaded with: wget $1 $2 ..."
        echo 'echo "Executed with: $@"'
      ) > "$3"
      """
    When I run 'bin --self-update'
    Then it is successful
    And there is a script '{ROOT}/usr/bin/bin' with content:
      """
      #!/usr/bin/env bash
      # This is the new script downloaded with: wget https://bin-cli.com/bin -O ...
      echo "Executed with: $@"
      """
    And the output is:
      # The wget progress output would be in the middle
      """
      Bin CLI v1.2.3-dev

      Downloading the latest version from https://bin-cli.com/bin


      Updated to:
      Executed with: --version
      """

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
      Bin CLI v1.2.3-dev

      Downloading the latest version from https://bin-cli.com/bin


      Updated to:
      Executed with: --version
      """

  @undocumented
  Scenario: If neither wget nor curl are installed, self-update exits with an error
    When I run 'bin --self-update'
    Then it fails with exit code 246
    And the error is "bin: Neither 'wget' nor 'curl' are available"
