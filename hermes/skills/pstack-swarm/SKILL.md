---
name: pstack-swarm
description: "Fan out N parallel workers on framed slices or a declared race, drain them, return one consolidated report. Use for 'swarm this', parallel coverage, races, gauntlets, and exploration. Fred (orchestrator) only."
upstream: pstack/skills/swarm/SKILL.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream swarm skill. Cursor Task-tool/subagent_type/environment mechanics replaced with Hermes orchestration (Fred dispatches workers). Model slug default replaced with your model configuration swarm worker panel: worker-model @ medium, qwen3.8-27b-ned @ medium (gguf alias as third worker when slices > 2). your model configurationc path replaced with your model configuration. cloud_base_branch concept dropped (local worktrees cover it)."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Adapted for Hermes agent profiles. See [UPSTREAM.md](../../UPSTREAM.md).


# Swarm

## Checklist (read this first — full playbook below)
1. Frame: done predicate + shape (slices / race / mix); declare the race rule BEFORE spawning.
2. Every brief stands alone: goal, exact slice, how to verify, report format (PASS / ISSUES / BLOCKED with evidence).
3. Fan out in parallel; each worker gets its own writable output.
4. Aggregate: drop results missing the named SHAs/method, respawn once; a gap is NOT a pass.
5. One consolidated report: result table, issue one-liners, gaps — no raw worker dumps.


**Fred (orchestrator) only.** Open a task list with one entry per phase (Frame, Fan out, Aggregate, Report) before launching anything.

## Phase A — Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape: partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` **before** spawning.
3. Pick workers from the `swarm workers` panel in your model configuration (`~/workspace/pstack-port/your model configuration`):
   - `worker-model` @ medium
   - `qwen3.8-27b-ned` @ medium
   - Add the gguf alias as a third worker when slices > 2.
4. Give each worker its own writable output when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B — Fan out

Dispatch all N workers in parallel via Hermes orchestration. Every brief stands alone: the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C — Aggregate

Read the terminal results. Drop a result that doesn't record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. **A gap does not count as a pass.** For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Do not paste raw worker dumps.

## Phase D — Report

Return one consolidated report: the result table, issue one-liners, gaps or dropouts, and the race rule when one was used.
