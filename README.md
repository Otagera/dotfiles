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
- `starship.toml` — prompt config, Catppuccin Mocha palette, language segments for Node/Rust/Go/Java/.NET(C#)/Python
- `ghostty_config` — Catppuccin Mocha theme (bundled with Ghostty, no extra install needed)
- `bin/llm.sh` — launches whichever LLM CLI is available (`$LLM_CLI` override, else `opencode`). Deliberately does **not** auto-launch bare `claude` — see comments in the file for why (it'd bypass the work/personal identity split)
- `bin/rclone-backup-personal.sh` + `com.othnielagera.rclone-backup-personal.plist` — backs up `~/source/personal_stuv` to Google Drive (`gdrive:MacBackup/personal_stuv`) every 6 hours (plus once on login/wake). **Scoped to personal_stuv only** — never points at `~/source/ravebyflutterwave` (work code), by design.
- `bin/rclone-backup-encrypted.sh` + `com.othnielagera.rclone-backup-encrypted.plist` — encrypts and backs up `~/secrets-to-backup` (e.g. TablePlus connection exports — anything that may carry saved passwords) via the `gdrive-crypt` remote, same schedule. Drop a fresh export in that folder whenever it changes; there's no way to automate the export step itself (no CLI for that).

Both jobs skip themselves gracefully (and log to `~/Library/Logs/rclone-backup/skipped*.log`) when there's no internet connection, rather than hanging/retrying.

Backup logs land in `~/Library/Logs/rclone-backup/`.

- `zellij/dev.kdl` — general-purpose terminal layout: nvim + shell + lazygit, with zellij's built-in tab-bar/status-bar so keybindings stay visible. Launch with `dev` (aliased to `zellij --layout dev`). No hardcoded `cwd` — inherits wherever you launched it from.

`yazi` (terminal file manager) is tracked in `Brewfile`, installed standalone for now — not wired into the `dev` layout yet.

`lazygit` and `mergiraf` are tracked in `Brewfile` (installed via `brew install`, auto-captured by the `brew` wrapper in `zshrc`). Mergiraf's merge driver is registered globally in `gitconfig` (`[merge "mergiraf"]` — there's no built-in installer command, this was hand-written against `mergiraf merge --help`'s actual flags). It's still opt-in per repo/language though — add a line to that repo's `.gitattributes` for whichever file types you want it handling, e.g. `*.rs merge=mergiraf`.

## Keeping it up to date

After installing something new:

```bash
cd ~/dotfiles
brew bundle dump --file=Brewfile --force
git add -A && git commit -m "update Brewfile" && git push
```
