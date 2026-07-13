# research-team

Multi-channel research fan-out for Claude Code. Routes each research question
to the channel that can actually reach it, runs them in parallel, and
synthesizes in the main loop. See [SKILL.md](./SKILL.md) for the full process.

| Channel | Reaches |
|---|---|
| codex | local repo, git history, `gh` |
| web-agent | blogs, forums, docs, non-X social |
| anysearch | general web + full-page extract |
| grok x_search | X/Twitter (the only native-X channel) |
| NotebookLM | YouTube, podcasts, PDFs, audio |
| browser | login-walled / heavy-JS pages |
| Apify ⚠️paid | public Facebook/social scrapes — last resort, ~$5 credit |

## Install (any machine — macOS / Linux / Windows Code tab)

The skill and its scripts are git-synced by this repo. CLI binaries and MCP
auth are per-machine (secrets never ride in git).

```bash
# 1. clone the fork and enter it
git clone https://github.com/mp3wizard/mattpocock-skills
cd mattpocock-skills

# 2. link every skill into ~/.claude/skills  (needs bash — Git Bash or WSL on Windows)
bash scripts/link-skills.sh

# 3. install the two pieces git can't sync on its own:
#    - the global research rule in ~/.claude/CLAUDE.md
#    - the wayfinder self-heal git hooks (.git/hooks is never pulled)
bash scripts/setup-research-team.sh
```

### CLI channels (per machine)

```bash
# grok  (native X search)
curl -fsSL https://x.ai/cli/install.sh | bash      # macOS / Linux
#   Windows PowerShell:  irm https://x.ai/cli/install.ps1 | iex
grok login

# codex  (repo / git / gh)
npm i -g @openai/codex
```

### MCP channels (per machine — auth does not sync)

```bash
# Apify (paid, gated — see the budget rule in SKILL.md)
claude mcp add --transport http --scope user apify https://mcp.apify.com
#   then authenticate:  /mcp  →  apify

# anysearch / notebooklm: add per your own config with `claude mcp add`
```

## What syncs vs. what's per-machine

| | via `git pull` | per machine |
|---|---|---|
| this skill + scripts | ✅ | — |
| wayfinder self-heal block | ✅ | — |
| global `~/.claude/CLAUDE.md` rule | via `setup-research-team.sh` | run once |
| git hooks | via `setup-research-team.sh` | run once |
| grok / codex CLI | ❌ | install + login |
| MCP auth (Apify, …) | ❌ | add + authenticate |

## Updating

`git pull` refreshes the skill, the scripts, and the wayfinder block on every
machine at once (each installed skill is a symlink into this repo). Re-run
`scripts/setup-research-team.sh` only if the global rule or the git hooks
change — it is idempotent and safe to run repeatedly.

## Notes

- Windows: use the Desktop app's **Code tab** (full Claude Code). The Chat tab
  has no skills/subagents/Bash, so this process cannot run there.
- Windows MSIX installs read MCP config from a virtualized path
  (`%LOCALAPPDATA%\Packages\Claude_*\LocalCache\Roaming\Claude\`), not the
  documented `%APPDATA%\Claude\` — check there if MCP servers silently fail.
