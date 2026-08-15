# dotfiles

Personal machine setup: shell config, git identity (work/personal split), SSH host routing, and installed packages.

## Restore on a new machine

```bash
git clone git@github.com:Otagera/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
brew bundle install --file=Brewfile
```

Then separately restore SSH keys (`~/.ssh/id_ed25519` for work/GitLab, `~/.ssh/id_ed25519_personal` for personal/GitHub) from your password manager or another secure channel — **never from this repo**.

Also re-authenticate rclone — **two** remotes, neither stored in this repo (`~/.config/rclone/rclone.conf` holds both, deliberately excluded from git):

- `gdrive` — plain OAuth login (browser flow), for the personal_stuv backup
- `gdrive-crypt` — needs the **same password + salt** you set originally, from your password manager. **If you lose that password, the encrypted backup is permanently unrecoverable** — there's no reset.

Then load both backup jobs:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.othnielagera.rclone-backup-personal.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.othnielagera.rclone-backup-encrypted.plist
```

## What's here

- `zshrc`, `zprofile` — shell config
- `gitconfig` — default (personal) git identity, includes `gitconfig-work` for anything under `~/source/ravebyflutterwave/`
- `gitconfig-work` — work git identity (Flutterwave)
- `ssh_config` — routes `gitlab.com` to the work key, `github.com` to the personal key
- `Brewfile` — snapshot of installed Homebrew formulae/casks (`brew bundle dump`)
- `rclone-filters.txt` — excludes regenerable build output (node_modules, target, venv, etc.) from the personal backup
- `bin/rclone-backup-personal.sh` + `com.othnielagera.rclone-backup-personal.plist` — backs up `~/source/personal_stuv` to Google Drive (`gdrive:MacBackup/personal_stuv`) every 6 hours (plus once on login/wake). **Scoped to personal_stuv only** — never points at `~/source/ravebyflutterwave` (work code), by design.
- `bin/rclone-backup-encrypted.sh` + `com.othnielagera.rclone-backup-encrypted.plist` — encrypts and backs up `~/secrets-to-backup` (e.g. TablePlus connection exports — anything that may carry saved passwords) via the `gdrive-crypt` remote, same schedule. Drop a fresh export in that folder whenever it changes; there's no way to automate the export step itself (no CLI for that).

Both jobs skip themselves gracefully (and log to `~/Library/Logs/rclone-backup/skipped*.log`) when there's no internet connection, rather than hanging/retrying.

Backup logs land in `~/Library/Logs/rclone-backup/`.

## Keeping it up to date

After installing something new:

```bash
cd ~/dotfiles
brew bundle dump --file=Brewfile --force
git add -A && git commit -m "update Brewfile" && git push
```
