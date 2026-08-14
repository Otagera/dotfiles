#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dest="$HOME/$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $dest"
  fi
  ln -sfn "$src" "$dest"
  echo "Linked $dest -> $src"
}

link zshrc .zshrc
link zprofile .zprofile
link gitconfig .gitconfig
link gitconfig-work .gitconfig-work
link gitignore_global .gitignore_global
mkdir -p "$HOME/.ssh"
link ssh_config .ssh/config
chmod 700 "$HOME/.ssh"
chmod 644 "$HOME/.ssh/config"

chmod +x "$DOTFILES/bin/rclone-backup-personal.sh"
mkdir -p "$HOME/Library/Logs/rclone-backup"
cp "$DOTFILES/com.othnielagera.rclone-backup-personal.plist" "$HOME/Library/LaunchAgents/"

echo
echo "Dotfiles linked. Now run:"
echo "  brew bundle install --file=$DOTFILES/Brewfile"
echo "Then restore SSH keys separately (never stored in this repo) and start a new shell."
echo
echo "Personal backup (rclone → Google Drive):"
echo "  1. rclone config   # re-authenticate the 'gdrive' remote (not stored in this repo)"
echo "  2. launchctl bootstrap gui/\$(id -u) $HOME/Library/LaunchAgents/com.othnielagera.rclone-backup-personal.plist"
