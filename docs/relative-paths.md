# Relative paths

*Bin* doesn't change the working directory, for consistency with running scripts manually, so you need to resolve any paths first. For example, this is equivalent to a typical `npm start` script:

```bash
#!/usr/bin/env bash
exec node "$(dirname "$0")/../server.js"
```

Or you can change the working directory to the project root:

```bash
#!/usr/bin/env bash
cd "$(dirname "$0")/.."
exec node server.js
```

Or you may prefer to assign the root path to a variable, for clarity and/or reusability:

```bash
#!/usr/bin/env bash
root="$(dirname "$0")/.."
exec node "$root/server.js"
```

In that case, `$root` will be something like `/path/to/repo/bin/..` - which is valid but a little ugly. You may prefer to use this format instead - the code is a little longer, but it will resolve to `/path/to/repo` instead:

```bash
#!/usr/bin/env bash
root=$(dirname "$(dirname "$0")")
exec node "$root/server.js"
```

In all of these, using `exec` tells Bash to replace itself with the given process, rather than running it in a subprocess.
