---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. **Always fan out through the research-team roster**: codex (repo/git/local files) and grok x_search (X/Twitter) run on every invocation of this skill, regardless of question size; this overrides research-team's own Sizing tier, which only fans those two out at medium/large. Add other roster channels (web-agent, anysearch, wigolo, NotebookLM/watch, browser) as the question's angles call for. Never add `agy`/Antigravity, it answers from model knowledge instead of searching and stays off the roster.
3. Write the findings to a single Markdown file, citing each claim's source and which channel surfaced it.
4. **Always save to `~/Public/research/`**, the fixed destination for every report this skill generates, regardless of what repo or directory the invocation happened in. Create the directory if it doesn't exist. Do not follow a repo-local notes convention for this skill's output; that rule is superseded by this fixed location.
