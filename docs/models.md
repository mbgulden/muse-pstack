# Model Seats — mapping tasks to models

> **Provenance:** Concept ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (`setup-pstack` skill, MIT, © 2026 Lauren Tan / poteto).
> The upstream maps Cursor model slugs to task roles. This is the platform-generic version: define your own seats for your own models.

## The idea

Different tasks want different models. A cheap fast model is fine for bulk investigation; judgment calls want your strongest model; adversarial review wants *two different model families* so they don't share blind spots.

A **seat** is a named role with a model assignment and a reasoning-effort level. Skills reference seats, not specific models — so you can swap models without rewriting every skill.

## How to define your seats

Create a table like this for your setup:

| Seat | Model | Effort | Used for |
|------|-------|--------|----------|
| `frontier` | your strongest model | high | Judgment calls, cross-judge, hardest tasks, final review |
| `worker` | your fast/cheap model | medium | Bulk investigation, implementation, per-slice swarm work |
| `reviewer-2` | a *different family* from frontier | high | Second reviewer in interrogate (diversity matters) |

## Rules

- **Judge seats go to the strongest model.** Anything that makes a call — cross-judge, lead judgment, final synthesis — uses `frontier`.
- **Reviewer diversity is load-bearing.** In `muse-interrogate`, the two reviewers must be different model families. Two instances of the same model share the same blind spots; the review is theater.
- **Effort tiers are per-seat, not per-call.** Set the reasoning effort on the seat definition, not scattered through skill files.
- **Skills reference seats, never model names.** When you swap models, you update this file — not seven skill files.

## Example mapping (adapt to your stack)

```
frontier:    your best model @ high effort
             → bug-fix judge, interrogate reviewer 1, arena cross-judge, swarm synthesizer

worker:      your fast model @ medium effort
             → bug-fix implementation, perf-issue implementation, swarm slices

reviewer-2:  different family from frontier @ high effort
             → interrogate reviewer 2
```

## Anti-patterns

- Don't put the same model in both reviewer seats "for consistency." That's the opposite of the point.
- Don't hardcode model names in skill files. That's what this file is for.
- Don't skip the effort tier. A strong model at low effort can underperform a weaker model at high effort on judgment tasks.
