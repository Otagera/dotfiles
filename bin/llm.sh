#!/usr/bin/env bash
#
# Launches whichever LLM assistant CLI is available, for use in scripts
# or terminal-multiplexer layouts that shouldn't hardcode one tool.
#
# Never auto-launches bare `claude` — that command is aliased in ~/.zshrc
# to refuse running directly, forcing an explicit identity (claude-work /
# claude-personal, each with its own $CLAUDE_CONFIG_DIR). Aliases don't
# exist in a script's subshell, so this replicates those two aliases
# directly instead, rather than silently bypassing the identity split.
#
# Pick order:
#   1. $LLM_CLI, if set — either "claude-work" / "claude-personal"
#      (routed through the correct $CLAUDE_CONFIG_DIR below), or any
#      other command name found on PATH (e.g. `export LLM_CLI=opencode`)
#   2. opencode, if on PATH
#   3. claude found but no identity chosen — tell you how to pick one

set -euo pipefail

CLAUDE_BIN="/Users/othnielagera/.local/bin/claude"

launch_claude_work() {
    exec env CLAUDE_CONFIG_DIR="$HOME/.claude-work" "$CLAUDE_BIN" "$@"
}

launch_claude_personal() {
    exec env CLAUDE_CONFIG_DIR="$HOME/.claude-personal" "$CLAUDE_BIN" "$@"
}

if [[ -n "${LLM_CLI:-}" ]]; then
    case "$LLM_CLI" in
        claude-work) launch_claude_work "$@" ;;
        claude-personal) launch_claude_personal "$@" ;;
        *)
            if command -v "$LLM_CLI" >/dev/null 2>&1; then
                exec "$LLM_CLI" "$@"
            fi
            echo "llm: \$LLM_CLI is set to '$LLM_CLI' but it's not on PATH" >&2
            exit 127
            ;;
    esac
fi

if command -v opencode >/dev/null 2>&1; then
    exec opencode "$@"
fi

if command -v claude >/dev/null 2>&1; then
    echo "llm: found 'claude' but won't auto-launch it bare (no identity)." >&2
    echo "llm: run 'claude-work' or 'claude-personal' directly, or set" >&2
    echo "llm: \$LLM_CLI=claude-work (or claude-personal) before running this." >&2
    exit 1
fi

echo "llm: no LLM CLI found (looked for: opencode, claude)." >&2
echo "llm: install one, or set \$LLM_CLI to the command to use." >&2
exit 127
