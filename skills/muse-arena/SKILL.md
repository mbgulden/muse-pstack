---
name: muse-arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use when one attempt at a non-trivial artifact would lock in the wrong shape."
upstream: pstack/skills/arena/SKILL.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream. Cursor Task tool replaced with subagent.spawn; model slugs (claude-opus-5-5, grok-4.7) replaced with pstack-models.md arena seats (a worker model @ medium/high, qwen3.8-27b-ned @ medium, optional gguf seat). Cross-judge pool → muse (different family from runners, per the model-diversity requirement). The .mdc rule reference retargeted to docs/models.md. /tmp work dirs replaced with ~/workspace scratch (per the workspace-not-/tmp rule). Slash-trigger references removed."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Upstream SHA and port notes are in the frontmatter above. Cursor-specific
> mechanics (Task tool, slash triggers, .mdc rules) were replaced with
> platform-generic equivalents. "Jimmy" references rebranded to "Muse" for
> the Muse.ai platform. See [UPSTREAM.md](../../UPSTREAM.md) for the full
> port manifest.


# Arena

Open a todolist with one entry per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) before launching anything.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric, 3-6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners from the `arena runners` panel in `docs/models.md`:
   - Runner A: `worker-model` @ medium
   - Runner B: `qwen3.8-27b-ned` @ medium
   - Runner C: `worker-model` @ high
   - Runner D (optional): gguf alias @ medium — add when the arena covers multiple design directions
   Spawn more runners when the arena covers multiple design directions. Use the same seat N times when the work is generation-bound rather than judgment-sensitive. If a seat is unavailable, run that runner on the closest available seat and say so.
4. Give each candidate its own output location: a git worktree where possible, otherwise `~/workspace/arena-<slug>/candidate-<n>/` (never `/tmp` — working files live in the workspace).

## Phase B: Fan out

Spawn all N subagents in one message with `subagent.spawn` (background), each with the task, the path to the shared grounding, its own output path, and instructions to produce the artifact and a short rationale naming the alternatives it considered and what it rejected. Prefix each brief: "read muse-mode principles before work; never substitute a generic brief."

If a candidate produces no output, proceed with N-1 and note the dropout.

## Phase C: Cross-judge

After all Phase B candidates complete, spawn one read-only judge subagent on the `arena cross-judge pool` seat (`muse` — a different model family from the runners, which is the point). It sees the rubric and the candidates by path label, scores each criterion, and recommends a base with rationale. It runs in parallel with your reading in Phase D. Don't spawn it while candidates are still writing.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or smaller API.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in by hand so the result stays coherent under one mental model. Don't paste mechanically.

If the candidates converge on one shape, that is strong agreement. Note it and ship the consensus shape. No graft is needed. If they wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact like any other output: mechanical evidence (tests, hashes, live reads), never a bare exit code. If verification finds a problem the arena missed, either Phase A was wrong (re-frame and re-run) or a candidate caught it and you missed the graft (go back to Phase E). Don't paper over it.

## Outputs

One synthesized artifact, with a short synthesis note alongside naming the base and why, the cross-judge's verdict, each graft with its source candidate, what was rejected and why, any convergence or dropouts, and the verification result.
