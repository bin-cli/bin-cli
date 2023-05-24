# Installation

System-wide:

```bash
sudo wget https://bin-cli.com/bin -O /usr/local/bin/bin
```

Or for the current user only:

```bash
mkdir -p ~/bin
wget https://bin-cli.com/bin -O ~/bin/bin
echo 'PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
```

## Tab completion

Add this:

```bash
eval "$(bin --completion)"
```

To one of the following files:

- `/usr/share/bash-completion/completions/bin` (recommended for system-wide install)
- `/etc/bash_completion.d/bin`
- `~/.local/share/bash-completion/completions/bin` (recommended for per-user install)
- `~/.bash_completion`
- `~/.bashrc`

You may want to wrap it in a conditional, in case *Bin* is not installed:

```bash
if command -v bin &>/dev/null; then
    eval "$(bin --completion)"
fi
```

(Only `bash` is supported at the moment. I may add `zsh` and others in the future.)
