if [[ -z ${GITHUB_ACTION-} && -d $HOME/.nvm ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    nvm use --silent
fi

if [[ ! -d node_modules ]]; then
    npm ci --silent
fi
