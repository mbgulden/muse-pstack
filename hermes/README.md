# Hermes deployment

How to install the pstack skills into Hermes agent profiles.

## What gets deployed

The `skills/` directory contains 7 skills, ported from upstream pstack and adapted for Hermes:

| Skill | Profiles | Why |
|-------|----------|-----|
| `pstack-bug-fix` | all | Core debugging playbook |
| `pstack-perf-issue` | all | Performance investigation |
| `pstack-interrogate` | all | Adversarial review (needs 2+ model families) |
| `pstack-create-formal-verification-skill` | all | Meta-skill: write verified skills |
| `pstack-maintain-formal-verification-skill` | all | Meta-skill: maintain verified skills |
| `pstack-arena` | orchestrator only | Parallel candidates + cross-judge (needs orchestration) |
| `pstack-swarm` | orchestrator only | Framed fan-out (needs orchestration) |

Arena and swarm go to the orchestrator profile only — they need multi-agent orchestration that worker profiles don't have.

## Deploy

```bash
./deploy.sh
```

The script:
1. Reads `config.yaml` (copy from `config.example.yaml`) for your Hermes home directory and profile list.
2. Copies each skill's `SKILL.md` into `<hermes-home>/profiles/<profile>/skills/<skill>/`.
3. Verifies every file landed (line counts).

## Wire into profiles

Add to each profile's `SOUL.md` (or system prompt):

```markdown
## pstack playbooks

When a task matches a playbook, read the corresponding skill file first:
- Bug → `skills/pstack-bug-fix/SKILL.md`
- Slow → `skills/pstack-perf-issue/SKILL.md`
- Review this diff → `skills/pstack-interrogate/SKILL.md`
(Orchestrator only: `pstack-arena`, `pstack-swarm`)
```

## Model seats

The skills reference model seats (`frontier`, `worker`, `reviewer-2`), not specific models. Define your seats in each profile's config — see [`../docs/models.md`](../docs/models.md) for the pattern.

The key rule: **interrogate's two reviewers must be different model families.** If all your profiles run the same model, interrogate degrades to a single-perspective review. The skill still works, but say so in the output.
