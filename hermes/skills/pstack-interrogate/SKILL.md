---
name: pstack-interrogate
description: "Adversarial multi-reviewer code review: independent reviewers challenge changes from different angles using a shared rubric, the lead synthesizes into Act on / Consider / Noted / Dismissed. Use for 'interrogate', 'tear this apart', 'find blind spots', or any diff that needs adversarial review. Never auto-applies changes."
upstream: pstack/skills/interrogate/SKILL.md + references/reviewer-prompt.md + references/rubric.md + references/lead-judgment.md + references/code-quality-review.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream interrogate skill + 4 references. Cursor Task-tool/subagent_type mechanics replaced with Hermes orchestration. Model table (claude-opus/grok) replaced with your model configuration interrogate reviewer panel: Reviewer 1 = the orchestrator (frontier), Reviewer 2 = worker-model @ high. the model configuration path replaced with your model configuration. Rubric, reviewer prompt, lead-judgment framework, and code-quality lens folded in as sections (condensed where upstream was verbose)."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Adapted for Hermes agent profiles. See [UPSTREAM.md](../../UPSTREAM.md).


# Interrogate

Two independent reviewers adversarially review code changes. The adversarial signal comes from reviewer diversity, not assigned personas. The deliverable is a synthesized verdict. **Do NOT auto-apply changes.**

## Step 1 — Scope

Identify what to review:
- If the user points at specific files or a diff, use that.
- If on a feature branch, run `git diff main...HEAD` (or the appropriate base) for the full changeset.
- If the message references recent work, gather the relevant files.

Package the diff or file contents with any surrounding context the reviewers need.

## Step 2 — Intent

State the intent in one clear paragraph from the user's message, commit messages, the PR description, and the code. If unsure about the intent, ask the user before proceeding.

## Step 3 — Spawn reviewers

Launch both reviewers in parallel via Hermes orchestration, labeled Reviewer 1 and Reviewer 2:

| Reviewer | Seat (per your model configuration) |
|---|---|
| Reviewer 1 | `frontier-reviewer` — frontier reviewer |
| Reviewer 2 | `worker-model` @ high — independent local reviewer |

Each reviewer is read-only. Build each reviewer's brief from the template below, filling in the stated intent, the diff or file contents, the rubric, and the code-quality lens.

## Step 4 — Synthesize

As results come back, build a unified picture. Merge findings that describe the same issue differently; note which reviewers raised each one. **Findings both reviewers raised independently are the highest signal.** Note disagreements — if one flags something and the other explicitly says the opposite, that's context for the verdict.

## Step 5 — Lead judgment

You are the lead reviewer: a pragmatic senior engineer, not a neutral aggregator. Put every finding in one bucket, with the reviewer(s) that raised it and a one-line rationale:

- **Act on.** Real issues affecting correctness, security, or maintainability given the actual goals. Would block a real PR.
- **Consider.** Legitimate, but you're not sure they outweigh the cost of addressing now. Worth the user's attention.
- **Noted.** Technically valid but not actionable. Context-dependent, premature optimization, or low-impact.
- **Dismissed.** Wrong, nitpicky, or missing context, with a brief reason.

**Filtering principles:**
- *Nitpick gravity:* if a reviewer's findings are all nits and style preferences, the code is probably fine. Say so.
- *Hypothetical vs. actual:* "what if someone passes null?" is only a finding if the caller can actually pass null. Trace the call site.
- *Premature abstraction:* does this code need to change in a second way? If not, the suggested abstraction is premature.
- *"I would have done it differently"* is the most common false positive. Not a bug, not actionable, unless the reviewer shows a concrete problem.
- *Missing context:* watch for findings that reveal the reviewer didn't understand the codebase (flagging unmodified code, patterns consistent with the repo, approaches conflicting with known constraints). Dismiss gracefully.
- *When reviewers are right:* don't dismiss uncomfortable findings. Consensus across both reviewers, concrete execution paths, and findings that reveal a gap in your mental model deserve attention. Be especially careful dismissing security and correctness findings.

## Output format

### Intent
> [The stated intent paragraph]

### Reviewers
- Reviewer 1 (the orchestrator): [N findings]
- Reviewer 2 (worker-model): [N findings]

### Act On
[Each: description, which reviewers raised it, why it matters.]

### Consider
[Each: description, which reviewers raised it, the tradeoff.]

### Noted
[Brief list.]

### Dismissed
[Each with a brief rationale.]

### Agreement Map
[Where reviewers agreed and diverged, and what that pattern tells us.]

## Reviewer brief template

> You are an adversarial code reviewer. Find real problems: bugs, design flaws, security issues, maintainability concerns. You are here to stress-test, not to encourage.
>
> **Intent:** {INTENT — the author's stated goal. Review whether the code achieves it well. Do NOT question the intent itself.}
>
> **Code under review:** {DIFF_OR_FILES}
>
> **Rubric:** {RUBRIC below — apply the lenses that are relevant, don't force ones that don't fit}
>
> **Code-quality lens:** {LENS below}
>
> For each finding: **Severity** (critical / warning / nit), **Finding** (concrete, with file:line), **Evidence** (why it matters — trace the path, don't just assert), **Suggestion** (optional, only with a concrete alternative). Do not restate what the code does without identifying a problem. Do not praise. "No findings" is a valid outcome.

## Rubric

**Correctness:** Does the code do what the intent says? Edge cases, error handling (caught/propagated/swallowed?), off-by-one, type coercion, overflow, encoding. State management: races, stale closures, dangling references. Happy path AND sad path. Idempotency: what if it runs twice or crashed halfway? Concurrency: is shared mutable state serialized structurally or by convention?

**Root causes vs. symptoms:** Is this fixing the real problem? Guard clauses masking invariant violations, retries hiding broken contracts, casts silencing modeling errors, workarounds (what would a proper fix look like?), fixes in module A that belong in module B's contract. Prefer structure over instructions: a comment saying "don't do X" should be a type, lint rule, or runtime check instead.

**Structural integrity:** Boundary discipline (validate once at entry, trust internally). Abstraction level mixing. Coupling. Data model fit. Bolted-on vs. integrated. Legacy dual-paths: no external consumers → migrate callers and delete the old path in the same wave.

**Verification:** Are there tests? Do they test behavior or implementation? Assertions/invariants for regressions? Bug fix → test for the bug? Integration boundary → full path tested? Check the real thing, not a proxy. Delegated/async work → verify actual artifacts, not self-reports.

**Complexity budget:** Could it be simpler? Single-callsite abstractions, speculative configuration, dead code, "just in case" paths, finished-migration scaffolding. Simpler is better unless simpler is wrong.

**Security:** Trace each finding's input path. Injection sinks without sanitization, auth gaps in new endpoints, secrets in code/logs/errors, TOCTOU in security-critical paths.

## Code-quality lens

Be ambitious about structural simplification — look for "code judo" moves that delete complexity, not just rearrange it. Don't let a PR push a file from under 1k lines to over 1k without a strong reason. Treat ad-hoc conditionals scattered into unrelated flows as a design problem. Prefer direct, boring, maintainable code over magic. Push type and boundary cleanliness when it affects maintainability. Keep logic in the canonical layer; reuse existing helpers. Treat unnecessary sequential orchestration and non-atomic updates as design smells when the cleaner structure is obvious. Don't approve merely because behavior seems correct — presumptive blockers: kept incidental complexity a code-judo move would delete, 1k-line threshold crossed, tangled ad-hoc branching, scattered feature checks, unnecessary abstractions or wrong-layer logic.
