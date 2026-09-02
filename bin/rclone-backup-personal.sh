#!/bin/bash
# Backup of personal content to personal Google Drive.
# Never point this at ~/source/ravebyflutterwave — that's work code, not personal.
set -o pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

FILTERS="$HOME/dotfiles/rclone-filters.txt"
LOG_DIR="$HOME/Library/Logs/rclone-backup"
mkdir -p "$LOG_DIR"

if ! curl -s --max-time 5 -o /dev/null https://www.google.com; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') No internet connection, skipping this run" >> "$LOG_DIR/skipped.log"
  exit 0
fi

overall_exit=0

rclone sync "$HOME/source/personal_stuv" "gdrive:MacBackup/personal_stuv" \
  --filter-from "$FILTERS" \
  --backup-dir "gdrive:MacBackup/_deleted-or-changed/$(date +%Y-%m-%d)" \
  --log-file "$LOG_DIR/$(date +%Y-%m-%d).log" \
  --log-level INFO
[ $? -ne 0 ] && overall_exit=1

# Sapience: a script copies its md files here from elsewhere, and the app
# that reads them may modify them in place — plain files, no symlinks.
rclone sync "$HOME/Documents/Sapience" "gdrive:MacBackup/Sapience" \
  --exclude ".DS_Store" \
  --backup-dir "gdrive:MacBackup/_deleted-or-changed-sapience/$(date +%Y-%m-%d)" \
  --log-file "$LOG_DIR/sapience-$(date +%Y-%m-%d).log" \
  --log-level INFO
[ $? -ne 0 ] && overall_exit=1

exit $overall_exit
