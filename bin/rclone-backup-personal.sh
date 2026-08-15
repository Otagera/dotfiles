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

if ! curl -s --max-time 5 -o /dev/null https://www.google.com; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') No internet connection, skipping this run" >> "$LOG_DIR/skipped.log"
  exit 0
fi

rclone sync "$SRC" "$DEST" \
  --filter-from "$FILTERS" \
  --backup-dir "gdrive:MacBackup/_deleted-or-changed/$(date +%Y-%m-%d)" \
  --log-file "$LOG_DIR/$(date +%Y-%m-%d).log" \
  --log-level INFO
