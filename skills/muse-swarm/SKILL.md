---
name: muse-swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for parallel coverage, races, gauntlets, and exploration."
upstream: pstack/skills/swarm/SKILL.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream. Cursor Task tool (subagent_type, environment flags) replaced with subagent.spawn; model slugs (grok-4.7) replaced with pstack-models.md swarm-worker seats (a worker model @ medium, qwen3.8-27b-ned @ medium, optional gguf third). The .mdc rule reference retargeted to docs/models.md. The cloud/local environment distinction is dropped — subagents here run on this VM; workers that need the user's computer say so in their brief. Slash-trigger references removed."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Upstream SHA and port notes are in the frontmatter above. Cursor-specific
> mechanics (Task tool, slash triggers, .mdc rules) were replaced with
> platform-generic equivalents. "Jimmy" references rebranded to "Muse" for
> the Muse.ai platform. See [UPSTREAM.md](../../UPSTREAM.md) for the full
> port manifest.


# Swarm

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Pick the worker seats from the `swarm workers` panel in `docs/models.md`:
   - `worker-model` @ medium
   - `qwen3.8-27b-ned` @ medium
   - (add the gguf alias as a third worker when slices > 2)
   If a seat is unavailable, use the closest available seat and say so. For a model race, name each arm's seat up front.
4. Give each worker its own writable output under `~/workspace/` when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers in one message with `subagent.spawn` (background). Prefix each brief: "read muse-mode principles before work; never substitute a generic brief."

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

## Phase D: Report

Return one consolidated report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
