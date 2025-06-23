# Contributing to Bin CLI

## Reporting Bugs

Please use the [Issues](https://github.com/bin-cli/bin-cli/issues) section to report bugs (except [security vulnerabilities](SECURITY.md)). You should include:

- The version number (or Git commit ID) of Bin CLI
- A copy (or screenshot) of the terminal output, including the command(s) run and the full text of any error messages
- A link to a public Git repo that demonstrates the issue (if possible) or enough detail to reproduce the problem by hand

## Suggesting New Features

Please open an [Issue](https://github.com/bin-cli/bin-cli/issues)

## Contributing Code Changes

Clone the source code locally:

```bash
git clone https://github.com/bin-cli/bin-cli.git
cd bin-cli
```

Make changes to `src/bin`, and update the tests in `features/*.feature` to match.

To run the tests locally, you will need:

- Either [nvm](https://github.com/nvm-sh/nvm) (recommended) or a recent version of [Node.js](https://nodejs.org/) (tests are powered by [Cucumber.js](https://cucumber.io/docs/installation/javascript/))
- [kcov](https://simonkagstrom.github.io/kcov/)
- [ShellCheck](https://www.shellcheck.net/)
- [awk](https://www.gnu.org/software/gawk/manual/gawk.html)

The `bin/setup` script will install most of these for you (except nvm/Node.js) on Ubuntu.

Run `bin/tdd` to automatically build and test the changes:

```bash
bin/tdd
```

To test the changes interactively, run `bin/dev`, which will both build and run the development version.

Update the [README](README.md) and `--help` output as needed.

To submit your changes as a pull request, [fork the repository on GitHub](https://github.com/bin-cli/bin-cli/fork) then run:

```bash
# Replace 'YOUR_BRANCH' with a suitable branch name
git switch -c YOUR_BRANCH
git add -A
git status
git commit -m "DESCRIPTION OF CHANGES HERE"
# Replace 'YOUR_USERNAME' with your GitHub username; replace the whole URL with the
# HTTPS version (see your repo on GitHub) if you don't have SSH authentication set up
git remote add myfork git@github.com:YOUR_USERNAME/bin-cli.git
git push -u myfork HEAD
```

Browse to the repository fork on GitHub (`https://github.com/YOUR_USERNAME/bin-cli/tree/YOUR_BRANCH`) and click "Compare & pull request". Finally, check/update the details and click "Create pull request".

## Contributing Documentation Changes

### Wiki

[The wiki](https://github.com/bin-cli/bin-cli/wiki) is used for tangential tips and thoughts. Editing is restricted, both to prevent spam and because it contains my personal views rather than factual information. Feel free to open an [Issue](https://github.com/bin-cli/bin-cli/issues) if you think anything could be improved.
