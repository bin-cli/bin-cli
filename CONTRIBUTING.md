# Contributing to Bin CLI

***Caveat:** I may or may not get around to dealing with issues/PRs/discussions - it depends how much they interest me at the time!*

## Reporting Bugs

Please use the [Issues](https://github.com/bin-cli/bin-cli/issues) section to report bugs (except [security vulnerabilities](SECURITY.md)). You should include:

- A link to a public Git repo that demonstrates the issue, if possible, or enough detail to reproduce the problem by hand
- A copy (or screenshot) of the terminal output, including the command(s) run and the full text of any error messages

## Suggesting New Features

Please use the [Feature suggestions / requests](https://github.com/bin-cli/bin-cli/discussions/categories/feature-suggestions-requests) discussion category in the first instance.

## Contributing Code Changes

You will need either [nvm](https://github.com/nvm-sh/nvm) (recommended) or a suitable version of [Node.js](https://nodejs.org/) installed to run the tests (which are powered by [Cucumber.js](https://cucumber.io/docs/installation/javascript/)). The `bin/setup` script in the repo will install dependencies for you on Ubuntu, if you like.

Clone the source code locally:

```bash
git clone https://github.com/bin-cli/bin-cli.git
```

Make changes to `src/bin`, and update the tests in `features/*.feature` to match. Run the `bin/watch` command to automatically build and test the changes:

```bash
cd bin-cli
bin/watch
```

To test the changes interactively, run `bin/dev`, which will both build and run the development version. You can also `alias bin="$PWD/bin/dev"` to make it the default version temporarily, or copy `temp/dist/bin` to `$HOME/.local/bin/bin` or `/usr/local/bin/bin` (as appropriate) to replace the installed version.

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

**Note:** Changes without passing tests won't be merged - but feel free to open a draft pull request if you are unable to complete it yourself or want to discuss it before finishing it.

## Contributing Documentation Changes

### README

The [`README.md`](README.md) file is automatically generated, so please do not edit it directly. Instead, please edit the `.md` and `.feature` files in the [`features/`](features/) directory and submit that as a pull request.

In the `.feature` files, each line of Markdown must be prefixed with `|` - this ensures headings, which start with `#`, are not treated as comments.

`README.md` will be [updated automatically](.github/workflows/update-readme.yml) when it is merged into the `main` branch. Alternatively, you can manually regenerate it by running `bin/generate/readme`. You will need either [nvm](https://github.com/nvm-sh/nvm) (recommended) or a suitable version of [Node.js](https://nodejs.org/) installed.

### CLI Reference / Help Text

The [CLI Reference](README.md#cli-reference) is taken directly from the `bin --help` output, which is part of the [source code](src/bin). Please see [Contributing Code Changes](#contributing-code-changes), above.

### Man Pages

The [man pages](https://bin-cli.github.io/bin-cli/bin.1.html) are generated from the Markdown files in the [src/](src/) folder. To test them:

```bash
bin/man bin
bin/man binconfig
```

To test the HTML versions, run `bin/generate/man` then open the HTML files generated in `temp/pages/`.

### Wiki

[The wiki](https://github.com/bin-cli/bin-cli/wiki) is used for tangential tips and thoughts. Editing is restricted, both to prevent spam and because it contains my personal views rather than factual information. Please use the [Discussions](https://github.com/bin-cli/bin-cli/discussions) section to share your own tips and thoughts, or open an [Issue](https://github.com/bin-cli/bin-cli/issues) if you believe there is a mistake.
