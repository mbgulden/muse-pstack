# Model Seats — mapping tasks to models

> **Provenance:** Concept ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (`setup-pstack` skill, MIT, © 2026 Lauren Tan / poteto).
> The upstream maps Cursor model slugs to task roles. This is the platform-generic version: define your own seats for your own models.

## The idea

Different tasks want different models. A cheap fast model is fine for bulk investigation; judgment calls want your strongest model; adversarial review wants *two different model families* so they don't share blind spots.

A **seat** is a named role with a model assignment and a reasoning-effort level. Skills reference seats, not specific models — so you can swap models without rewriting every skill.

## The seats, in plain English

There are three seats. Here's what each one means:

### `frontier` — your best thinking

This is the model you trust with hard calls. When something needs judgment — not just output, but *a decision* — it goes here.

- **Use for:** bug-fix root-cause judgment, interrogate reviewer 1, arena cross-judge, swarm final synthesis
- **Effort:** high. You're paying for the best reasoning the model can do.
- **Pick:** whatever your strongest available model is. If you only have one model, it fills this seat.

### `worker` — fast and cheap

This is the model that does the bulk work. Implementation, exploration, running the same thing 50 times to get a benchmark. It doesn't need to be brilliant — it needs to be fast and follow instructions.

- **Use for:** bug-fix implementation (after frontier decides the fix), perf-issue implementation, swarm per-slice work
- **Effort:** medium. Enough to follow multi-step instructions reliably.
- **Pick:** your fastest/cheapest capable model. Can be the same as frontier if you only have one.

### `reviewer-2` — the outsider

This is the whole point of adversarial review. Reviewer 2 **must** be a different model family from frontier. Two instances of the same model share the same blind spots, the same training biases, the same failure modes. The review becomes theater — they'll agree with each other because they think the same way.

- **Use for:** interrogate reviewer 2 (the independent check)
- **Effort:** high. This review needs to be as thorough as reviewer 1's.
- **Pick:** a model from a different provider/family than frontier. If you only have one model family available, you can still run interrogate — but note in your head that the "independent" review isn't truly independent.

## Sensible defaults

**If you're on Muse.ai with a single model:**

```yaml
frontier:   your-model @ high effort
worker:     your-model @ medium effort
reviewer-2: your-model @ high effort   # NOTE: same family — review diversity is reduced
```

This works fine for everything except true adversarial review. You'll still get value from interrogate's structured checklist, just not the cross-family disagreement detection.

**If you have two model families:**

```yaml
frontier:   family-A-strongest @ high effort
worker:     family-A-fast @ medium effort
reviewer-2: family-B-strongest @ high effort
```

This is the full setup. Interrogate gets real teeth — when the two reviewers disagree, that's signal.

**If you're on Hermes with local models:**

```yaml
frontier:   your-largest-local-model @ high effort
worker:     your-fastest-local-model @ medium effort
reviewer-2: <cloud API or second local family> @ high effort
```

Local-only setups can fill reviewer-2 with a cloud API call for high-stakes reviews, or accept reduced diversity.

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
