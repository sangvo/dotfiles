#!/usr/bin/env bash
# Helpers shared by bootstrap.sh. Source this file; it expects DOTFILES_DIR to be set.

: "${DOTFILES_DIR:?DOTFILES_DIR must point at the dotfiles checkout}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
ZSH_PLUGIN_DIR="${ZSH_PLUGIN_DIR:-$HOME/.local/share/zsh/plugins}"
CURRENT_STEP=""

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

# run_step NAME CMD...: bootstrap.sh's ERR trap reports CURRENT_STEP when CMD fails.
run_step() {
  CURRENT_STEP=$1
  shift
  log "$CURRENT_STEP"
  "$@"
}

# Move a file, directory or symlink under $HOME into $BACKUP_DIR, keeping its relative path.
backup_path() {
  local path=$1 rel dest
  if [[ ! -e $path && ! -L $path ]]; then
    return 0
  fi
  rel=${path#"$HOME"/}
  dest="$BACKUP_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  mv "$path" "$dest"
  log "backed up ~/$rel to $dest"
}

# Remove broken symlinks in ~, ~/.config and ~/.ssh that point into the repository,
# e.g. links left behind when a package directory is renamed.
clean_stale_links() {
  local dir link target repo_rel
  repo_rel=${DOTFILES_DIR#"$HOME"/}
  for dir in "$HOME" "$HOME/.config" "$HOME/.ssh"; do
    if [[ ! -d $dir ]]; then
      continue
    fi
    while IFS= read -r -d '' link; do
      if [[ -e $link ]]; then
        continue
      fi
      target=$(readlink "$link")
      if [[ $target == *"$repo_rel/"* ]]; then
        rm "$link"
        log "removed stale link ~/${link#"$HOME"/}"
      fi
    done < <(find "$dir" -maxdepth 1 -type l -print0)
  done
}

# Keep a hand-written ~/.ssh/config by moving it to ~/.ssh/config.d/legacy,
# which the shared config includes.
migrate_ssh_config() {
  local cfg="$HOME/.ssh/config" legacy="$HOME/.ssh/config.d/legacy"
  if [[ ! -f $cfg || -L $cfg ]]; then
    return 0
  fi
  mkdir -p "$HOME/.ssh/config.d"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
  if [[ -e $legacy ]]; then
    backup_path "$cfg"
    return 0
  fi
  mv "$cfg" "$legacy"
  chmod 600 "$legacy"
  log "moved ~/.ssh/config to ~/.ssh/config.d/legacy"
}

# copy_if_missing SRC DEST MODE
copy_if_missing() {
  local src=$1 dest=$2 mode=$3
  if [[ -e $dest ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  chmod "$mode" "$dest"
  log "created ~/${dest#"$HOME"/} from template"
}

# Machine-local files that tracked configs include but that never enter git.
setup_local_files() {
  mkdir -p "$HOME/.ssh/config.d" "$HOME/.ssh/sockets"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d" "$HOME/.ssh/sockets"
  copy_if_missing "$DOTFILES_DIR/templates/gitconfig.local" "$HOME/.gitconfig.local" 644
  copy_if_missing "$DOTFILES_DIR/templates/git-company" "$HOME/.config/git/company" 600
  copy_if_missing "$DOTFILES_DIR/templates/ssh-company" "$HOME/.ssh/config.d/company" 600
}
