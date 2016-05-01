# ZSH Theme - Preview: http://dl.dropbox.com/u/4109351/pics/gnzh-zsh-theme.png
# Based on bira theme

setopt prompt_subst

() {

local PR_USER PR_USER_OP PR_HOST

# Check the UID
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
git_branch='$(git-radar --zsh --fetch)'

# print -P -n "╭─${user_host} ${current_dir} ${git_branch} b" | wc --chars # let it eat this line instead


prompt_gnzh_prcmd() {
    local prompt_line_1
    local git_radar
    local start='⎨'
    local stop='⎬'

    # The prompt will eat a line of the output
    print # let it eat this line instead
    prompt_gnzh_padding
    PROMPT="$prompt_line_1
╰─$PR_PROMPT "
    RPROMPT="${return_code} %F{white}${git_radar}"
}

prompt_gnzh_padding() {
    git_radar="$(git-radar --zsh --fetch | sed -e 's/ //')"
    if [[ -n "$git_radar" ]]; then
        git_radar="%F{white}%f${git_radar}"
    fi
    local jobs="%(1j.─${start}%j${stop}─.)"
    local prompt_line_1a="%F{white}╭─${jobs}${start}${current_dir}%F{white}${stop}%f"
    local prompt_line_1b="─${start}${user_host}%F{white}${stop}──"
    prompt_line_1="${prompt_line_1a}${prompt_line_1b}"
    local prompt_line_1_width=${#${(S%%)prompt_line_1//(\%([KF1]|)\{*\}|\%[Bbkf])}}
    local padding_size=$((COLUMNS - prompt_line_1_width))
    local padding
    if (( padding_size > 0)); then
        eval "padding=\${(l:${padding_size}::─:)_empty_zz}"
    fi
    prompt_line_1="${prompt_line_1a}%F{white}${padding}${prompt_line_1b}"
    # print $padding
}
add-zsh-hook precmd prompt_gnzh_prcmd
add-zsh-hook chpwd prompt_gnzh_prcmd


# PROMPT="╭─${user_host} ${current_dir} ${rvm_ruby} ${git_branch}
# ╰─$PR_PROMPT "
# PROMPT="$prompt_line_1%F{white}${padding}%f
# ╰─$PR_PROMPT "
# RPROMPT="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %f"

}
