---
name: muse-bug-fix
description: "Reproduce a bug on the real surface, binary-search the cause with runtime evidence, fix the smallest change the evidence justifies, and verify. Use when something is broken."
upstream: pstack/skills/poteto-mode/playbooks/bug-fix.md + pstack/skills/poteto-mode/references/bugbot-triage.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream. Cursor /loop replaced with cron+heartbeat+subagent-wake for long hunts. Task-tool model slugs replaced with subagent.spawn and pstack-models.md seats (bug-fix → a worker model @ medium). gh CLI replaced with GitHub REST API. Slash-trigger references removed; skill file is read at task start. bugbot-triage reference folded in as the automated-review-comments section (it was written for the Babysit playbook, which is DEFERRED — kept here because bug-fix PRs are where those comments land)."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Upstream SHA and port notes are in the frontmatter above. Cursor-specific
> mechanics (Task tool, slash triggers, .mdc rules) were replaced with
> platform-generic equivalents. "Jimmy" references rebranded to "Muse" for
> the Muse.ai platform. See [UPSTREAM.md](../../UPSTREAM.md) for the full
> port manifest.


# Bug fix

**You own this task. Plan, review, verify.** Delegate investigation and the fix to subagents, stay in the lead. Before delegating, prefix the brief: "read muse-mode principles before work; never substitute a generic brief."

Be scientific. Every shipped line traces to runtime evidence. Belt-and-suspenders that "might help" is a hypothesis, not a fix. It does not ship. When evidence refutes a hypothesis, revert what it motivated. The smallest change the evidence justifies ships, nothing more.

1. Reproduce it yourself on the matching surface, even when a debug or instrumentation protocol says to ask the user to reproduce. Ask the user only with a stated, specific reason the control surface cannot reach the target, and only after driving it as far as it goes. If it won't reproduce directly, synthesize the trigger, tighten conditions, or instrument until it fires.
2. Binary-search the cause. Form the candidate hypotheses, then rule them out until one survives. Ground them in the affected subsystem and in regression history (`~/workspace/audit/signals.jsonl`, Hermes journals, `~/memory/`). Each pass, take the split that cuts the most remaining problem space, get runtime evidence, eliminate. When program state is unclear, add instrumentation or logging and read it as the code runs. Don't guess. Drive a long or stubborn hunt with crons + heartbeat + subagent wake. Confirm the surviving *mechanism* with runtime evidence before the step-3 fan-out.
3. Plan the fix. If it crosses a function boundary, design it first (see the architect thinking: state the contract change before writing code). Delegate implementation to a subagent on the `bug-fix` seat from `docs/models.md` (`worker-model` @ medium) with a specific scope.
4. Verify on the same surface. The original repro now passes. "Inconclusive" or wrong-surface is not a pass. Flag it. Unit tests show branch behavior, not bug absence.
5. Stage the commits so the failing repro lands before the fix in git history. Failing-test-first cadence when the bug has a cheap local test path. Skip it when the test would be expensive, integration-heavy, or unclear.
6. Open a PR (draft; you merge). Use the GitHub REST API per repo convention — the git CLI does not authenticate with the available credential.

**Reply:** what was broken, root cause, fix, how you verified. Paste failing-then-passing repro output verbatim.

## Automated review comments (Bugbot triage)

When the fix PR collects automated review comments, classify each thread before acting. The goal is not to ignore them by default. The goal is to stop treating every comment as a required code change.

- **fix**: The comment identifies a plausible correctness, security, privacy, data loss, auth, billing, migration, idempotency, race, or shipped-behavior issue. Fix it in the lowest owning PR, then reply with the commit SHA and resolve the thread.
- **dismiss**: The comment matches a documented low-risk noisy pattern, and the current code/context proves the concern does not need a code change. Reply with a short reason and resolve the thread.
- **ask**: The comment is novel, high-severity, security/privacy/data-related, or ambiguous. Ask the user instead of guessing.

When in doubt, ask. Skipping a noisy code-quality comment is cheap; skipping a real data or security bug is not.

### Recurring skip candidates

**Intentional UI or design-system visual changes** (confidence: candidate)
- Skip when: the PR description, screenshots, design review, or nearby code makes the visual change explicit, and the comment is only restating that a shared visual default changed.
- Do not skip when: the comment points to accessibility, focus visibility, keyboard navigation, color contrast, or a component API contract the PR did not intentionally change.

**Upstack or stack-local usage the reviewer cannot see** (confidence: candidate)
- Skip when: the comment flags an export, component, helper, or file as unused, and the PR list and diffs show it is used by a later PR in the stack.
- Do not skip when: the current PR is not part of a stack, the symbol is public API, or the supposed upstack use cannot be verified.

**Temporary duplication during parallel implementation** (confidence: candidate)
- Skip when: the PR intentionally duplicates a small amount of code to keep a new path parallel to an old path being deleted, replaced, or proven out.
- Do not skip when: the duplicated code changes security, billing, data access, API behavior, or a long-lived shared abstraction would clearly reduce risk.

**Existing framework or component invariant covers the warning** (confidence: candidate)
- Skip when: the concern is already guaranteed by a shared component, framework contract, type invariant, or single source of truth visible in the current diff or nearby code.
- Do not skip when: the invariant is assumed but not enforced, depends on timing, or crosses async/state boundaries where values can diverge.

**Owner-declared follow-up or deferred cleanup** (confidence: candidate)
- Skip when: the PR owner explicitly says the issue is a known follow-up, the behavior is not made worse by the current PR, and the comment is not about a high-risk area.
- Do not skip when: acting without owner input, the issue is medium/high severity product behavior, or deferring would merge a new regression.

**Self-withdrawn or explicit false-positive rule comments** (confidence: recurring)
- Skip when: the comment body or a later reply explicitly says the finding is withdrawn, compliant, or a false positive, and the relevant rule can be verified locally.
- Do not skip when: the only evidence is a human saying "false positive" on a high-risk issue without explanation.

### Ask by default

Do not auto-skip these categories, even if a previous PR dismissed something similar:
- Security, privacy, auth, billing, data retention, and permission-boundary findings.
- High-severity findings.
- Migration, schema, idempotency, concurrency, and cross-system behavior findings.
- Comments where the suggested fix is small and clearly reduces risk without changing product intent.

### Learned pattern format

Add future patterns in this shape:

```markdown
### <short pattern name>

- Confidence: candidate | recurring | strong
- Skip when: <conditions that must be true>
- Do not skip when: <risk boundaries>
- Example signal: <phrases or code context that identify the pattern>
- Source: <PR/comment URL or short historical note>
```

Use `candidate` for one or two examples. Use `recurring` after multiple real dismissals. Use `strong` only when the pattern is narrow, repeatedly verified, and low-risk.
