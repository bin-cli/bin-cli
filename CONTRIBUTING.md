# Contributing to Bin CLI

## Bug Reports

Please use the [Issues](https://github.com/bin-cli/bin-cli/issues) section to
report bugs (except [security vulnerabilities](SECURITY.md)).
You should include:

- The version number (or Git commit ID) of Bin CLI
- A copy (or screenshot) of the terminal output, including the command(s) run
  and the full text of any error messages
- A link to a public Git repo that demonstrates the issue (if possible) or
  enough detail to reproduce the problem by hand

## Feature Suggestions

Feel free to open an [Issue](https://github.com/bin-cli/bin-cli/issues), but
note that Bin CLI is intentionally kept as simple as possible (see
[#66](https://github.com/bin-cli/bin-cli/issues/66) for details).

## Documentation Changes

### README

You can
[fork and edit the README](https://github.com/bin-cli/bin-cli/edit/main/README.md)
directly on GitHub, then submit a pull request.

### Wiki

[The wiki](https://github.com/bin-cli/bin-cli/wiki) is used for tangential tips
and thoughts. Editing is restricted, but feel free to open an
[Issue](https://github.com/bin-cli/bin-cli/issues) if you think anything could
be improved.

## Pull Requests

Clone the source code locally:

```bash
git clone https://github.com/bin-cli/bin-cli.git
cd bin-cli
```

Make changes to `src/bin`, and update the tests in `features/*.feature` to match.

To run the tests locally, you will need:

- Either [nvm](https://github.com/nvm-sh/nvm) (recommended) or a recent version
  of [Node.js](https://nodejs.org/) (tests are powered by
  [Cucumber.js](https://cucumber.io/docs/installation/javascript/))
- [kcov](https://simonkagstrom.github.io/kcov/)
- [ShellCheck](https://www.shellcheck.net/)
- [awk](https://www.gnu.org/software/gawk/manual/gawk.html)

If you are using Ubuntu/Debian, the `bin/setup` script will install most of
these for you (except nvm/Node.js).

Run `bin/tdd` to automatically run the test suite each time you make a change,
or manually run `bin/test` if you prefer.

To test the changes interactively, run `bin/dev`.

Remember to update the `--help` output, [README](README.md) and
[CHANGELOG](CHANGELOG.md) as appropriate.

To submit your changes as a pull request,
[fork the repository on GitHub](https://github.com/bin-cli/bin-cli/fork)
then run:

```bash
# Replace 'YOUR_BRANCH' with a suitable branch name
git switch -c YOUR_BRANCH
git add -A
git status
git commit -m "DESCRIPTION OF CHANGES HERE"
# Replace 'YOUR_USERNAME' with your GitHub username; or replace the whole URL with the
# HTTPS version (see your repo on GitHub) if you don't have SSH authentication set up
git remote add myfork git@github.com:YOUR_USERNAME/bin-cli.git
git push -u myfork HEAD
```

Browse to the repository fork on GitHub
(`https://github.com/YOUR_USERNAME/bin-cli/tree/YOUR_BRANCH`) and click
"Compare & pull request". Finally, check/update the details and click
"Create pull request".

## Patches

If you have an aversion to everything Microsoft, or just prefer your privacy,
feel free to send a patch to [d@djm.me](mailto:d@djm.me) instead.
