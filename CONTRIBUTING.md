# Contributing to Bin CLI

## Reporting Bugs

Please use the [Issues](https://github.com/bin-cli/bin-cli/issues) section to report bugs (except [security vulnerabilities](SECURITY.md)). You should include:

- The version number (or Git commit ID) of Bin CLI
- A copy (or screenshot) of the terminal output, including the command(s) run and the full text of any error messages
- A link to a public Git repo that demonstrates the issue (if possible) or enough detail to reproduce the problem by hand

## Suggesting New Features

Please open an [Issue](https://github.com/bin-cli/bin-cli/issues) 

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

To test the changes interactively, run `bin/dev`, which will both build and run the development version. You can also `alias bin="$PWD/bin/dev"` to make it the default version temporarily, or add `dist/` to your `$PATH`.

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

### README

The [`README.md`](README.md) file is automatically generated, so please do not edit it directly. Instead, please edit the `.md` and `.feature` files in the [`features/`](features/) directory and submit that as a pull request.

In the `.feature` files, each line of Markdown must be prefixed with `|` - this ensures headings, which start with `#`, are not treated as comments.

`README.md` will be [updated automatically](.github/workflows/update-readme.yml) by GitHub Actions. Alternatively, you can manually regenerate it by running `bin/generate/readme`. You will need either [nvm](https://github.com/nvm-sh/nvm) (recommended) or a suitable version of [Node.js](https://nodejs.org/) installed.

### CLI Reference / Help Text

The [CLI Reference](README.md#cli-reference) is taken directly from the `bin --help` output, which is part of the [source code](src/bin). Please see [Contributing Code Changes](#contributing-code-changes), above.

### Man Pages

The [man pages](https://bin-cli.github.io/bin-cli/bin.1.html) are generated from the Markdown files in the [man/](man/) folder. To test them, run:

```bash
bin/man bin
bin/man binconfig
```

To test the HTML versions, run `bin/generate/man` then open the HTML files generated in `dist/`.

### Wiki

[The wiki](https://github.com/bin-cli/bin-cli/wiki) is used for tangential tips and thoughts. Editing is restricted, both to prevent spam and because it contains my personal views rather than factual information. Feel free to open an [Issue](https://github.com/bin-cli/bin-cli/issues) if you think anything could be improved.
