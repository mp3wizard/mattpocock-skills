#!/usr/bin/env bash
# Portable setup for the research-team process on a new machine.
# Run once after cloning + `scripts/link-skills.sh`. Idempotent.
#
# Does two things git can't do on its own:
#   1. Installs the global research rule into ~/.claude/CLAUDE.md (user-global,
#      not tracked by any repo).
#   2. Installs the wayfinder self-heal git hooks (.git/hooks is never pulled).
#
# CLI/MCP channels (grok, codex, anysearch, notebooklm, apify) are per-machine
# installs — see this skill's "Setup on a new machine" section.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="Research Workflow"

# 1. Global research rule ---------------------------------------------------
mkdir -p "$HOME/.claude"
if [ -f "$CLAUDE_MD" ] && grep -q "$MARKER" "$CLAUDE_MD"; then
  echo "[setup] research rule already in $CLAUDE_MD"
else
  cat >> "$CLAUDE_MD" <<'RULE'

## Research Workflow

Any task that gathers external information — web lookups, "หาข้อมูล/ค้นเพิ่ม", investigating tools/libraries/topics, community reactions, video content, repo history — MUST follow the `research-team` skill (multi-channel fan-out: codex→repo/git, grok x_search→X/Twitter, NotebookLM→YouTube/media, anysearch/web-agent→web, browser→blocked pages; synthesize in the main loop). Apify is a paid last-resort scraping channel (~$5 credit) — never call it without confirming cost with the user first; see the skill's budget gate.

This applies at every entry point:
- `/wayfinder` — research tickets resolve via research-team; when charting a map, add "Research tickets follow the research-team skill" to the map's `## Notes`.
- `/deep-research` and `/research` — instruct their fan-out subagents to use the research-team roster (grok for X angles, NotebookLM for video sources, codex for repo angles), not WebSearch alone.
- Ad-hoc questions — size per the skill (small → anysearch direct; medium+ → fan out).

Never use `agy` (Antigravity) for research. Never let a search channel write the final synthesis.
RULE
  echo "[setup] appended research rule to $CLAUDE_MD"
fi

# 2. Wayfinder self-heal git hooks -----------------------------------------
HOOKDIR="$(git -C "$REPO" rev-parse --git-path hooks)"
case "$HOOKDIR" in /*) : ;; *) HOOKDIR="$REPO/$HOOKDIR" ;; esac
mkdir -p "$HOOKDIR"
for h in post-merge post-rewrite; do
  f="$HOOKDIR/$h"
  if [ -f "$f" ] && grep -q "wayfinder-research-pointer" "$f"; then
    echo "[setup] $h already wired"
  elif [ -f "$f" ]; then
    printf '\n"%s/scripts/wayfinder-research-pointer.sh" || true\n' "$REPO" >> "$f"
    echo "[setup] appended to existing $h"
  else
    printf '#!/usr/bin/env bash\n"%s/scripts/wayfinder-research-pointer.sh" || true\n' "$REPO" > "$f"
    chmod +x "$f"
    echo "[setup] created $h"
  fi
done

echo "[setup] done. Next: install grok + codex CLIs and add the MCP channels (see research-team SKILL.md)."
