# Docker shim

Similarly, you could create shims for commands that need to be run inside a Docker container:

```bash
#!/usr/bin/env bash
exec docker compose exec web php artisan "$@"
```
