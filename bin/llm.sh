#!/usr/bin/env bash
#
# Launches whichever LLM assistant CLI is available, for use in scripts
# or terminal-multiplexer layouts that shouldn't hardcode one tool.
#
# Deliberately does NOT auto-launch bare `claude` — that command is aliased
# in ~/.zshrc to refuse running directly, forcing an explicit identity
# (claude-work / claude-personal, each with its own $CLAUDE_CONFIG_DIR).
# Aliases don't exist in a script's subshell, so this can't just detect
# and exec `claude` the way it could with opencode — doing so would
# silently bypass that identity split.
#
# Pick order:
#   1. $LLM_CLI, if set (e.g. `export LLM_CLI=opencode`)
#   2. opencode, if on PATH
#   3. otherwise, tell you to pick an identity explicitly

set -euo pipefail

if [[ -n "${LLM_CLI:-}" ]]; then
    if command -v "$LLM_CLI" >/dev/null 2>&1; then
        exec "$LLM_CLI" "$@"
    fi
    echo "llm: \$LLM_CLI is set to '$LLM_CLI' but it's not on PATH" >&2
    exit 127
fi

if command -v opencode >/dev/null 2>&1; then
    exec opencode "$@"
fi

if command -v claude >/dev/null 2>&1; then
    echo "llm: found 'claude' but won't auto-launch it bare (no identity)." >&2
    echo "llm: run 'claude-work' or 'claude-personal' directly, or set \$LLM_CLI." >&2
    exit 1
fi

echo "llm: no LLM CLI found (looked for: opencode, claude)." >&2
echo "llm: install one, or set \$LLM_CLI to the command to use." >&2
exit 127
