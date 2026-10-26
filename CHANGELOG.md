# Changelog — pstack for Muse.ai and Hermes

## 1.2.0 (2026-10-26)

The verification-skill pair and two more playbooks, each in both variants (Hermes `pstack-*` and Muse.ai `muse-*`). All four ported from upstream pstack at pinned SHA d4575673 (v0.15.28); provenance and port notes are in each file's frontmatter.

- **create-verification-skill (new)** — generate a project-local verification skill (`skills/verify-<app>/` in the project repo): interview the repo for its surface, run, drive, observe, and isolation answers; generate a control CLI (doctor / drive / cleanup) and a feature map. Ships with the worked feature-map example under `references/feature-map-example/` on both variants.
- **maintain-verification-skill (new)** — the upkeep loop for a generated verification skill: parallel source readers per feature, one live session driving every feature, at most one PR of proven corrections. Outcomes are stated as clean / changed / blocked.
- **in-your-own-words (new)** — restate the problem before acting: the user's goals, the underlying issue, and what done looks like, with no hypotheses smuggled in. The restatement is the first artifact; a correction replaces the read completely.
- **tdd (new)** — test-first bug-fix discipline for bugs with a cheap local test path: make the broken behavior an executable failing test before touching production code, fix until it passes, and skip the new test when the test path is impractical.

## 1.1.0 (2026-10-24)

Playbook adoption pass: every Hermes playbook now leads with a one-screen checklist, and interrogate verdicts from local worker profiles are first-pass until second-witnessed.

- **One-screen checklists (Hermes side)** — `pstack-bug-fix`, `pstack-perf-issue`, `pstack-interrogate`, `pstack-arena`, and `pstack-swarm` each open with a short checklist distilled from the playbook's own steps, inserted right after the title. The full playbook text below each checklist is unchanged.
- **Interrogate fleet note (both sides)** — on the local worker profiles, an interrogate pass is FIRST-PASS only: the synthesized verdict does not land until the reviewer second-witnesses it in the kanban review step, verifying the claims mechanically (files, counts, test runs) before the verdict is posted or acted on. The note rides inside the Hermes checklist and as a standalone note in `skills/muse-interrogate/SKILL.md`.

## 1.0.0 (2026-10-19)

Initial public release. Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).

### Ported skills (Muse.ai side)

- `muse-mode` — task classifier and router
- `muse-bug-fix` — reproduce, bisect, fix, verify
- `muse-perf-issue` — baseline, fix, measure the delta
- `muse-interrogate` — adversarial diff review with two independent reviewers
- `muse-arena` — parallel candidate approaches, cross-judged
- `muse-swarm` — bulk parallelizable work with framed fan-out
- `muse-create-formal-verification-skill` — write a new skill with formal verification
- `muse-maintain-formal-verification-skill` — maintain a formally-verified skill

### Ported skills (Hermes side)

Same seven playbooks as `pstack-*` skills, adapted for Hermes agent profiles. See `hermes/` for the deploy script.

### Docs

- `docs/principles.md` — 24 distilled engineering principles
- `docs/models.md` — model seat mapping guide
- `UPSTREAM.md` — full provenance manifest

### Upstream SHAs

- Waves 1–2 (core skills): `99743e9c`
- Formal verification pair: `d4575673` (v0.15.28)

### Deferred (not ported)

Upstream items not yet ported: `correct`, `recall`, `architect` skills and ~18 remaining playbooks. See UPSTREAM.md for the full list.
