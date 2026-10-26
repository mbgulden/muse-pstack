# pstack for Muse.ai and Hermes

**Version 1.2.0** — see [CHANGELOG.md](CHANGELOG.md) for what's included.

Opinionated agent playbooks — bug fixing, performance work, adversarial review, parallel experimentation, and bulk execution — ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto) for the Muse.ai platform and Hermes agent profiles.

## What this is

pstack is a set of engineering playbooks for AI coding agents. It was built for Cursor. This repo distills the methodology into platform-generic skills:

- **`skills/`** — for Muse.ai agents (`muse-bug-fix`, `muse-interrogate`, `muse-arena`, …)
- **`hermes/`** — for Hermes agent profiles (`pstack-bug-fix`, `pstack-interrogate`, …)
- **`docs/`** — the 24 engineering principles and the model-seat mapping guide

## Quick start

### Muse.ai

```bash
./install-muse.sh
```

Or manually:

1. Copy the `skills/` directory into `~/workspace/custom-skills/`.
2. Read `skills/muse-mode/SKILL.md` — it's the router. It tells you which playbook applies to which task.
3. Define your model seats in `docs/models.md` (which model fills the `frontier`, `worker`, and `reviewer-2` roles).
4. Read `docs/principles.md` — the 24 rules that govern everything.

When a task arrives: classify it (muse-mode) → run the playbook → verify mechanically.

### Hermes

1. Read `hermes/README.md`.
2. Run `hermes/deploy.sh` to install skills into your profiles.
3. Reference the skills in your profile SOUL.md files.

## The skills

| Skill | When to use it |
|-------|---------------|
| `muse-mode` | **Read first.** Classifies the task and routes to the right playbook. |
| `muse-bug-fix` | Something is broken. Reproduce, bisect, fix, verify. |
| `muse-perf-issue` | Something is slow. Baseline, fix, measure the delta. |
| `muse-interrogate` | Review a diff adversarially. Two independent reviewers, cross-checked. |
| `muse-arena` | N ways to do it. Parallel candidates, cross-judged, winner grafted. |
| `muse-swarm` | Bulk parallelizable work. Framed fan-out with a done predicate. |
| `muse-create-formal-verification-skill` | Write a new skill with formal verification. |
| `muse-maintain-formal-verification-skill` | Maintain an existing formally-verified skill. |

## Usage examples

### "This endpoint returns 500 sometimes"

> **You:** `POST /api/checkout returns 500 about 1 in 20 times. Can't reproduce reliably.`

**muse-mode** classifies this as a bug-fix task → **muse-bug-fix** fires:

1. Writes a reproduction script that hammers the endpoint 200 times
2. Catches the failure, captures the stack trace and request that triggered it
3. Bisects: it's a race between the inventory check and the payment hold
4. Fixes with a row-level lock, re-runs the repro 500 times — zero failures
5. Shows you the diff (12 lines) plus the before/after failure counts

You see the repro script, the root cause, and the proof it worked — not just "fixed it."

### "Is this diff safe to merge?"

> **You:** `Interrogate this diff before I merge.`

**muse-interrogate** runs two independent reviewers against the diff:

- **Reviewer 1** (frontier seat): walks every changed line, flags a missing null check on line 47
- **Reviewer 2** (different model family): independently flags the same line *plus* a subtle ordering issue in the migration
- **Cross-check:** both agree on the null check → high confidence. Only reviewer 2 caught the ordering → flagged as "single-reviewer finding, verify manually"

You get the findings ranked by confidence, not a rubber stamp.

### "Try a few approaches and pick the best"

> **You:** `Arena this: I need to cut API latency by 30%.`

**muse-arena** spins up 3 parallel candidates:

1. Add Redis caching on the hot path
2. Batch the N+1 queries into a single join
3. Move serialization off the request thread

Each is implemented and benchmarked independently. A cross-judge (different model from the implementers) picks #2 — biggest win, smallest diff, no new infrastructure. The winner is grafted in; the losers are discarded with their benchmarks kept for reference.

## Principles

Start with [`docs/principles.md`](docs/principles.md). Every principle has a named enforcement mechanism — not just "be careful," but "here's the check that makes it real."

A few favorites:

- **Attack the premise** — when two fixes fail the same way, stop fixing and test the assumption.
- **Smallest diff that solves it** — bias toward deletion.
- **Explain the number** — every measurement ships with its limiter, run count, and spread, or it doesn't ship.
- **Build the lever** — for non-trivial work, build the tool instead of doing it by hand.

## Provenance

Every skill file carries its upstream source, SHA, and port notes in the frontmatter. See [UPSTREAM.md](UPSTREAM.md) for the complete port manifest — what's ported, what's deferred, and the MIT license attribution.

## Updating

See [docs/UPDATING.md](docs/UPDATING.md) for how this repo stays in sync with upstream pstack.

## License

MIT. See [LICENSE](LICENSE).
