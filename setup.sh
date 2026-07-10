#!/bin/bash
# Second-brain setup: scaffolds ~/brain and (optionally) the Claude Code
# SessionStart hook that auto-loads it every session.
# Idempotent — never overwrites existing files.
set -euo pipefail

BRAIN="$HOME/brain"
KIT="$(cd "$(dirname "$0")" && pwd)"

echo "== Second-brain setup =="

# 1. Directory structure
mkdir -p "$BRAIN"/{brain/topics,work/active,decisions,.claude/commands}

# 2. Templates (skip anything that already exists)
copy_if_missing() {
  if [ -e "$2" ]; then echo "  keep    $2 (exists)"; else cp "$1" "$2"; echo "  create  $2"; fi
}
copy_if_missing "$KIT/templates/CLAUDE.md"  "$BRAIN/CLAUDE.md"
copy_if_missing "$KIT/templates/index.md"   "$BRAIN/brain/index.md"
for c in "$KIT"/templates/commands/*.md; do
  copy_if_missing "$c" "$BRAIN/.claude/commands/$(basename "$c")"
done
[ -e "$BRAIN/brain/log.md" ] || { echo "# Session Log" > "$BRAIN/brain/log.md"; echo "  create  $BRAIN/brain/log.md"; }
[ -e "$BRAIN/.gitignore" ] || { echo ".DS_Store" > "$BRAIN/.gitignore"; echo "  create  $BRAIN/.gitignore"; }

# 3. Git init (local history; add a PRIVATE remote yourself for backup)
if [ ! -d "$BRAIN/.git" ]; then
  git -C "$BRAIN" init -q && git -C "$BRAIN" add -A && git -C "$BRAIN" commit -qm "init: second brain from starter kit"
  echo "  git     initialized $BRAIN (local only — add a PRIVATE remote for backup)"
fi

# 4. SessionStart hook (auto-load brain in every Claude Code session)
HOOK_DST="$HOME/.claude/hooks/brain-context.sh"
mkdir -p "$HOME/.claude/hooks"
copy_if_missing "$KIT/hooks/brain-context.sh" "$HOOK_DST"
chmod +x "$HOOK_DST"

SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ] && grep -q "brain-context.sh" "$SETTINGS"; then
  echo "  hook    already wired in settings.json"
elif command -v jq >/dev/null && [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak"
  jq '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks":[{"type":"command","command":"'"$HOOK_DST"'","timeout":10,"statusMessage":"Loading second brain..."}]}])' "$SETTINGS.bak" > "$SETTINGS"
  echo "  hook    wired into settings.json (backup at settings.json.bak)"
else
  cat <<EOF
  hook    add this to ~/.claude/settings.json under "hooks":
    "SessionStart": [{"hooks":[{"type":"command","command":"$HOOK_DST","timeout":10}]}]
EOF
fi

echo
echo "Done. Next steps:"
echo "  1. Edit $BRAIN/brain/index.md — fill in who you are and your active projects"
echo "  2. Name files in work/active/ after your project FOLDER names (e.g. my-project.md)"
echo "     so the hook auto-loads the right one per project"
echo "  3. Restart Claude Code — your brain now loads in every session"
echo "  4. Optional: create a PRIVATE GitLab/GitHub repo and: cd ~/brain && git remote add origin <url> && git push -u origin master"
