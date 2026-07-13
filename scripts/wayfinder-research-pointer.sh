#!/usr/bin/env bash
# Self-heal: ensure the research-team integration block exists in wayfinder/SKILL.md.
# Idempotent. Called by .git/hooks/post-merge and post-rewrite after upstream pulls,
# so if a merge from origin (mattpocock/skills) drops the block, it is re-appended.
# Safe to run anywhere: no-ops unless the wayfinder skill file is present.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] || exit 0

target="$root/skills/engineering/wayfinder/SKILL.md"
[ -f "$target" ] || exit 0

marker="research-team-integration"
if grep -q "$marker" "$target"; then
  exit 0   # already present — nothing to do
fi

cat >> "$target" <<'BLOCK'

<!-- BEGIN research-team-integration (local fork addition — auto-re-added by .git/hooks/post-merge & post-rewrite if an upstream merge removes it) -->

## Research integration (local fork)

Resolving a `wayfinder:research` ticket — or any search this map needs — follows the **research-team** skill: fan out to the channel that can actually reach each angle (codex→repo/git, grok x_search→X/Twitter, NotebookLM→YouTube/media, anysearch/web-agent→web, browser→blocked pages) and synthesize in the main loop. Never let a single search tool answer a multi-angle question; never let a search tool write the final synthesis. When charting a map, add the line "Research tickets follow the research-team skill" to the map's `## Notes` so parallel sessions inherit it.

<!-- END research-team-integration -->
BLOCK

echo "[wayfinder-research-pointer] re-added research-team block to $target"
