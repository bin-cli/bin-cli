if [[ -t 1 ]]; then
    TITLE=$(printf "\e[97;1;4m") # White, bold, underline
    ALIASES=$(printf "\e[90m") # Grey
    RESET=$(printf "\e[0m")
else
    TITLE=''
    ALIASES=''
    RESET=''
fi
