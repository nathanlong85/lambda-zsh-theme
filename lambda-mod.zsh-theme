#!/usr/bin/env zsh

LAMBDA="%(?,%{$fg_bold[green]%}λ,%{$fg_bold[red]%}λ)"
if [[ "$USER" == "root" ]]; then USERCOLOR="red"; else USERCOLOR="yellow"; fi

# Format for git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} ✔"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg_bold[white]%}^"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" %{$fg_bold[white]%}[%{$fg_bold[blue]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$fg_bold[white]%}]"

function _lambda_git_status() {
    local INDEX result=""
    INDEX=$(git status --porcelain 2>/dev/null)
    [[ -z "$INDEX" ]] && return
    echo "$INDEX" | command grep -qE '^A[ MD]'        && result+="$ZSH_THEME_GIT_PROMPT_ADDED"
    echo "$INDEX" | command grep -qE '^M |^[ MARC]M' && result+="$ZSH_THEME_GIT_PROMPT_MODIFIED"
    echo "$INDEX" | command grep -qE '^D |^[ MARC]D' && result+="$ZSH_THEME_GIT_PROMPT_DELETED"
    echo "$INDEX" | command grep -qE '^R[ MD]'        && result+="$ZSH_THEME_GIT_PROMPT_RENAMED"
    echo "$INDEX" | command grep -qE '^(U[UDA]|[DA]U|AA|DD)' && result+="$ZSH_THEME_GIT_PROMPT_UNMERGED"
    echo "$INDEX" | command grep -q  '^[?][?]'        && result+="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    echo "$result"
}

# Git sometimes goes into a detached head state. git symbolic-ref fails in
# that case, so we detect it and show "detached-head" instead.
function check_git_prompt_info() {
    git rev-parse --git-dir > /dev/null 2>&1 || return
    local branch git_st dirty
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    git_st=$(_lambda_git_status)
    if [[ -z "$branch" ]]; then
        echo "(%{$fg[blue]%}detached-head%{$reset_color%})${git_st}%{$reset_color%}"
    else
        if [[ -z "$git_st" ]]; then
            dirty="$ZSH_THEME_GIT_PROMPT_CLEAN"
        else
            dirty="$ZSH_THEME_GIT_PROMPT_DIRTY"
        fi
        echo "(${ZSH_THEME_GIT_PROMPT_PREFIX}${branch}${ZSH_THEME_GIT_PROMPT_SUFFIX}${dirty}${git_st}%{$reset_color%})"
    fi
}

function get_right_prompt() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local sha
        sha=$(git rev-parse --short HEAD 2>/dev/null)
        echo -n "${ZSH_THEME_GIT_PROMPT_SHA_BEFORE}${sha}${ZSH_THEME_GIT_PROMPT_SHA_AFTER}%{$reset_color%}"
    else
        echo -n "%{$reset_color%}"
    fi
}

# Change the prompt depending on the terminal application. The lambda on a
# line by itself doesn't look right in Warp terminal
if [[ "$TERM_PROGRAM" == "WarpTerminal" ]]; then
  PROMPT=$'%F{161%}%n%{$reset_color%} at %F{166%}%m%{$reset_color%} in %F{118%}%d%{$reset_color%} $(check_git_prompt_info)\n'
else
  PROMPT=$'╭─%F{161%}%n%{$reset_color%} at %F{166%}%m%{$reset_color%} in %F{118%}%d%{$reset_color%} $(check_git_prompt_info)
%{$reset_color%}╰─'$LAMBDA' %{$reset_color%}'
fi

# RPROMPT='$(get_right_prompt)'
