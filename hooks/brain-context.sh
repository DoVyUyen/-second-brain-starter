#!/bin/bash
# SessionStart hook: inject second-brain context into every Claude session.
# stdout becomes session context.

BRAIN="$HOME/brain/brain"
ACTIVE="$HOME/brain/work/active"
PROJECT="$(basename "$PWD")"

{
  if [ -f "$BRAIN/index.md" ]; then
    echo "# Second brain — index"
    cat "$BRAIN/index.md"
    echo
  fi

  if [ -f "$BRAIN/log.md" ]; then
    echo "# Second brain — recent log (last 30 lines)"
    tail -30 "$BRAIN/log.md"
    echo
  fi

  if [ -f "$ACTIVE/$PROJECT.md" ]; then
    echo "# Second brain — active work for this project ($PROJECT)"
    cat "$ACTIVE/$PROJECT.md"
  fi
} 2>/dev/null
exit 0
