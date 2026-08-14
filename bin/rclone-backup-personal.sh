#!/bin/bash
# Nightly backup of ~/source/personal_stuv to personal Google Drive.
# Never point this at ~/source/ravebyflutterwave — that's work code, not personal.
set -o pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SRC="$HOME/source/personal_stuv"
DEST="gdrive:MacBackup/personal_stuv"
FILTERS="$HOME/dotfiles/rclone-filters.txt"
LOG_DIR="$HOME/Library/Logs/rclone-backup"
mkdir -p "$LOG_DIR"

rclone sync "$SRC" "$DEST" \
  --filter-from "$FILTERS" \
  --backup-dir "gdrive:MacBackup/_deleted-or-changed/$(date +%Y-%m-%d)" \
  --log-file "$LOG_DIR/$(date +%Y-%m-%d).log" \
  --log-level INFO
