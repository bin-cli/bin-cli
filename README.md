# Bin – A simple task runner

[![GitHub Actions Status](https://github.com/bin-cli/bin-cli/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/bin-cli/bin-cli/actions/workflows/test.yml)
[![Netlify Status](https://api.netlify.com/api/v1/badges/e128b9c4-43cd-4ad9-b079-9828e89db6b8/deploy-status)](https://app.netlify.com/sites/bin-cli/deploys)

<!-- This text is also in docs/index.md -->

*Bin* is a simple task/script runner, designed to be used in code repositories, with scripts written in any programming language.

It automatically searches in parent directories, so you can run scripts from anywhere in the project tree.

It supports aliases and unique prefix matching, as well as tab completion, reducing the amount you need to type.

It is implemented as a self-contained shell script, small enough to bundle with your dotfiles or projects if you want to.

Its use is completely optional - users who choose not to install *Bin* can run the scripts directly.

*It doesn't natively support Windows - though it can be used via [WSL](https://learn.microsoft.com/en-us/windows/wsl/about), [Git Bash](https://gitforwindows.org/), [MSYS2](https://www.msys2.org/) or [Cygwin](https://www.cygwin.com/).*

For more details, see [bin-cli.com](https://bin-cli.com/).
