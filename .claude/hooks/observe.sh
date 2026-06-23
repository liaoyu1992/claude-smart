#!/usr/bin/env bash
# observe.sh - Claude Code Observation Hook Entry Point
# Called by Claude Code hooks (PreToolUse / PostToolUse)
# Usage: observe.sh <pre|post>
# Reads JSON from stdin (Claude Code passes tool call data via stdin)
#
# IMPORTANT: All paths are relative to the project root where .claude/ lives.

set -eo pipefail

PHASE="${1:-post}"

# Resolve project root from this script's location (../.. from .claude/hooks/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

OBSERVE_PY="$CLAUDE_DIR/bin/observe.py"

# Read all stdin into a variable
INPUT=$(cat)

# Only process if we have actual input
if [ -z "$INPUT" ]; then
    exit 0
fi

# Delegate to Python script, passing phase and input
# Use subshell to ensure || true works correctly in pipefail mode
(echo "$INPUT" | python3 "$OBSERVE_PY" "$PHASE" "$CLAUDE_DIR" 2>/dev/null || true) || true

# Also run rotation check (silently)
(python3 "$CLAUDE_DIR/bin/observations_rotate.py" "$CLAUDE_DIR" 2>/dev/null || true) || true

exit 0
