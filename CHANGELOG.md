# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] (Major)

### Changed

- Subcommands are no longer listed recursively ([#66])
- Scripts starting with underscore (`_`) are no longer treated specially ([#66])

### Removed

The following were removed ([#66]) in an effort to speed things up ([#61]), simplify/minimise ongoing maintenance, and focus on the core features that matter:

- Aliases defined in config files (`alias = ...`, `aliases = ...`) (but symlink aliases are still supported)
- Create (`--create`, `-c`) and edit (`--edit`, `-e`) actions
- Config files (`.binconfig`)
- Directory merging (`merge = true`, `merge = optional`)
- Exact command matching (`--exact`, `exact = true`) - unique prefix matching is now always enabled
- Fallbacks (`--fallback`) and shims (`--shim`)
- Info action (`--info`)
- Inline commands (`command = ...`)
- Man pages (`man bin`, `man binconfig`)
- Scripts with hidden extensions (`command.sh` -> `bin command`)
- Warnings about broken symlinks and non-executable files

In addition, the `.deb` and `.rpm` packages will no longer be built, including the Ubuntu PPA.

## [1.0.2] - 2025-03-06

### Fixed

- Fix `.binconfig` not being detected when `dir = .` is used along with an absolute `--path` ([ba4cdca])
- Minor fix to 'not found' error message wording when `.binconfig` can't be found ([fb9e285])

## [1.0.1] - 2024-08-21

### Fixed

- Speed up execution on Bash 4+ (particularly noticable during tab completion - around 30% speedup in my unscientific tests) ([0ad26c8], [a63f255], [a97301c])

## [1.0.0] - 2024-05-31

### Added

- Allow command arguments to be listed with the command names ([844260e])

### Fixed

- Better handling of multiple action arguments such as `bin -e -e` ([#46])

Since this would have taken us from version 0.9 to 0.10, and I think it is more-or-less feature-complete now, I decided this is a good time to make an official 1.0 release.

## [0.9.3] - 2024-05-30

### Fixed

- Fix bug where unique prefix matching didn't work correctly for an alias that points to a subcommand ([0dae5ed])

## [0.9.2] - 2024-05-28

### Changed

- Stop minifying the script ([51d587b])

## [0.9.1] - 2024-05-18

### Added

- Create [Ubuntu PPA](https://launchpad.net/~bin-cli/+archive/ubuntu/bin-cli) ([#42])
- Add `.deb` installation package to GitHub releases
- Create `.rpm` installation package ([#45])

### Changed

- Compress (gzip) man pages, as expected by Debian packages

### Fixed

- Make the `--completion` command use the basename of the exe rather than the full path, so it can be relocated later ([55274af])

## [0.9.0] - 2024-05-04

### Added

- Add man pages ([#11])
- Make `--edit` support inline commands ([#38])
- Add `--info` option to display info about the current project ([#35])
    - Special handling for `bin info` ([f2251b4])

### Changed

- Improvements to tab completion
    - Make tab completion work after options such as `--edit` ([#39])
    - Tab-complete option names as well as command names ([#40])
- Link to the relevant version of the README in the `--help` output (instead of the latest version) ([5c036fd])
- Make the command names stand out a little more in the command listing ([8d556f7])
- Minify the `bin` script (remove commands and leading whitespace) ([1c6fd7d])

### Fixed

- Set `$BIN_DIR` and `$BIN_ROOT` correctly for inline commands when merging directories ([714be30])
- Handle missing required arguments ([8907e2a])
- Detect conflicts between commands and subdirectories ([dd52bd4])

## [0.8.1] - 2024-02-28

### Fixed

- Correctly display help text for scripts with extensions ([496541a])

## [0.8.0] - 2023-11-11

### Added

- Add a `template` option for `--create` ([c75be53])

### Changed

- Allow (and encourage) spaces in `.binconfig` ([2f39abe])
- Prepopulate new `.binconfig` files with the command names ([47f6c6b])

### Fixed

- Ignore blank help text in `.binconfig` ([c21897a])
- Fix warning when an alias is defined for a directory ([fdf4778])

## [0.7.2] - 2023-11-06

### Fixed

- Fix typo in `--create` output - 'set -eno pipefail' should be 'set -euo pipefail' ([e06ca35])

## [0.7.1] - 2023-10-30

### Changed

- Don't display a message when subdirectories are created by `--create` (allows us to use `mkdir -p`)
- Disallow executing text files (`*.txt`), etc. in the root directory (more consistent + simplifies merging)

### Fixed

- Fix `--create` using the highest not lowest merged directory ([#29])
- Fix "Command not found" error messages displaying the highest not lowest merged directory + `.binconfig` file
- Fix `--create` not working if `bin/` doesn't already exist

## [0.7.0] - 2023-10-29

### Added

- Add a config option `merge=true` to merge multiple `bin/` directories ([#15])

### Changed

- Restrict the values accepted for `exact=` - raise an error if another value is found

### Removed

- Remove `--debug` argument, as it was getting difficult to maintain the debug output when reorganising the code
- Remove `--print` argument, since I can't actually see much use for it

## [0.6.2] - 2023-10-28

### Added

- Support for `--key=value` format options (`--dir=`, `--exe=`, `--fallback=`) as well as `--key value` ([#10])

### Changed

- Various minor improvements to handle edge cases better and be more resilient overall

### Fixed

- Remove `--shell` from the help text, since it was never actually implemented

## [0.6.1] - 2023-10-23

### Changed

- Display a helpful tip when running 'bin help' or similar (if not defined as a command) ([#8])
- Make it clearer that `bin/` is a directory not a file in the error message listing the path

### Fixed

- Fix warning displayed when inline commands are used ([#26])
- Sort commands alphabetically, even when some are defined inline ([#9])

## [0.6.0] - 2023-10-22

### Added

- Allow simple commands to be defined directly in `.binconfig` ([#25])
- Add `$BIN_EXE` environment variable for scripts to use

## [0.5.0] - 2023-10-22

### Changed

- Link to the README in the `--help` text

### Fixed

- Fix the `/bin` directory not being ignored because it is seen as `//bin` ([#23])

(This could arguably have been a patch release, but never mind...)

## [0.4.0] - 2023-09-21

### Added

- Add `--create` and `--edit` commands ([#2])

## [0.3.0] - 2023-05-15

### Added

- Add support for macOS (Bash v3)

## [0.2.0] - 2023-05-01

### Changed

- Exclude hidden scripts from tab completion (unless the `_` prefix is typed)
- Ensure debugging output can be pasted into GitHub issues without being treated as Markdown
- Set `$BIN_COMMAND` to the full original command name, instead of the unique prefix or alias entered
- Display a warning if .binconfig contains a command that doesn't exist
- Display a warning if a symlink is broken
- Remove dependency on `realpath` by using `readlink -f` (since `readlink` is already used elsewhere)

### Fixed

- Fix aliases with spaces in them

## [0.1.0] - 2023-04-23

- First release (beta)

[Unreleased]: https://github.com/bin-cli/bin-cli/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/bin-cli/bin-cli/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/bin-cli/bin-cli/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/bin-cli/bin-cli/compare/v0.9.3...v1.0.0
[0.9.3]: https://github.com/bin-cli/bin-cli/compare/v0.9.2...v0.9.3
[0.9.2]: https://github.com/bin-cli/bin-cli/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/bin-cli/bin-cli/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/bin-cli/bin-cli/compare/v0.8.1...v0.9.0
[0.8.1]: https://github.com/bin-cli/bin-cli/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/bin-cli/bin-cli/compare/v0.7.2...v0.8.0
[0.7.2]: https://github.com/bin-cli/bin-cli/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/bin-cli/bin-cli/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/bin-cli/bin-cli/compare/v0.6.2...v0.7.0
[0.6.2]: https://github.com/bin-cli/bin-cli/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/bin-cli/bin-cli/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/bin-cli/bin-cli/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/bin-cli/bin-cli/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/bin-cli/bin-cli/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/bin-cli/bin-cli/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/bin-cli/bin-cli/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/bin-cli/bin-cli/compare/2d9a4006...v0.1.0

[#66]: https://github.com/bin-cli/bin-cli/issues/66
[#61]: https://github.com/bin-cli/bin-cli/issues/61
[#46]: https://github.com/bin-cli/bin-cli/issues/46
[#45]: https://github.com/bin-cli/bin-cli/issues/45
[#42]: https://github.com/bin-cli/bin-cli/issues/42
[#40]: https://github.com/bin-cli/bin-cli/issues/40
[#39]: https://github.com/bin-cli/bin-cli/issues/39
[#38]: https://github.com/bin-cli/bin-cli/issues/38
[#35]: https://github.com/bin-cli/bin-cli/issues/35
[#29]: https://github.com/bin-cli/bin-cli/issues/29
[#26]: https://github.com/bin-cli/bin-cli/issues/26
[#25]: https://github.com/bin-cli/bin-cli/issues/25
[#23]: https://github.com/bin-cli/bin-cli/issues/23
[#15]: https://github.com/bin-cli/bin-cli/issues/15
[#11]: https://github.com/bin-cli/bin-cli/issues/11
[#10]: https://github.com/bin-cli/bin-cli/issues/10
[#9]: https://github.com/bin-cli/bin-cli/issues/9
[#8]: https://github.com/bin-cli/bin-cli/issues/8
[#2]: https://github.com/bin-cli/bin-cli/issues/2

[ba4cdca]: https://github.com/bin-cli/bin-cli/commit/ba4cdca9526a7bb4c7515a3fb9a3db00054378af
[fb9e285]: https://github.com/bin-cli/bin-cli/commit/fb9e2851811c6a4f3c977fdacccb7241772a8a45
[0ad26c8]: https://github.com/bin-cli/bin-cli/commit/0ad26c8bea3ec9af77c198387c690df8e9a00a3d
[a63f255]: https://github.com/bin-cli/bin-cli/commit/a63f2551f3eb272e4c67af962fa8e42aa1ecb9fc
[a97301c]: https://github.com/bin-cli/bin-cli/commit/a97301caee6b883f3d0a3c638ee487d66f22ffb5
[844260e]: https://github.com/bin-cli/bin-cli/commit/844260efc42b0fdca0316163fa3ff0315fe3ee30
[0dae5ed]: https://github.com/bin-cli/bin-cli/commit/0dae5ed98a9f85c7a582d7859110acdd9afae367
[51d587b]: https://github.com/bin-cli/bin-cli/commit/51d587bb21565e42092283ef33f6f8074449657f
[55274af]: https://github.com/bin-cli/bin-cli/commit/55274af36e1b7c4967d802864fb27c14cf51e286
[f2251b4]: https://github.com/bin-cli/bin-cli/commit/f2251b48643ff84673b6ab9a9323c643298e4c7a
[5c036fd]: https://github.com/bin-cli/bin-cli/commit/5c036fdff76be27c00c67548c7fe7fe30bddceb8
[8d556f7]: https://github.com/bin-cli/bin-cli/commit/8d556f7a8839e0ef39e3a694acab719b488426ed
[1c6fd7d]: https://github.com/bin-cli/bin-cli/commit/1c6fd7d6c991015880311f058f0d410130f00792
[714be30]: https://github.com/bin-cli/bin-cli/commit/714be309c47baa84a941c2d4c71fafd0ec8d981e
[8907e2a]: https://github.com/bin-cli/bin-cli/commit/8907e2a6fc2adb81d7c85929b42dcc11601bffd2
[dd52bd4]: https://github.com/bin-cli/bin-cli/commit/dd52bd4a043383defd5cfb263816cb094ec57418
[496541a]: https://github.com/bin-cli/bin-cli/commit/496541a0c19854d5e9af249b851f55908d7cda38
[c75be53]: https://github.com/bin-cli/bin-cli/commit/c75be5307babfea59c2a5dd77a0c59d4cea951ea
[2f39abe]: https://github.com/bin-cli/bin-cli/commit/2f39abe57e5b8d7a5297a3da1201729bea2e6ddb
[47f6c6b]: https://github.com/bin-cli/bin-cli/commit/47f6c6bea8ce8063b5ef973ae1f50fb0db58a972
[c21897a]: https://github.com/bin-cli/bin-cli/commit/c21897ad154fac944c61b89062df35d079e17bfb
[fdf4778]: https://github.com/bin-cli/bin-cli/commit/fdf4778a8d2baee8c53e68e88cf19dea81be557c
[e06ca35]: https://github.com/bin-cli/bin-cli/commit/e06ca35f6bd12564143841966c6521b792dc7555
