#!/bin/bash
# install-muse.sh — Install pstack skills for Muse.ai.
#
# Copies skills/ into ~/workspace/custom-skills/ (the Muse.ai custom skills
# location). Idempotent and safe to re-run.
#
# Usage:
#   ./install-muse.sh [--help] [--dry-run] [--list]

set -u

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/workspace/custom-skills"
DRY_RUN=0
VERSION="$(cat "$REPO_DIR/VERSION" 2>/dev/null || echo "unknown")"

if [ "${1:-}" = "--help" ]; then
  sed -n '2,/^set -u/p' "$0" | sed 's/^# //; s/^#//'
  exit 0
fi
if [ "${1:-}" = "--dry-run" ]; then DRY_RUN=1; echo "DRY RUN — no changes will be made"; echo ""; fi
if [ "${1:-}" = "--list" ]; then
  echo "Skills in this repo:"
  for d in "$SKILLS_SRC"/*/; do basename "$d"; done
  exit 0
fi

echo "=== pstack for Muse.ai — installer (v$VERSION) ==="
echo ""

run() {
  if [ "$DRY_RUN" = "1" ]; then echo "  [dry-run] $*"; else "$@"; fi
}

run mkdir -p "$SKILLS_DST"

INSTALLED=0; SKIPPED=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill=$(basename "$skill_dir")
  dst="$SKILLS_DST/$skill"
  if [ -d "$dst" ] && [ "$DRY_RUN" = "0" ]; then
    echo "  exists: $skill (overwriting)"
  fi
  run rm -rf "$dst"
  run cp -r "$skill_dir" "$dst"
  echo "  installed: $skill"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Installed $INSTALLED skills to $SKILLS_DST"
echo ""
echo "Next steps:"
echo "  1. Read $SKILLS_DST/muse-mode/SKILL.md — it's the router."
echo "  2. Define your model seats in $REPO_DIR/docs/models.md"
echo "  3. Read $REPO_DIR/docs/principles.md — the 24 rules."
echo ""
echo "For Hermes profiles, see hermes/README.md and hermes/deploy.sh."
