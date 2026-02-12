#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(git -C "$SKILL_DIR" rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "$REPO_ROOT"

if ! command -v openspec >/dev/null 2>&1; then
  echo "OpenSpec CLI not found. Installing..."
  npm install -g @fission-ai/openspec@latest
fi

openspec --version

echo "Running openspec init in: $REPO_ROOT"
openspec init

AGENTS_FILE="$REPO_ROOT/AGENTS.md"
BOOTSTRAP_MARKER="## OpenSpec bootstrap"

if [[ -f "$AGENTS_FILE" ]] && grep -q "$BOOTSTRAP_MARKER" "$AGENTS_FILE"; then
  echo "AGENTS.md already contains OpenSpec bootstrap block."
  exit 0
fi

cat <<'EOF' >> "$AGENTS_FILE"

## OpenSpec bootstrap

1. Populate your project context:
   "Please read openspec/project.md and help me fill it out
    with details about my project, tech stack, and conventions"

2. Create your first change proposal:
   "I want to add [YOUR FEATURE HERE]. Please create an
    OpenSpec change proposal for this feature"

3. Learn the OpenSpec workflow:
   "Please explain the OpenSpec workflow from openspec/AGENTS.md
    and how I should work with you on this project"
EOF

echo "Added OpenSpec bootstrap block to AGENTS.md."
