---
name: research-team
description: Multi-channel research fan-out process. Use whenever a task requires gathering external information — web research, investigating a tool/library/topic, community reactions, video content, or repo history. This includes research tickets inside /wayfinder maps, /deep-research runs, /research sessions, and any ad-hoc "หาข้อมูล / ค้นเพิ่ม / research X" request. Routes each question to the channel that can actually reach it (repo→codex, X→grok, video→NotebookLM, web→anysearch/web-agent) and synthesizes in the main loop.
---

# Research Team

Research is a two-layer process: **search channels fan out in parallel, the main loop synthesizes**. Never let a single search tool answer a multi-angle question, and never let a search tool be the final summarizer.

## The roster — route by what the channel can reach

| Channel | Reaches | Invoke |
|---|---|---|
| **codex** | Local repo, git history, `gh` CLI, files on disk | `Agent` tool, `subagent_type: codex:codex-rescue` |
| **web-agent** | Blogs, forums, docs, non-X social (multi-source sweeps) | `Agent` tool, `subagent_type: general-purpose`, instruct WebSearch/WebFetch |
| **anysearch** | General web search + full-page extract of a known URL | `mcp__anysearch__search` / `mcp__anysearch__extract` (load via ToolSearch) |
| **grok x_search** | X/Twitter — real posts, handles, sentiment. The ONLY channel with native X access | `Bash`: `grok -p "<question — X only>" --disable-web-search` (headless; auth in `~/.grok/auth.json`, Windows `%USERPROFILE%\.grok\auth.json`) |
| **NotebookLM** | YouTube videos, podcasts, PDFs, audio — media that text-fetch cannot read | `mcp__notebooklm-mcp__*`: notebook_create → source_add(url, wait=true) → notebook_query |
| **browser** | Pages that block plain fetch (login walls, heavy JS) | Claude Browser / playwright tools |
| **Apify** ⚠️paid | Structured scrapes of social/web that have no free reach — public Facebook pages/groups/keyword search, competitor timelines, other no-API platforms | `mcp__apify__*`: search-actors → call-actor (e.g. `apify/facebook-posts-scraper`) → dataset. **LAST RESORT — see budget gate below** |

**Not on the roster:** `agy` (Antigravity — coding agent, answers from model knowledge instead of searching). Small/fast models for synthesis.

### Apify budget gate (hard)

Apify credit is **~$5 total** — treat every run as spending real money that does not refill. Do NOT reach for Apify by default.

- **Exhaust the free channels first.** anysearch/web-agent/grok/NotebookLM/browser cover almost everything. Apify is only for structured data that genuinely has no free path (e.g. bulk public-Facebook post extraction).
- **Ask before spending.** Never call `call-actor` without first telling the user the actor, the estimated cost ($/1000 results × expected volume), and getting an explicit yes. A scrape is an irreversible spend.
- **Cap every run.** Always set the smallest `maxPosts`/`resultsLimit` that answers the question; never leave limits at default.
- **Free path exists → use it.** If anysearch can already reach a public page, use anysearch, not Apify.

If unsure whether a task justifies Apify, it doesn't — fall back to the free channels and say what a paid scrape would add.

## Process

1. **Decompose** the question into angles. Typical split: official docs / repo & git / community reaction / video-media / verification of specific claims.
2. **Fan out in parallel** — one channel per angle, launched in a single message. Do NOT send the same prompt to every channel; each gets only the angle it can uniquely reach.
3. **Tell each subagent what is already known** so it returns only net-new facts.
4. **Synthesize in the main loop** (the smartest available model): connect findings across channels, dedupe, surface contradictions, and verify load-bearing claims against primary sources before presenting.
5. **Report gaps honestly** — a channel that found nothing is a finding; say so.

## Sizing

- **Small question** → anysearch directly, no fan-out.
- **Medium** → 2–3 channels in parallel (typically codex + web-agent), synthesize.
- **Large / must-verify** → run `/deep-research`, and instruct its fan-out subagents to use this roster (grok for X angles, NotebookLM for any video source, codex for repo angles) instead of WebSearch alone.

## Integration points

- **/wayfinder**: when charting a map, add to the map's `## Notes`: "Research tickets follow the research-team skill." When resolving a `wayfinder:research` ticket, decompose and fan out per this roster.
- **/deep-research** and **/research**: this skill governs *which channels* those harnesses use; their own process (verification, citation, write-up conventions) still applies on top.
- Ad-hoc "ค้นเพิ่ม / หาข้อมูล / อะไรคือ X": apply the Sizing rule above.

## Channel notes

- grok x_search: keep `--disable-web-search` to force pure X results; bare product names drown in noise — include author handle or `/skill-name` in the query.
- NotebookLM: notebooks persist — reuse an existing notebook for the same source instead of re-ingesting.
- Costs are cents per session on every channel; choose by capability, not price.

## Setup on a new machine (portability)

This skill is git-synced via this repo. To make the whole process work on another machine (e.g. Claude Code / the Desktop app's **Code tab** on Windows):

1. `git pull` this repo, then run `scripts/link-skills.sh` (Bash/WSL) so the skill is linked into `~/.claude/skills`.
2. Run `scripts/setup-research-team.sh` — installs the global research rule into `~/.claude/CLAUDE.md` and the wayfinder self-heal git hooks.
3. Install the CLI channels: **grok** (`irm https://x.ai/cli/install.ps1 | iex` on Windows, then `grok login`), **codex** (`npm i -g @openai/codex`).
4. Add the MCP channels per machine: `claude mcp add` for anysearch/notebooklm; Apify via `claude mcp add --transport http --scope user apify https://mcp.apify.com` then authenticate. MCP auth is per-machine — it does not sync through git.
