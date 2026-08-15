#!/bin/bash
# Encrypted backup of ~/secrets-to-backup (e.g. TablePlus connection exports)
# to Google Drive via the 'gdrive-crypt' remote. Contents are encrypted at
# rest by rclone before ever leaving this machine.
set -o pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SRC="$HOME/secrets-to-backup"
DEST="gdrive-crypt:current"
LOG_DIR="$HOME/Library/Logs/rclone-backup"
mkdir -p "$LOG_DIR"

if ! curl -s --max-time 5 -o /dev/null https://www.google.com; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') No internet connection, skipping this run" >> "$LOG_DIR/skipped-encrypted.log"
  exit 0
fi

rclone sync "$SRC" "$DEST" \
  --backup-dir "gdrive-crypt:_deleted-or-changed/$(date +%Y-%m-%d)" \
  --log-file "$LOG_DIR/encrypted-$(date +%Y-%m-%d).log" \
  --log-level INFO
