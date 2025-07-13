# Contributing to Bin CLI

## Bug Reports

Please use the [Issues] section to report bugs (except [security vulnerabilities]). You should include:

- The version number (or Git commit ID) of Bin CLI
- A copy (or screenshot) of the terminal output, including the command(s) run and the full text of any error messages
- A link to a public Git repo that demonstrates the issue (if possible) or enough detail to reproduce the problem by hand

## Feature Suggestions

Feel free to open an [Issue], but please note that Bin CLI is intentionally kept as simple as possible (see
[GOALS]), so I'm only likely to accept/implement high-value features that don't slow things down.

## Documentation Improvements

You can [fork and edit the README] directly on GitHub, then submit a pull request, or just open an [Issue] to let me know.

## Pull Requests

Clone the source code locally:

```bash
git clone https://github.com/bin-cli/bin-cli.git
cd bin-cli
```

Make changes to `src/bin`, and update the tests in `tests/*.bash` to match.

To run the tests locally, you will need:

- [kcov]
- [ShellCheck]
- [awk]

If you are using Ubuntu 24.04 or Debian 12 (or similar), the `bin/setup` script will install most of these for you.

Run `bin/tdd` to automatically run the test suite each time you make a change, or manually run `bin/test` if you prefer.

To test the changes interactively, run `bin/dev`. To build a version for your own use, run `bin/build <version>`,
specifying your own version number such as `1.2.3-yourname.0`, then copy `dist/bin` to your preferred location.

Remember to update the `--help` output, [README] and [CHANGELOG] as appropriate.

To submit your changes as a pull request, [fork the repository on GitHub] then run:

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

Browse to the repository fork on GitHub (`https://github.com/YOUR_USERNAME/bin-cli/tree/YOUR_BRANCH`) and click
"Compare & pull request". Finally, check/update the details and click "Create pull request".

## Email

If you prefer the 90's approach, feel free to send a suggestion, patch,
[Git bundle], thank you note to [d@djm.me] instead.

[CHANGELOG]: CHANGELOG.md
[Git bundle]: https://www.chiark.greenend.org.uk/~sgtatham/quasiblog/git-no-forge/#bundle
[GOALS]: GOALS.md
[Issue]: https://github.com/bin-cli/bin-cli/issues
[Issues]: https://github.com/bin-cli/bin-cli/issues
[README]: README.md
[ShellCheck]: https://www.shellcheck.net/
[awk]: https://www.gnu.org/software/gawk/manual/gawk.html
[d@djm.me]: mailto:d@djm.me
[fork and edit the README]: https://github.com/bin-cli/bin-cli/edit/main/README.md
[fork the repository on GitHub]: https://github.com/bin-cli/bin-cli/fork
[kcov]: https://simonkagstrom.github.io/kcov/
[nvm]: https://github.com/nvm-sh/nvm
[security vulnerabilities]: SECURITY.md
