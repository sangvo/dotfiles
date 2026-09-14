# Replacement for oh-my-zsh: keeps only the parts in use
# (lib history/completion/directories/key-bindings/termsupport/grep + theme robbyrussell + plugin z)

ZSH_CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR

# --- History ------------------------------------------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify share_history
alias history='fc -l 1'

# --- Options ------------------------------------------------------------------
setopt auto_cd auto_pushd pushd_ignore_dups pushd_minus
setopt multios long_list_jobs interactive_comments prompt_subst
setopt auto_menu complete_in_word always_to_end
unsetopt menu_complete flow_control

export PAGER=${PAGER:-less} LESS=${LESS:--R}
export LSCOLORS=Gxfxcxdxbxegedabagacad
export LS_COLORS=${LS_COLORS:-'di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'}

# --- Completion ---------------------------------------------------------------
zmodload -i zsh/complist
WORDCHARS=''
# :A normalizes the path to match the one the plugin adds itself; typeset -U drops duplicates
typeset -U fpath
fpath=(~/.local/share/zsh/plugins/zsh-z(:A) $fpath)

autoload -Uz compinit
# dump newer than 20h: load it directly (-C); otherwise re-check fpath and rebuild if needed
_zc_dump=$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION
_zc_fresh=($_zc_dump(N.mh-20))
if (( $#_zc_fresh )); then
  compinit -C -d $_zc_dump
else
  compinit -u -d $_zc_dump && touch $_zc_dump
fi
[[ $_zc_dump.zwc -nt $_zc_dump ]] || zcompile $_zc_dump
unset _zc_dump _zc_fresh
autoload -U +X bashcompinit && bashcompinit

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
  clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
  gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
  ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
  operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
  usbmux uucp vcsa wwwrun xfs '_*'
zstyle '*' single-ignored show
bindkey -M menuselect '^o' accept-and-infer-next-history

# --- Key bindings -------------------------------------------------------------
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  zle-line-init() { echoti smkx }
  zle-line-finish() { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey -e
for _zc_km in emacs viins vicmd; do
  bindkey -M $_zc_km '^[[A' up-line-or-beginning-search
  bindkey -M $_zc_km '^[[B' down-line-or-beginning-search
  bindkey -M $_zc_km '^?' backward-delete-char
  bindkey -M $_zc_km '^[[3;5~' kill-word
  bindkey -M $_zc_km '^[[1;5C' forward-word
  bindkey -M $_zc_km '^[[1;5D' backward-word
  bindkey -M $_zc_km ${terminfo[kdch1]:-'^[[3~'} delete-char
  [[ -n ${terminfo[kpp]} ]] && bindkey -M $_zc_km ${terminfo[kpp]} up-line-or-history
  [[ -n ${terminfo[knp]} ]] && bindkey -M $_zc_km ${terminfo[knp]} down-line-or-history
  [[ -n ${terminfo[kcuu1]} ]] && bindkey -M $_zc_km ${terminfo[kcuu1]} up-line-or-beginning-search
  [[ -n ${terminfo[kcud1]} ]] && bindkey -M $_zc_km ${terminfo[kcud1]} down-line-or-beginning-search
  [[ -n ${terminfo[khome]} ]] && bindkey -M $_zc_km ${terminfo[khome]} beginning-of-line
  [[ -n ${terminfo[kend]} ]] && bindkey -M $_zc_km ${terminfo[kend]} end-of-line
  [[ -n ${terminfo[kcbt]} ]] && bindkey -M $_zc_km ${terminfo[kcbt]} reverse-menu-complete
done
unset _zc_km
bindkey '\ew' kill-region
bindkey -s '\el' '^q ls\n'
bindkey '^r' history-incremental-search-backward
bindkey ' ' magic-space
bindkey '^x^e' edit-command-line
bindkey '^[m' copy-prev-shell-word

# --- Aliases / functions ------------------------------------------------------
alias -g ...='../..' ....='../../..' .....='../../../..' ......='../../../../..'
alias -- -='cd -'
for _zc_i in {1..9}; do alias $_zc_i="cd -$_zc_i"; done
unset _zc_i
alias md='mkdir -p' rd=rmdir lsa='ls -lah' _='sudo '
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}'
alias egrep='grep -E' fgrep='grep -F'

d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

take() { mkdir -p -- "$1" && builtin cd -- "$1" }
diff() { command diff --color "$@" }

# --- Terminal title + cwd (OSC 7 so WezTerm opens tabs/splits in the same dir) --
_zc_title() {
  emulate -L zsh
  setopt no_prompt_subst
  case $TERM in
    screen*|tmux*)
      print -Pn "\e]2;${2:q}\e\\"
      print -Pn "\ek${1:q}\e\\"
      ;;
    *)
      print -Pn "\e]2;${2:q}\a"
      print -Pn "\e]1;${1:q}\a"
      ;;
  esac
}
_zc_title_precmd() { _zc_title '%15<..<%~%<<' '%n@%m:%~' }
_zc_title_preexec() {
  emulate -L zsh
  setopt extended_glob
  local cmd=${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
  _zc_title "$cmd" "%100>...>${2:gs/%/%%}%<<"
}
_zc_cwd() {
  emulate -L zsh
  setopt extended_glob
  local LC_ALL=C
  printf '\e]7;file://%s%s\e\\' "$HOST" "${PWD//(#m)[^A-Za-z0-9\/._~-]/%${(l:2::0:)$(( [##16] #MATCH ))}}"
}

# --- Prompt (robbyrussell theme), git status runs async -----------------------
_zc_git=''
typeset -gi _zc_git_fd=0

_zc_git_info() {
  local line head oid dirty
  git status --porcelain=v2 --branch --ignore-submodules=dirty 2>/dev/null | while IFS= read -r line; do
    case $line in
      ('# branch.oid '*) oid=${line#\# branch.oid } ;;
      ('# branch.head '*) head=${line#\# branch.head } ;;
      ('#'*) ;;
      (*) dirty=1; break ;;
    esac
  done
  [[ -z $head ]] && return
  [[ $head == '(detached)' ]] && head=${oid[1,7]}
  local info="%B%F{blue}git:(%F{red}${head//\%/%%}%F{blue})"
  [[ -n $dirty ]] && info+=" %F{yellow}%1{✗%}"
  print -r -- "$info%b%f "
}

_zc_git_done() {
  local fd=$1 out
  IFS= read -r -u $fd out
  zle -F $fd
  exec {fd}<&-
  _zc_git_fd=0
  if [[ $out != $_zc_git ]]; then
    _zc_git=$out
    zle reset-prompt
  fi
}
zle -N _zc_git_done

_zc_git_precmd() {
  if (( _zc_git_fd )); then
    zle -F $_zc_git_fd 2>/dev/null
    exec {_zc_git_fd}<&-
    _zc_git_fd=0
  fi
  exec {_zc_git_fd}< <(_zc_git_info)
  zle -F -w $_zc_git_fd _zc_git_done
}
_zc_git_chpwd() { _zc_git='' }

PROMPT='%(?:%B%F{green}%1{➜%} :%B%F{red}%1{➜%} ) %F{cyan}%c%b%f ${_zc_git}'

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zc_title_precmd
add-zsh-hook precmd _zc_cwd
add-zsh-hook precmd _zc_git_precmd
add-zsh-hook preexec _zc_title_preexec
add-zsh-hook chpwd _zc_git_chpwd

# --- Plugin z (jump to frecent directories) ------------------------------------
source ~/.local/share/zsh/plugins/zsh-z/zsh-z.plugin.zsh
