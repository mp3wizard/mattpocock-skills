# Automated Security Scan Report
**Target:** `/Users/mp3wizard/Public/Claude skill/mattpocock-skills`
**Scanned at:** 2026-07-07T20:07+07:00  **Git HEAD:** 16a2a5c
**Standard:** OWASP APTS-aligned (Scope Enforcement · Auditability · Manipulation Resistance · Reporting)

## Verdict: ✅ SAFE TO INSTALL

Repo scanned before install. No secrets, no malicious code, no injection in the
promoted skills. One low-impact dev-dependency advisory (not shipped in skills).

## Scope Record
- Scan target: repo cwd (`mattpocock-skills`)
- Git HEAD: 16a2a5c
- Include: all supported | Exclude: .git, node_modules, .out-of-scope
- Composition: 116 `.md`, 5 `.sh`, 4 `.json`, 0 `.py`

## Coverage Disclosure
| Tool | Ran? | Result |
|------|------|--------|
| gitleaks (git history + fs) | OK | no leaks — 224 commits, 782 KB |
| trufflehog (git) | OK | 0 verified, 0 unverified |
| trivy fs (vuln/secret/misconfig) | OK | 0 secrets, 0 misconfig |
| osv-scanner (deps) | OK | 1 MEDIUM (dev dep) — see below |
| semgrep p/secrets | OK | no findings |
| semgrep p/bash (shell scripts) | OK | no findings |
| skill-audit.sh (all SKILL.md) | OK | 3 heuristic flags, all false-positive on inspection |
| bandit | N/A | no `.py` in scope |
| mcp-exfil-scan.sh | SKIPPED | ⚠️ bundled-script SHA256 MISMATCH — scanner's own tool, not run per skill rule |

## Findings

### 1. js-yaml 3.14.2 — MEDIUM (dev dependency)
- GHSA-h67p-54hq-rp68, CVSS 5.3. Fixed in 3.15.0.
- Transitive **dev** dep in `package-lock.json`; not part of any shipped skill.
- Impact: none on installed skills. Optional: `npm audit fix`.

### 2. skill-audit heuristic flags — all FALSE POSITIVE
- `skills/deprecated/qa/SKILL.md` "netcat" → matched benign prose ("sync service
  fails to apply the patch"). Bucket = `deprecated/`, excluded from install.
- `skills/in-progress/writing-fragments/SKILL.md`, `writing-shape/SKILL.md`
  "prompt injection" → targeted grep found no real injection directives; regex
  tripped on writing-advice prose. Bucket = `in-progress/`.

### 3. Install script `scripts/link-skills.sh` — SAFE
- Symlinks only, `set -euo pipefail`, no network / no eval.
- Excludes `deprecated/`. Collision check: no repo skill name matches an existing
  real dir in `~/.claude/skills` or `~/.agents/skills`, so its `rm -rf` never fires.

## Actions Taken
1. Ran `scripts/link-skills.sh` — 34 skills symlinked into `~/.claude/skills` and
   `~/.agents/skills` (exit 0, links verified).
2. Packed the 5 `productivity` skills into
   `mattpocock-productivity-skills.zip` (24K) for manual Cowork install.

## Manipulation-Resistance Note
The invoking Thai args string appeared echoed inside the scanner plugin's own
`SKILL.md` bash fallbacks — a `$ARGUMENTS` templating artifact, treated as data,
not acted on.

## Coverage Gaps
Static scan only. Not covered: runtime behavior, business logic, LLM-mode skill
analysis (opt-in, not run). mcp-exfil-scan skipped due to scanner-tool integrity
failure (reinstall the security plugin from a trusted release to restore it).
