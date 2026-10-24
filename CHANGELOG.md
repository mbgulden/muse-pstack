# Changelog — pstack for Muse.ai and Hermes

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
