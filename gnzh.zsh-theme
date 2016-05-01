# ZSH Theme - Preview: http://dl.dropbox.com/u/4109351/pics/gnzh-zsh-theme.png
# Based on bira theme

setopt prompt_subst

() {

local PR_USER PR_USER_OP PR_HOST

# Unicode characters for padding and text brackets
local unicode_symbols=("─" "⎨" "⎬" "╭" "╰" "➤")
# Ascii characters for padding and text brackets
local ascii_symbols=('-' '(' ')' '.' '`-' ">")

PROMPT_SYMBOLS=($unicode_symbols)

# Check the UID
local arrow=$PROMPT_SYMBOLS[6]
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{yellow}%n%f'
  PR_USER_OP='%F{green}%#%f'
  PR_PROMPT='➤%f'
else # root
  PR_USER='%F{red}%n%f'
  PR_USER_OP='%F{red}%#%f'
  PR_PROMPT='%F{red}➤%f'
fi

# Check if we are on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{red}%M%f' # SSH
else
  PR_HOST='%F{yellow}%M%f' # no SSH
fi


return_code="%(?..%F{red}%? ↵%f)"

user_host="${PR_USER}%F{cyan}@${PR_HOST}"
current_dir="%F{blue}%~%f"
local rvm_ruby=''
if ${HOME}/.rvm/bin/rvm-prompt &> /dev/null; then # detect user-local rvm installation
  rvm_ruby='%F{red}‹$(${HOME}/.rvm/bin/rvm-prompt i v g s)›%f'
elif which rvm-prompt &> /dev/null; then # detect system-wide rvm installation
  rvm_ruby='%F{red}‹$(rvm-prompt i v g s)›%f'
elif which rbenv &> /dev/null; then # detect Simple Ruby Version Management
  rvm_ruby='%F{red}‹$(rbenv version | sed -e "s/ (set.*$//")›%f'
fi

prompt_gnzh_prcmd() {
    local prompt_line_1
    local git_radar
    local p_char="$PROMPT_SYMBOLS[1]"
    local start="$PROMPT_SYMBOLS[2]"
    local stop="$PROMPT_SYMBOLS[3]"
    local top_corner="$PROMPT_SYMBOLS[4]"
    local bottom_corner="$PROMPT_SYMBOLS[5]"

    # The prompt will eat a line of the output
    print # let it eat this line instead
    # Load the prompt_line
    prompt_gnzh_padding
    PROMPT="$prompt_line_1
${bottom_corner}${p_char}$PR_PROMPT "
    RPROMPT="${return_code} %F{white}${git_radar}%f"
}

prompt_gnzh_padding() {
    git_radar="$(git-radar --zsh --fetch | sed -e 's/ //')"
    if [[ -n "$git_radar" ]]; then
        git_radar="%F{white}%f${git_radar}"
    fi
    local jobs="%(1j.${p_char}${start}%j${stop}${p_char}.)"
    local prompt_line_1a="%F{white}${top_corner}${p_char}${jobs}${start}${current_dir}%F{white}${stop}%f"
    local prompt_line_1b="${start}${user_host}%F{white}${stop}${p_char}${p_char}"
    prompt_line_1="${prompt_line_1a}${prompt_line_1b}"

    local prompt_line_1_width=${#${(S%%)prompt_line_1//(\%([KF1]|)\{*\}|\%[Bbkf])}}
    local padding_size=$((COLUMNS - prompt_line_1_width))
    local padding
    if (( padding_size > 0)); then
        eval "padding=\${(l:${padding_size}::${p_char}:)_empty_zz}"
    fi
    prompt_line_1="${prompt_line_1a}%F{white}${padding}${prompt_line_1b}"
}

add-zsh-hook precmd prompt_gnzh_prcmd
add-zsh-hook chpwd prompt_gnzh_prcmd
}
