---
name: pstack-arena
description: "Spawn N parallel candidates at the same task with an identical brief, cross-judge them, pick a base, graft the strongest parts of the losers in, verify. Use for 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape. Fred (orchestrator) only."
upstream: pstack/skills/arena/SKILL.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream arena skill. Cursor Task-tool/subagent_type/run_in_background mechanics replaced with Hermes orchestration (Fred dispatches workers). Model slugs (claude-opus/grok) replaced with your model configuration arena runner panel: A=worker-model @ medium, B=qwen3.8-27b-ned @ medium, C=worker-model @ high, optional D=gguf @ medium; cross-judge = the orchestrator. your model configurationc path replaced with your model configuration. /tmp/arena paths kept with workspace preference noted."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Adapted for Hermes agent profiles. See [UPSTREAM.md](../../UPSTREAM.md).


# Arena

**Fred (orchestrator) only.** Open a task list with one entry per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) before launching anything.

## Phase A — Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric: 3–6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners from the `arena runners` panel in your model configuration (`~/workspace/pstack-port/your model configuration`):
   - Runner A: `worker-model` @ medium
   - Runner B: `qwen3.8-27b-ned` @ medium
   - Runner C: `worker-model` @ high
   - Runner D (optional): gguf alias @ medium — add when the arena covers multiple design directions
   - Use the same seat N times when the work is generation-bound rather than judgment-sensitive.
4. Give each candidate its own output location (a git worktree where possible, otherwise `~/workspace/arena-<slug>/candidate-<n>/`), so candidates never share mutable state.

## Phase B — Fan out

Dispatch all N workers in parallel via Hermes orchestration. Each gets the task, the path to shared grounding, its own output path, and instructions to produce the artifact plus a short rationale naming the alternatives it considered and rejected.

If a candidate produces no output, proceed with N-1 and note the dropout.

## Phase C — Cross-judge

After all candidates complete, the cross-judge is `frontier-reviewer` (per your model configuration — must be a different family from the runners). The judge sees the rubric and the candidates by path label, scores each criterion, and recommends a base with rationale. Run the judge in parallel with your own reading in Phase D. Don't start judging while candidates are still writing.

## Phase D — Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge. Agreement confirms the pick. Disagreement means bias or an ambiguous rubric — read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or smaller API.

## Phase E — Graft

Walk each losing candidate once more for what's worth porting into the base — usually one or two things per candidate, not most of it. Fold each graft in by hand so the result stays coherent under one mental model. Don't paste mechanically.

If candidates converge on one shape, that's strong agreement — note it and ship the consensus. No graft needed. If they wildly diverge, Phase A was under-specified: reframe and re-run rather than averaging the divergence.

## Phase F — Verify

Verify the synthesized artifact like any other output. If verification finds a problem the arena missed, either Phase A was wrong (reframe and re-run) or a candidate caught it and you missed the graft (back to Phase E). Don't paper over it.

## Output

One synthesized artifact, with a short synthesis note alongside: the base and why, the cross-judge's verdict, each graft with its source candidate, what was rejected and why, any convergence or dropouts, and the verification result.
