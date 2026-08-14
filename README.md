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

Also re-authenticate rclone (`rclone config`, remote name `gdrive`) — the OAuth credentials live in `~/.config/rclone/rclone.conf`, deliberately **not** stored in this repo, then load the backup job:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.othnielagera.rclone-backup-personal.plist
```

## What's here

- `zshrc`, `zprofile` — shell config
- `gitconfig` — default (personal) git identity, includes `gitconfig-work` for anything under `~/source/ravebyflutterwave/`
- `gitconfig-work` — work git identity (Flutterwave)
- `ssh_config` — routes `gitlab.com` to the work key, `github.com` to the personal key
- `Brewfile` — snapshot of installed Homebrew formulae/casks (`brew bundle dump`)
- `rclone-filters.txt` — excludes regenerable build output (node_modules, target, venv, etc.) from the personal backup
- `bin/rclone-backup-personal.sh` + `com.othnielagera.rclone-backup-personal.plist` — nightly (2 AM) backup of `~/source/personal_stuv` to Google Drive (`gdrive:MacBackup/personal_stuv`). **Scoped to personal_stuv only** — never points at `~/source/ravebyflutterwave` (work code), by design.

Backup logs land in `~/Library/Logs/rclone-backup/`.

## Keeping it up to date

After installing something new:

```bash
cd ~/dotfiles
brew bundle dump --file=Brewfile --force
git add -A && git commit -m "update Brewfile" && git push
```
