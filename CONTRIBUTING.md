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

If you don't want to install them locally, you can use Docker:

```bash
# Run *one* of these to build the image using the given base image
docker build --build-arg base=ubuntu:22.04 --build-arg UID=$UID -t bin-cli-dev .
docker build --build-arg base=fedora:40 --build-arg UID=$UID -t bin-cli-dev .

# Then start a container based on that image (this start a Bash shell)
docker run -v "$PWD:/home/docker/bin-cli" -it --rm bin-cli-dev
```

Run the `bin/watch` command to automatically build and test the changes:

```bash
bin/watch
```

To test the changes interactively, run `bin/dev`, which will both build and run the development version.

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

To free up space used by Docker:

```bash
docker image rm bin-cli-dev

# Optional (be careful not to remove anything you're still using)
docker container prune
docker image prune
docker builder prune
```

## Contributing Documentation Changes

### README

The [`README.md`](README.md) file is automatically generated, so please do not edit it directly. Instead, please edit the `.md` and `.feature` files in the [`features/`](features/) directory and submit that as a pull request.

In the `.feature` files, each line of Markdown must be prefixed with `|` - this ensures headings, which start with `#`, are not treated as comments.

`README.md` will be [updated automatically](.github/workflows/update-readme.yml) by GitHub Actions. Alternatively, you can manually regenerate it by running `bin/generate/readme`. You will need either [nvm](https://github.com/nvm-sh/nvm) (recommended) or a suitable version of [Node.js](https://nodejs.org/) installed - or you can use Docker, as described above.

### CLI Reference / Help Text

The [CLI Reference](README.md#cli-reference) is taken directly from the `bin --help` output, which is part of the [source code](src/bin). Please see [Contributing Code Changes](#contributing-code-changes), above.

### Man Page

The [man page](https://bin-cli.github.io/bin-cli/bin.1.html) is generated from the Markdown file in the [man/](man/) folder using [Pandoc](https://pandoc.org/). To test it, run:

```bash
bin/man
```

To test the HTML versions, run `bin/generate/man` then open the HTML files generated in `dist/`.

### Wiki

[The wiki](https://github.com/bin-cli/bin-cli/wiki) is used for tangential tips and thoughts. Editing is restricted, both to prevent spam and because it contains my personal views rather than factual information. Feel free to open an [Issue](https://github.com/bin-cli/bin-cli/issues) if you think anything could be improved.
