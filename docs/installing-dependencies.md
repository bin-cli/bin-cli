# Automatic installation of dependencies

You could extend the previous script to automatically install missing dependencies, rather than requiring the user to do it manually:

```bash
#!/usr/bin/env bash
cd "$(dirname "$0")/.."

if [[ ! -d node_modules ]]; then
    echo 'Installing dependencies...'
    npm ci || exit
    echo
fi

exec node server.js
```
