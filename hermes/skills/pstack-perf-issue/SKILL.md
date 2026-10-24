---
name: pstack-perf-issue
description: "Fix a measured performance issue: baseline trace, vet every number with the benchmark checklist, apply the performance mantras cheapest-first, verify with a post-fix trace, cite the delta. Use when something is measurably slow."
upstream: pstack/skills/poteto-mode/playbooks/perf-issue.md + pstack/skills/benchmark-checklist/SKILL.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream perf-issue playbook + benchmark-checklist skill. Model slug mapped to worker-model @ medium per your model configuration. 'Control skill' references retargeted to profile tooling. Hillclimb playbook referenced as DEFERRED (not ported). Benchmark checklist's 7 questions folded in as a section. Task-tool mechanics replaced with Hermes orchestration pattern."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Adapted for Hermes agent profiles. See [UPSTREAM.md](../../UPSTREAM.md).


# Perf issue

## Checklist (read this first — full playbook below)
1. Baseline trace on the real surface first; vet it with the benchmark checklist.
2. Hypotheses come from measurements, not from reading source.
3. Mantras cheapest-first: don't do it, don't redo it, do it less, later, in background, concurrently, cheaper. Stop when the target is met.
4. One change at a time; post-fix trace before the next attempt.
5. Compare the artifacts; "inconclusive" is not a pass.
6. PR cites one primary number + delta. Draft PR only.
Reply: baseline, post-fix number, delta, artifact path.


**You own the measurement story. Plan, review, verify the numbers.** Tie every fix to a measurement, don't read source instead of measuring.

## Steps

1. **Capture a baseline trace** on the real surface. Vet the baseline — and each later number — with the benchmark checklist below.
2. **Ground hypotheses by measuring.** Don't claim a perf ceiling without running it first. Try the performance mantras in order, cheapest first:
   1. Don't do it. Stop work whose result nothing uses rather than cheapening it.
   2. Do it, but don't do it again. (Cache, memoize.)
   3. Do it less. (Reduce frequency, batch.)
   4. Do it later. (Defer, lazy-load.)
   5. Do it when they're not looking. (Background, off-peak.)
   6. Do it concurrently. (Parallelize.)
   7. Do it cheaper. (Optimize the hot path.)
   
   When an earlier mantra meets the target, stop.
3. **Plan the fix from the trace.** If it crosses a function boundary, design it first. Implement at the configured perf-issue seat (`worker-model` @ medium, per your model configuration). Capture a post-fix trace. Verify each attempt before trying the next — don't stack untested changes.
4. **Compare the artifacts** (JSON to sqlite, diff). "Inconclusive" or wrong-surface is not a pass. Flag it.
5. **Cite the measurement in the PR.** One primary number in the PR body; runs, range, and limiter evidence in a linked artifact or notes file.
6. **Open a draft PR.** the user merges.

For sustained improvement against a metric rather than a one-off fix, the Hillclimb playbook applies (DEFERRED — not yet ported; ask The orchestrator).

**Reply:** baseline number, post-fix number, delta, artifact path.

## Benchmark checklist

Use this when you produce a performance number. Answer each question with evidence from a run, not a guess about the code.

**Before you run anything:**
- Write down the claim you expect to make, in the words you would ship ("export is 30% faster at p50 on the 60k-row dataset").
- Read the measurement script. Note what it times, counts, and ignores.
- Check `uptime` and `nproc`. If the machine is busy, find out what's running. If you can't stop it, interleave the sides so both see the same noise, and say so.

**The questions:**

1. **Why not double?** Name the limiter. Profile in a run you don't report (profilers slow the work down). Use CPU per process, a runtime profiler, I/O wait, syscall counts — then map the hot spot to source. If a change didn't move the number, the limiter explains why. Find it before calling the change useless.
2. **Was it tuned?** Run every side the way production runs it: release builds, production flags, batching, connection pools, warm/cold caches as production sees them, same versions and data. If one side runs on defaults, you compared configurations, not implementations.
3. **Did it break limits?** Do the arithmetic. Removing a piece that takes 10% of the run can make it at most ~11% faster. A result past a limit measured something other than the work — a cache, a no-op, or a bug.
4. **Did it error?** Count failures and non-success responses. Check outputs are correct, not just present. Rejections are often fast; timeouts and retries are slow.
5. **Does it reproduce?** Run each side at least 5 times, alternating (A, B, A, B...) so warmup and drift favor neither. Report median and range. A gap smaller than run-to-run variation is no measurable difference.
6. **Does it matter?** Next to any micro result, measure the end-to-end path a user waits on with realistic data sizes and concurrency. A helper taking 1% of a request can make it at most 1% faster.
7. **Did it even happen?** Confirm the work ran inside the timed region: the request reached the server, the rows were written, the bytes were read. Lazy code and timeouts produce numbers for work that never happened.

**Report:** Lead with the verdict (faster / slower / no measurable difference / inconclusive). Give the number with its unit, run count, range, and limiter. Call it inconclusive when you can't name the limiter, a side ran untuned, or you couldn't check questions 4 and 7 — and name the gap.
