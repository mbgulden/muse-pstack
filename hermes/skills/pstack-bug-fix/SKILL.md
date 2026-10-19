---
name: pstack-bug-fix
description: "Fix a bug the scientific way: reproduce on the real surface, binary-search the cause with runtime evidence, plan the fix, verify on the same surface, stage failing-test-first commits. Use when something is broken."
upstream: pstack/skills/poteto-mode/playbooks/bug-fix.md + pstack/skills/poteto-mode/references/bugbot-triage.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream bug-fix playbook + bugbot-triage reference. Cursor /loop replaced with cron/heartbeat pattern. Model slug grok-4.7-xhigh-fast mapped to worker-model @ medium per your model configuration. 'Control skill' references retargeted to the agent's profile tooling. 'Opening a PR' retargeted to local draft-PR convention (the user merges). Task-tool/subagent_type mechanics replaced with Hermes orchestration pattern. Bugbot-triage reference folded in as a section."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Adapted for Hermes agent profiles. See [UPSTREAM.md](../../UPSTREAM.md).


# Bug fix

**You own this task. Plan, review, verify.** Be scientific. Every shipped line traces to runtime evidence. Belt-and-suspenders that "might help" is a hypothesis, not a fix. It does not ship. When evidence refutes a hypothesis, revert what it motivated. The smallest change the evidence justifies ships, nothing more.

## Steps

1. **Reproduce it yourself on the real surface**, even when a report says "I already reproduced it." Ask the user only with a stated, specific reason the surface cannot reach the target, and only after driving it as far as it goes. If it won't reproduce directly, synthesize the trigger, tighten conditions, or instrument until it fires.
2. **Binary-search the cause.** Form the candidate hypotheses, then rule them out until one survives. Each pass, take the split that cuts the most remaining problem space, get runtime evidence, eliminate. When program state is unclear, add instrumentation or logging and read it as the code runs. Don't guess. Drive a long or stubborn hunt with a cron-backed loop and a checkable exit predicate. Confirm the surviving *mechanism* with runtime evidence before planning the fix.
3. **Plan the fix.** If it crosses a function boundary, design it first (see pstack-arena for multi-direction exploration when the shape is uncertain). Implement at the configured bug-fix seat (`worker-model` @ medium, per your model configuration) with a specific scope.
4. **Verify on the same surface.** The original repro now passes. "Inconclusive" or wrong-surface is not a pass. Flag it. Unit tests show branch behavior, not bug absence.
5. **Stage the commits** so the failing repro lands before the fix in git history — failing test first, fix on top. Skip the failing-test-first cadence when the test would be expensive, integration-heavy, or unclear.
6. **Open a draft PR.** the user merges. Never merge your own PR.

**Reply:** what was broken, root cause, fix, how you verified. Paste failing-then-passing repro output verbatim.

## Bugbot triage (for review-automation comments)

When handling Bugbot or review-automation comments on a PR, classify each thread before acting. The goal is not to ignore Bugbot by default — it is to stop treating every comment as a required code change.

- **fix**: The comment identifies a plausible correctness, security, privacy, data loss, auth, billing, migration, idempotency, race, or shipped-behavior issue. Fix it in the lowest owning PR, then reply with the commit SHA and resolve the thread.
- **dismiss**: The comment matches a documented low-risk noisy pattern, and the current code/context proves the concern does not need a code change. Reply with a short reason and resolve the thread.
- **ask**: The comment is novel, high-severity, security/privacy/data-related, or ambiguous. Ask the user instead of guessing.

When in doubt, ask. Skipping a noisy code-quality comment is cheap; skipping a real data or security bug is not.

**Never auto-dismiss:** security, privacy, auth, billing, data retention, permission-boundary findings; high-severity findings; migration, schema, idempotency, concurrency, and cross-system behavior findings; comments where the suggested fix is small and clearly reduces risk without changing product intent.

**Learned skip patterns** (promote from candidate → recurring → strong with evidence):

- *Intentional UI/design-system visual changes* — skip when the PR makes the visual change explicit and the comment only restates a shared default changed. Do not skip for accessibility, focus, keyboard, contrast, or component API contract concerns.
- *Upstack usage Bugbot cannot see* — skip when a later PR in the stack uses the flagged export/component. Do not skip for public API or unverifiable upstack claims.
- *Temporary duplication during parallel implementation* — skip when the duplicate keeps a new path parallel to an old path being deleted. Do not skip when it touches security, billing, data access, or API behavior.
- *Framework invariant already covers the warning* — skip when a shared component or type invariant visibly guarantees the concern. Do not skip when the invariant is assumed-but-unenforced or crosses async boundaries.
- *Owner-declared follow-up* — skip when the owner explicitly defers and the PR doesn't make things worse. Do not skip for medium/high severity product behavior.
- *Self-withdrawn comments* — skip when the comment body says the finding is withdrawn or a false positive and you can verify the rule locally.
