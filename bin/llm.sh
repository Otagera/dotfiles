#!/usr/bin/env bash
#
# Launches an LLM assistant CLI. If more than one is available and you
# haven't specified which, shows an interactive picker instead of just
# guessing — run this again in a new zellij pane/tab and pick a different
# one to have multiple assistants open side by side.
#
# Never auto-launches bare `claude` — that command is aliased in ~/.zshrc
# to refuse running directly, forcing an explicit identity (claude-work /
# claude-personal, each with its own $CLAUDE_CONFIG_DIR). Aliases don't
# exist in a script's subshell, so this replicates those two aliases
# directly instead, rather than silently bypassing the identity split.
#
# Pick order:
#   1. $LLM_CLI, if set — "claude-work", "claude-personal", or any other
#      command name found on PATH (e.g. `export LLM_CLI=opencode`)
#   2. exactly one option available — just launch it, no need to ask
#   3. more than one option available — interactive picker

set -euo pipefail

CLAUDE_BIN="/Users/othnielagera/.local/bin/claude"

launch_claude_work() {
    exec env CLAUDE_CONFIG_DIR="$HOME/.claude-work" "$CLAUDE_BIN" "$@"
}

launch_claude_personal() {
    exec env CLAUDE_CONFIG_DIR="$HOME/.claude-personal" "$CLAUDE_BIN" "$@"
}

run_choice() {
    local choice="$1"
    shift
    case "$choice" in
        opencode) exec opencode "$@" ;;
        claude-work) launch_claude_work "$@" ;;
        claude-personal) launch_claude_personal "$@" ;;
        *)
            if command -v "$choice" >/dev/null 2>&1; then
                exec "$choice" "$@"
            fi
            echo "llm: '$choice' is not on PATH" >&2
            exit 127
            ;;
    esac
}

if [[ -n "${LLM_CLI:-}" ]]; then
    run_choice "$LLM_CLI" "$@"
fi

options=()
command -v opencode >/dev/null 2>&1 && options+=("opencode")
command -v "$CLAUDE_BIN" >/dev/null 2>&1 && options+=("claude-work" "claude-personal")

if [[ ${#options[@]} -eq 0 ]]; then
    echo "llm: no LLM CLI found (looked for: opencode, claude)." >&2
    echo "llm: install one, or set \$LLM_CLI to the command to use." >&2
    exit 127
fi

if [[ ${#options[@]} -eq 1 ]]; then
    run_choice "${options[0]}" "$@"
fi

PS3="Pick an assistant (number or name): "
select choice in "${options[@]}"; do
    if [[ -n "${choice:-}" ]]; then
        run_choice "$choice" "$@"
    fi
    # select only matches numbers by default — also accept the name typed directly
    for opt in "${options[@]}"; do
        if [[ "$REPLY" == "$opt" ]]; then
            run_choice "$opt" "$@"
        fi
    done
    echo "Not a valid option, try again."
done
