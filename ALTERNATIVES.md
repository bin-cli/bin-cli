# Alternatives

The reasons I decided to write Bin, rather than using one of the existing options, are:

1. It works from any project subdirectory (unlike manually running shell scripts)
2. Scripts can accept arbitrary arguments (unlike [Make](https://makefiletutorial.com/), [Just](https://just.systems/)) - useful when writing a [shim](https://en.wikipedia.org/wiki/Shim_(computing)) for another program
3. It isn't tied to any particular language, and it has no dependencies (unlike [npm](https://docs.npmjs.com/cli/v7/commands/npm-run-script), [Yarn](https://classic.yarnpkg.com/lang/en/docs/cli/run/), [Composer](https://getcomposer.org/doc/articles/scripts.md), [Rake](https://ruby.github.io/rake/), [Grunt](https://gruntjs.com/)) - so I can safely use it for all my projects
4. Installing it is completely optional (unlike [Task](https://taskfile.dev/)) - collaborators can run the scripts directly if they prefer (they don't even need to know I'm using it)
5. It is standalone and small enough to include in my [dotfiles](https://github.com/d13r/dotfiles), for use on systems where I don't have root access

The alternatives I considered include:

[^alias]: By defining a script/task that just calls another script/task.

|                      | Bin        | Scripts         | [npm](https://docs.npmjs.com/cli/v7/commands/npm-run-script)     | [Yarn](https://classic.yarnpkg.com/lang/en/docs/cli/run/) | [Composer](https://getcomposer.org/doc/articles/scripts.md)    |
|----------------------|------------|-----------------|------------------------------------------------------------------|-----------------------------------------------------------|----------------------------------------------------------------|
| **Type**             | **Runner** | **N/A**         | **Runner**                                                       | **Runner**                                                | **Runner**                                                     |
| **Written in**       | Shell      | N/A             | JavaScript                                                       | TypeScript                                                | PHP                                                            |
| **Requires**         | **Shell**  | **Shell**       | Node.js                                                          | Node.js                                                   | PHP                                                            |
| **Standalone**       | **Yes**    | **N/A**         | No                                                               | No                                                        | Kind of (2.8 MB)                                               |
| **Scripts in**       | **Any**    | **Any**         | **Any**                                                          | **Any**                                                   | **Any**                                                        |
| **Config in**        | INI        | N/A             | JSON                                                             | JSON                                                      | JSON                                                           |
| **Linux/Mac/WSL**    | Yes        | Yes             | Yes                                                              | Yes                                                       | Yes                                                            |
| **Windows (native)** | No         | No              | **Yes**                                                          | **Yes**                                                   | **Yes**                                                        |
| **Search parents**   | **Yes**    | No              | **Yes**                                                          | **Yes**                                                   | Prompts first                                                  |
| **Arguments**        | **Yes**    | **Yes**         | **Yes**                                                          | **Yes**                                                   | **Yes**                                                        |
| **CLI optional**     | **Yes**    | **N/A**         | No                                                               | No                                                        | No                                                             |
| **Tab completion**   | **Yes**    | **Yes**         | **[Yes](https://docs.npmjs.com/cli/v7/commands/npm-completion)** | [Third party](https://github.com/mklabs/yarn-completions) | [Third party](https://github.com/bramus/composer-autocomplete) |
| **Prefix matches**   | **Yes**    | No              | No                                                               | No                                                        | No                                                             |
| **Aliases**          | **Yes**    | Kind of[^alias] | Kind of[^alias]                                                  | Kind of[^alias]                                           | Kind of[^alias]                                                |

[^make]: Can be used as a task runner by marking every target as [`.PHONY`](https://stackoverflow.com/a/2145605/167815), but that feels a bit hacky to me!
[^grunt]: Can be used as a basic task runner via [grunt-shell](https://www.npmjs.com/package/grunt-shell).

|                      | [Task](https://taskfile.dev/)                                                | [Just](https://just.systems/)                          | [Rake](https://ruby.github.io/rake/)                   | [Make](https://makefiletutorial.com/)                  | [Grunt](https://gruntjs.com/)                   |
|----------------------|------------------------------------------------------------------------------|--------------------------------------------------------|--------------------------------------------------------|--------------------------------------------------------|-------------------------------------------------|
| **Type**             | **Both**                                                                     | **Both**                                               | **Both**                                               | Builder[^make]                                         | Builder[^grunt]                                 |
| **Written in**       | Go                                                                           | Rust                                                   | Ruby                                                   | C                                                      | JavaScript                                      |
| **Requires**         | **Nothing**                                                                  | **Shell**                                              | Ruby                                                   | **Nothing**                                            | JavaScript                                      |
| **Standalone**       | **Yes** (5 MB)                                                               | **Yes** (5 MB)                                         | No                                                     | No                                                     | No                                              |
| **Scripts in**       | **Any**                                                                      | **Any**                                                | **[Any](https://stackoverflow.com/a/14360488/167815)** | **Any**                                                | JavaScript                                      |
| **Config in**        | YAML                                                                         | Custom                                                 | Ruby                                                   | Custom                                                 | JavaScript                                      |
| **Linux/Mac/WSL**    | Yes                                                                          | Yes                                                    | Yes                                                    | Yes                                                    | Yes                                             |
| **Windows (native)** | **Yes**                                                                      | **Yes**                                                | **Yes**                                                | [Maybe](https://stackoverflow.com/a/32127632/167815)   | **Yes**                                         |
| **Search parents**   | **Yes**                                                                      | **Yes**                                                | **Yes**                                                | No                                                     | **Yes**                                         |
| **Arguments**        | [Prefixed](https://taskfile.dev/usage/#forwarding-cli-arguments-to-commands) | Limited                                                | Limited                                                | Limited                                                | Limited                                         |
| **CLI optional**     | No                                                                           | No                                                     | No                                                     | No                                                     | No                                              |
| **Tab completion**   | **[Yes](https://taskfile.dev/installation/#bash)**                           | **[Yes](https://just.systems/man/en/chapter_63.html)** | **Yes**                                                | **Yes**                                                | **[Yes](https://github.com/gruntjs/grunt-cli)** |
| **Prefix matches**   | No                                                                           | No                                                     | No                                                     | No                                                     | No                                              |
| **Aliases**          | [Yes](https://taskfile.dev/usage/#task-aliases)                              | **[Yes](https://github.com/casey/just#aliases)**       | [Kind of](https://stackoverflow.com/a/7661613/167815)  | [Kind of](https://stackoverflow.com/a/33594470/167815) | Kind of[^alias]                                 |

Of these, [Task](https://taskfile.dev/) would be my second choice - but I find shell scripts more suitable for the majority of my own use cases. YMMV.

I also looked at a few others, which I judged not suitable or too complex to investigate further:

- [Gulp](https://gulpjs.com/)
- [Webpack](https://webpack.js.org/)
- [pydoit](https://pydoit.org/)
- [Snakemake](https://snakemake.readthedocs.io/en/stable/)
- [SCons](https://scons.org/)

There are even more listed in the [Just manual](https://just.systems/man/en/chapter_68.html) and the [Rake manual](https://ruby.github.io/rake/#label-Other+Make+Re-envisionings+...).
