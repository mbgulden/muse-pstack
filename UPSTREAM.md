# Upstream Provenance

This repo is a port of **[pstack](https://github.com/cursor/plugins/tree/main/pstack)** — a set of agent skills and engineering principles by [Lauren Tan (poteto)](https://github.com/cursor/plugins), released under the **MIT License**.

## What pstack is

pstack is a "poteto stack": opinionated playbooks for how AI coding agents should work — bug fixing, performance investigation, adversarial code review, parallel experimentation, and bulk task execution. It was built for Cursor's agent environment.

## What this repo is

A distillation of pstack for two platforms it wasn't written for:

- **Muse.ai** — skills renamed `muse-*`, Cursor-specific mechanics (Task tool, slash triggers, `.mdc` rules) replaced with platform-generic equivalents (subagent dispatch, skill files, model seats).
- **Hermes** — skills kept as `pstack-*` (matching upstream naming), adapted for Hermes agent profiles and orchestration patterns.

## Pinned upstream versions

| Port wave | Upstream SHA | Upstream version | Port date |
|-----------|-------------|-----------------|-----------|
| Wave 1 (principles, models, router) | `99743e9c151c8537cbbf1f98bb38f34ef3368453` | pre-release | 2026-10-15 |
| Wave 2 (5 core skills) | `99743e9c151c8537cbbf1f98bb38f34ef3368453` | pre-release | 2026-10-19 |
| Formal verification pair | `d4575673` | v0.15.28 | 2026-10-19 |

## What's ported

### Principles (24 files → `docs/principles.md`)
All 24 upstream principle files distilled into enforceable engineering rules. 21 were new; 3 were already common practice (noted at the bottom of the doc).

Upstream: `pstack/skills/principle-*/SKILL.md`

### Router (`skills/muse-mode/SKILL.md`)
The task-classification router: what kind of task is this, which playbook applies, what protocols govern the work. Ported from upstream `poteto-mode`, with the transcript-mining origin replaced by a clean router design.

Upstream: `pstack/skills/poteto-mode/SKILL.md`, `pstack/skills/automate-me/SKILL.md`, `pstack/skills/setup-pstack/SKILL.md`

### Core skills (Wave 2)

| Skill (Muse.ai) | Skill (Hermes) | Upstream source |
|-----------------|----------------|-----------------|
| `muse-bug-fix` | `pstack-bug-fix` | `poteto-mode/playbooks/bug-fix.md` + `references/bugbot-triage.md` |
| `muse-perf-issue` | `pstack-perf-issue` | `poteto-mode/playbooks/perf-issue.md` + `benchmark-checklist` |
| `muse-interrogate` | `pstack-interrogate` | `interrogate/SKILL.md` + 4 references (embedded) |
| `muse-arena` | `pstack-arena` | `arena/SKILL.md` |
| `muse-swarm` | `pstack-swarm` | `swarm/SKILL.md` |

### Formal verification pair

| Skill (Muse.ai) | Skill (Hermes) | Upstream source |
|-----------------|----------------|-----------------|
| `muse-create-formal-verification-skill` | `pstack-create-formal-verification-skill` | `create-formal-verification-skill/SKILL.md` @ v0.15.28 |
| `muse-maintain-formal-verification-skill` | `pstack-maintain-formal-verification-skill` | `maintain-formal-verification-skill/SKILL.md` @ v0.15.28 |

## What's deferred (not yet ported)

From the upstream triage (132 files inventoried):

- **`correct`, `recall`** — standalone skills, phase-2 candidates
- **`architect`** — design skill, phase-2 candidate
- **Remaining playbooks** — `feature`, `refactoring`, `babysit`, `shipping`, `orchestrate`, `autonomous-run`, `session-pickup`, `investigation`, `hillclimb`, and others (~18 playbooks)
- **`create-verification-skill` / `maintain-verification-skill`** — the original (non-formal) verification pair
- **`comment-sicko`** — read-only comment reviewer
- **`benny`** — Slack-triage automation pack
- **`poteto-agent`** — subagent wrapper

These are tracked for future porting waves. The upstream repo is MIT-licensed; nothing here is copied verbatim — every file was adapted, with port notes in the frontmatter explaining what changed.

## License attribution

```
pstack — MIT License, © 2026 Lauren Tan
Source: https://github.com/cursor/plugins/tree/main/pstack
```

This repo's own LICENSE is also MIT. The port is a derivative work; the upstream MIT license is honored by attribution and by keeping the same permissive terms.
