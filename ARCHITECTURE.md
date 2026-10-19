# Architecture

How the pieces fit together.

## The big picture

```
┌─────────────────────────────────────────────────┐
│                    muse-mode                      │
│              (the router — read first)            │
│                                                   │
│   Task arrives → classify → route to playbook     │
└──────────┬──────────────────────────────────────┘
           │
     ┌─────┴──────┬──────────────┬─────────────┐
     ▼            ▼              ▼             ▼
┌─────────┐ ┌───────────┐ ┌────────────┐ ┌──────────┐
│ bug-fix │ │perf-issue │ │interrogate │ │  arena   │
│         │ │           │ │            │ │          │
│ Repro → │ │ Baseline→ │ │ Two indep. │ │ N candi- │
│ bisect→ │ │ vet → fix │ │ reviewers, │ │ dates,   │
│ fix →   │ │ → delta   │ │ cross-check│ │ cross-   │
│ verify  │ │           │ │ findings   │ │ judge    │
└─────────┘ └───────────┘ └────────────┘ └──────────┘
     │                                     │
     └──────────┬──────────────────────────┘
                ▼
         ┌────────────┐
         │   swarm    │
         │            │
         │ Framed     │
         │ fan-out,   │
         │ N workers, │
         │ done pred. │
         └────────────┘
```

Plus two meta-skills:

- **`muse-create-formal-verification-skill`** / **`muse-maintain-formal-verification-skill`** — skills that write and maintain other skills with formal verification. Meta-level tooling.

And the foundation:

- **`docs/principles.md`** — 24 engineering principles, each with a named enforcement mechanism. Read these before writing code.
- **`docs/models.md`** — how to map your models to task seats. Skills reference seats, not model names.

## How a task flows

1. **muse-mode** classifies the task. "Something is broken" → `muse-bug-fix`. "It's slow" → `muse-perf-issue`. "Review this diff" → `muse-interrogate`. "N ways to do it" → `muse-arena`. "Do these 20 things" → `muse-swarm`.
2. The playbook skill runs. Each one has the same shape: **own the task, gather evidence, act on evidence, verify mechanically.**
3. Principles apply throughout. "Attack the premise" when fixes keep failing. "Smallest diff" when writing the fix. "Explain the number" when reporting measurements.

## Muse.ai vs Hermes

The skills exist in two flavors:

| | Muse.ai (`skills/`) | Hermes (`hermes/skills/`) |
|---|---|---|
| Naming | `muse-*` | `pstack-*` (upstream) |
| Delegation | `subagent.spawn` | Hermes orchestration |
| Router | `muse-mode` | Referenced by profile SOUL.md |
| Model seats | `docs/models.md` | Profile-local config |

The methodology is identical. Only the platform mechanics differ. Port notes in each skill's frontmatter explain exactly what was adapted.

## Design decisions

**Why two namings?** The Muse.ai side is branded for the platform (`muse-bug-fix`). The Hermes side keeps upstream `pstack-*` naming so Hermes users familiar with pstack recognize them.

**Why embed references?** Upstream pstack spreads content across SKILL.md + references/. We fold references inline so each skill is a single self-contained file. Easier to deploy, easier to read.

**Why seats, not model names?** Skills say "delegate to the `worker` seat," not "delegate to model X." You define your seats once in `docs/models.md`; swapping models doesn't touch the skills.

**What was cut?** Cursor-specific mechanics: the Task tool (replaced by subagent dispatch / orchestration), slash triggers (replaced by skill-read convention), `.mdc` rule files (replaced by SKILL.md frontmatter), `/loop` for long hunts (replaced by cron + heartbeat pattern).
