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
mkdir -p "$HOME/.ssh"
link ssh_config .ssh/config
chmod 700 "$HOME/.ssh"
chmod 644 "$HOME/.ssh/config"

echo
echo "Dotfiles linked. Now run:"
echo "  brew bundle install --file=$DOTFILES/Brewfile"
echo "Then restore SSH keys separately (never stored in this repo) and start a new shell."
