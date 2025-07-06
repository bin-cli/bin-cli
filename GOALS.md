# Bin CLI Project Goals

In this order:

1. Make it easy to run project-specific scripts, such as `deploy`, `stage`, `clear-cache`
2. Ensure those scripts can still be run without Bin CLI installed (on live servers or in other people's development environments)
3. Be fast, especially during tab completion (so avoid superfluous features that may slow it down - see [#61](https://github.com/bin-cli/bin-cli/issues/61))
4. Be small enough to bundle with [my dotfiles](https://github.com/d13r/dotfiles) (so prefer a script to a compiled executable)
5. Be able to run anywhere (so prefer a language that's always available)
6. Keep it simple

## Anti-Goals

- Implement features just because other people may want them or to compete with alternatives like [Just](https://just.systems/man/en/) (see [#66](https://github.com/bin-cli/bin-cli/issues/66))
