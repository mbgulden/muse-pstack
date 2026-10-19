#!/bin/bash
# Deploy pstack skills to Hermes agent profiles.
#
# Usage:
#   cp config.example.yaml config.yaml   # edit with your paths
#   ./deploy.sh
#
# Copies each skill's SKILL.md into <hermes-home>/profiles/<profile>/skills/.
# Verifies every file landed by comparing line counts.
# Idempotent: safe to re-run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/config.yaml"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config.yaml not found." >&2
  echo "  cp config.example.yaml config.yaml, then edit it." >&2
  exit 1
fi

# Parse minimal YAML (hermes_home, profiles list)
HERMES_HOME="$(grep '^hermes_home:' "$CONFIG" | cut -d: -f2- | xargs)"
if [ -z "$HERMES_HOME" ]; then
  echo "ERROR: hermes_home not set in config.yaml" >&2
  exit 1
fi

# Profiles: lines after 'profiles:' starting with '- '
mapfile -t PROFILES < <(awk '/^profiles:/{flag=1;next}/^- /{if(flag)print}/^[^ -]/{flag=0}' "$CONFIG" | sed 's/^-[[:space:]]*//')

if [ ${#PROFILES[@]} -eq 0 ]; then
  echo "ERROR: no profiles listed in config.yaml" >&2
  exit 1
fi

# Skill -> profiles mapping
declare -A SKILL_PROFILES
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill="$(basename "$skill_dir")"
  case "$skill" in
    pstack-arena|pstack-swarm)
      SKILL_PROFILES["$skill"]="orchestrator"
      ;;
    *)
      # all profiles
      SKILL_PROFILES["$skill"]="${PROFILES[*]}"
      ;;
  esac
done

echo "Deploying to $HERMES_HOME"
echo "Profiles: ${PROFILES[*]}"
echo ""

FAILED=0
for skill in "${!SKILL_PROFILES[@]}"; do
  src="$SCRIPT_DIR/skills/$skill/SKILL.md"
  [ -f "$src" ] || { echo "SKIP: $skill (no SKILL.md)"; continue; }
  expected_lines=$(wc -l < "$src")

  # Determine target profiles for this skill
  if [ "${SKILL_PROFILES[$skill]}" = "orchestrator" ]; then
    # Only deploy to a profile literally named "orchestrator", else first profile
    targets=()
    for p in "${PROFILES[@]}"; do
      if [ "$p" = "orchestrator" ]; then targets=("$p"); break; fi
    done
    [ ${#targets[@]} -eq 0 ] && targets=("${PROFILES[0]}")
    echo "  $skill → orchestrator-only (${targets[*]})"
  else
    targets=("${PROFILES[@]}")
    echo "  $skill → all profiles"
  fi

  for profile in "${targets[@]}"; do
    dest_dir="$HERMES_HOME/profiles/$profile/skills/$skill"
    mkdir -p "$dest_dir"
    cp "$src" "$dest_dir/SKILL.md"
    actual_lines=$(wc -l < "$dest_dir/SKILL.md")
    if [ "$actual_lines" -eq "$expected_lines" ]; then
      echo "    ✓ $profile ($actual_lines lines)"
    else
      echo "    ✗ $profile (expected $expected_lines, got $actual_lines)"
      FAILED=1
    fi
  done
done

if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "All skills deployed and verified."
else
  echo ""
  echo "Some deployments failed. Check output above." >&2
  exit 1
fi
