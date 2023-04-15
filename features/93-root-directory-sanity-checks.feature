Feature: Root directory sanity checks
  I don't think there are any security issues with allowing root to point to an
  external directory, since the whole idea of Bin is to run arbitrary code,
  which could call those scripts directory - but I hope to reduce the likelihood
  of invalid paths being committed to a shared repository.

  Scenario: The 'root' option cannot be an absolute path when set in .binconfig
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    And a file '/project/.binconfig' with content 'dir=/project/scripts'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The option 'root' cannot be an absolute path in /project/.binconfig line 1"

  Scenario: The 'root' option cannot point to a parent directory in .binconfig
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    And a file '/project/root/.binconfig' with content 'dir=../scripts'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The option 'root' cannot point to a directory outside /project in /project/.binconfig line 1"

  Scenario: The 'root' option cannot point to a symlink to a parent directory in .binconfig
    Given a script '/project/scripts/hello' that outputs 'Hello, World!'
    And a symlink '/project/root/symlink' pointing to '/project/scripts'
    And a file '/project/root/.binconfig' with content 'dir=symlink'
    And the working directory is '/project/root'
    When I run 'bin hello'
    Then the exit code is 246
    And there is no output
    And the error is "bin: The option 'root' cannot point to a symlink to a directory outside /project in /project/.binconfig line 1"
