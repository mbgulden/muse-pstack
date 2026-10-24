---
name: muse-interrogate
description: "Spawn independent reviewers to adversarially challenge code changes from different angles, then synthesize a verdict. Use for adversarial review, multi-model review, challenging a diff, or finding blind spots. Never auto-applies."
upstream: pstack/skills/interrogate/SKILL.md + references/reviewer-prompt.md + references/rubric.md + references/lead-judgment.md + references/code-quality-review.md
upstream_sha: 99743e9c151c8537cbbf1f98bb38f34ef3368453
port_notes: "Adapted from upstream. The 4 reference files are embedded inline so the skill is self-contained. Cursor Task tool replaced with subagent.spawn; model slugs (claude-opus-5-5, grok-4.7) replaced with pstack-models.md interrogate-reviewer seats (muse + a worker model @ high). The .mdc rule reference retargeted to docs/models.md. Slash-trigger references removed. Reasoning-effort varies per seat instead of per-call model slugs."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Upstream SHA and port notes are in the frontmatter above. Cursor-specific
> mechanics (Task tool, slash triggers, .mdc rules) were replaced with
> platform-generic equivalents. "Jimmy" references rebranded to "Muse" for
> the Muse.ai platform. See [UPSTREAM.md](../../UPSTREAM.md) for the full
> port manifest.


# Interrogate

Spawn independent reviewers to adversarially review code changes. The adversarial signal comes from reviewer independence, not assigned personas. The deliverable is a synthesized verdict. Do NOT auto-apply changes.

**Fleet note (Oct 23, 2026):** on the local worker profiles, an interrogate pass is FIRST-PASS only. Its synthesized verdict does not land until Muse second-witnesses it in the kanban review step — Muse verifies the claims mechanically (files, counts, test runs) before the verdict is posted or acted on. This mirrors the standing reviewer pattern: the worker synthesizes, Muse witnesses.

## Step 1, Scope

Identify what to review from context:

- If the user points at specific files or a diff, use that.
- If on a feature branch, run `git diff main...HEAD` (or the appropriate base branch) for the full changeset.
- If the user's message references recent work, gather the relevant files.

Package the diff or file contents with any surrounding context files the reviewers need to understand the code.

## Step 2, Intent

Before spawning reviewers, state the intent in one clear paragraph from the user's message, commit messages, the PR description if one exists, and the code. If you're unsure about the intent, ask the user before proceeding — one plain-text question, never a stacked list.

## Step 3, Spawn Reviewers

Launch both reviewers in a single message with `subagent.spawn`, labeled Reviewer 1 and Reviewer 2, per the `interrogate reviewers` panel in `docs/models.md`:

| Reviewer | Seat |
|----------|------|
| Reviewer 1 | `muse` — frontier reviewer (this agent's own seat, spawned as a fresh read-only subagent) |
| Reviewer 2 | `worker-model` @ high — independent local reviewer |

Prefix each brief: "read muse-mode principles before work; never substitute a generic brief." Both reviewers are read-only. Build each reviewer's prompt from the template below, filling in the stated intent, the diff or file contents, the rubric, and the code-quality lens.

If a seat is unavailable, run that reviewer on the closest available seat and say so. Never block the review on a seat issue.

## Step 4, Synthesize

As results come back, build a unified picture. Parse every reviewer's findings. Merge findings that describe the same issue differently, and note which reviewer raised each one. Findings both reviewers raised independently are the highest signal. Read a lone reviewer's finding, but weight it accordingly. Note disagreements. If one reviewer flags something and the other explicitly says the opposite, that is context for the verdict.

## Step 5, Lead Judgment

You are the lead reviewer, a pragmatic senior engineer, not a neutral aggregator. Apply the filtering principles below. Put every finding in one of four buckets, with the reviewer(s) that raised it and a one-line rationale.

- **Act on**. Real issues affecting correctness, security, or maintainability given the actual goals. They would block a real PR.
- **Consider**. Legitimate, but you're not sure they outweigh the cost of addressing them now. Worth the user's attention.
- **Noted**. Technically valid but not actionable. Context-dependent, premature optimization, or low-impact at this stage.
- **Dismissed**. Wrong, nitpicky, or missing context, with a brief reason.

## Output Format

### Intent
> [The stated intent paragraph from Step 2]

### Reviewers
- Reviewer [label]: [seat], [N findings] (one bullet per reviewer)

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

---

## Reviewer prompt template

Build each reviewer subagent's prompt from this template, filling in the placeholders.

---

You are an adversarial code reviewer. Find real problems in the code below: bugs, design flaws, security issues, and maintainability concerns. You are not here to be helpful or encouraging. You are here to stress-test.

## Intent

The author's stated intent for this change:

> {INTENT}

Review whether the code achieves this intent well. Do NOT question the intent itself. Assume the goal is correct and challenge the execution.

## Code Under Review

{DIFF_OR_FILES}

## Review Rubric

{RUBRIC_CONTENTS}

## Code Quality Lens

{CODE_QUALITY_CONTENTS}

## Instructions

Review the code through every lens in the rubric and the code-quality lens above that you find relevant. Do not force lenses that don't apply. A simple bug fix does not need paragraphs about architectural integrity.

For each finding, provide:

1. **Severity**: `critical` | `warning` | `nit`
   - `critical`: Would cause bugs, data loss, security issues, or fundamentally broken behavior
   - `warning`: Design concern, maintainability risk, or correctness issue that isn't immediately broken but will cause pain
   - `nit`: Style, naming, minor improvement.
2. **Finding**: What the problem is, in concrete terms. Reference specific lines/functions.
3. **Evidence**: Why you believe this is a problem. Show your reasoning. Don't just assert.
4. **Suggestion** (optional): What you'd do instead, only if you have a concrete alternative.

A good finding references specific code, not vague concerns ("this could be better"). It distinguishes between "this is broken" and "I would have done this differently". It considers the stated intent. A finding that ignores the context of what's being built is a bad finding.

Do not restate what the code does without identifying a problem. Do not praise the code. If you find nothing wrong, say "no findings" and stop. An empty review is a valid outcome.

## Output

Return your findings as a structured list:

```
## Findings

### 1. [Severity] Short title
**Location**: file:line or function name
**Finding**: What's wrong
**Evidence**: Why this matters
**Suggestion**: (optional) What to do instead

### 2. [Severity] Short title
...
```

---

## Review rubric

Review through whichever lenses are relevant. Not every lens applies to every change.

### Correctness

Does the code actually do what the intent says it should?

- Edge cases: empty inputs, nil/undefined, boundary values, concurrent access
- Error handling: are errors caught, propagated, or silently swallowed?
- Off-by-one, type coercion, integer overflow, string encoding
- State management: race conditions, stale closures, dangling references
- Do both the happy path and the sad path work?
- Idempotency: what happens if this operation runs twice, or if a previous run crashed halfway? If the answer is "it depends on what state was left behind," a reconciliation step is missing.
- Concurrency: if multiple actors can touch the same mutable state (files, branches, shared data), is access serialized structurally (locks, sequential phases, exclusive ownership), or by conventions that won't hold?

When you find a potential bug, trace the execution path. Don't just flag "this could be nil". Show the call chain that makes it nil.

### Root Causes vs. Symptoms

Is the code fixing the actual problem or papering over a symptom?

Answering this often requires looking beyond the changed files. Read the surrounding code (callers, callees, type definitions, sibling modules) and understand the architecture the change lives in before judging whether the change addresses the right layer.

- Guard clauses that mask a deeper invariant violation
- Retry logic that hides a broken contract
- Type casts that silence a modeling error
- A workaround: why is it needed? What would a proper fix look like?
- A fix in module A that should really be a fix in module B's contract
- Instructions where structure would be better: if the fix is a comment saying "don't do X" or a convention someone has to remember, ask whether it could instead be a type constraint, a lint rule, or a runtime check that makes the wrong thing impossible

### Structural Integrity

Does the code fit well into the system it's part of?

- Boundary discipline: is validation at system boundaries, or scattered through business logic? Validate data once where it enters the system, then trust it internally.
- Abstraction level: is the code mixing high-level orchestration with low-level detail?
- Coupling: does this change introduce dependencies that will make future changes harder?
- Data model fit: do the data structures match the actual access patterns?
- Bolted-on vs. integrated: if the new requirement had been known from the start, would the code look like this, or does the change feel patched onto the existing design?
- Legacy dual-paths: does the change introduce a new API while keeping the old one alive? If there are no external consumers, migrate callers and delete the old path in the same wave. Don't leave compatibility layers that will become permanent.

Don't penalize simple code for lacking abstraction. Premature abstraction is worse than duplication.

### Verification

Can you tell that this code works from reading it?

- Are there tests? Do they test behavior or implementation details?
- Are there assertions/invariants that would catch regressions?
- If this is a bug fix: is there a test for the bug?
- If this touches an integration boundary: is the full path tested?
- Check the real thing, not a proxy. If the code checks liveness via file mtime or cached state instead of reading the actual value, that's a verification gap.
- For delegated or async work: does the code verify actual output artifacts, or does it trust self-reports and summaries?

### Complexity Budget

Is the complexity justified by what the code accomplishes?

- Code that could be simpler without losing correctness or clarity
- Abstractions that serve only one call site
- Configuration or parameterization for cases that don't exist yet
- Dead code, unused imports, vestigial parameters
- Over-engineering: "just in case" code paths with no current callers
- Obsolete compatibility paths kept alive for transitional stability that's no longer needed. If the migration is done, delete the scaffolding
- Does the user experience justify the complexity? Every feature, control, and option should earn its place. Half-finished features are worse than missing ones.

Simpler is better unless simpler is wrong.

### Security

For each security finding, trace the input path through the code and show it.

- User input flowing to dangerous sinks (SQL, shell, eval, innerHTML) without sanitization
- Authentication/authorization gaps in new endpoints
- Secrets in code, logs, or error messages
- TOCTOU (time-of-check-time-of-use) in security-critical paths

---

## Code-quality lens

Each reviewer applies this lens in addition to the rubric. It is a strict standard focused on implementation quality, maintainability, abstraction quality, and codebase health.

Above all, be ambitious about code structure. Do not merely identify local cleanup. Actively search for "code judo" moves, restructurings that preserve behavior while making the implementation dramatically simpler, smaller, more direct, and more elegant.

Start from this baseline:

> Perform a deep code quality audit of the current branch's changes.
> Rethink how to structure / implement the changes to meaningfully improve code quality without impacting behavior.
> Work to improve abstractions, modularity, reduce spaghetti code, improve succinctness and legibility.
> Be ambitious, if there is a clear path to improving the implementation that involves restructuring some of the codebase, go for it.
> Be extremely thorough and rigorous. Measure twice, cut once.

Dimensions (apply the ones that are relevant):

0. **Be ambitious about structural simplification.** Do not stop at "this could be a bit cleaner." Look for reframings that make whole branches, helpers, modes, conditionals, or layers disappear. Assume a "code judo" move is often available. If you can delete complexity rather than rearrange it, push hard for that.
1. **Do not let a PR push a file from under 1k lines to over 1k lines without a very strong reason.** Treat this as a strong smell. Prefer extracting helpers, subcomponents, or modules. Waive only for a compelling structural reason where the resulting file stays clearly organized.
2. **Do not allow spaghetti growth in existing code.** Be suspicious of new ad-hoc conditionals, scattered special cases, or one-off branches inserted into unrelated flows. Prefer pushing the logic into a dedicated helper, state machine, or module instead of tangling an existing path.
3. **Bias toward cleaning the design, not just accepting working code.** If behavior can stay the same while the structure becomes meaningfully cleaner, push for the cleaner version.
4. **Prefer direct, boring, maintainable code over hacky or magical code.** Treat brittle, ad-hoc, or "magic" behavior as a problem. Flag thin abstractions, identity wrappers, or pass-through helpers that add indirection without buying clarity.
5. **Push on type and boundary cleanliness when it affects maintainability.** Question unnecessary optionality or cast-heavy code when a clearer type boundary could exist.
6. **Keep logic in the canonical layer and reuse existing helpers.** Call out feature logic leaking into shared paths. Prefer existing canonical utilities over bespoke one-offs.
7. **Treat unnecessary sequential orchestration and non-atomic updates as design smells when the cleaner structure is obvious.** If independent work is serialized for no reason, ask whether it should run in parallel. If related updates can leave state half-applied, push for a more atomic structure.

Prioritize structural code-quality regressions and missed simplifications first, then spaghetti and branching complexity, then boundary, type, and file-size concerns, then smaller modularity and legibility issues.

**Approval bar:** do not approve merely because behavior seems correct. Treat these as presumptive blockers unless the author can justify them: the PR keeps a lot of incidental complexity when a code-judo move would delete it; pushes a file from below 1000 lines to above 1000 lines; adds ad-hoc branching that tangles an existing flow; scatters feature checks across shared code; adds an unnecessary abstraction, wrapper, or cast-heavy contract, or duplicates an existing helper or puts logic in the wrong layer when there is a clear canonical home.

Be direct, serious, and demanding about quality. Do not be rude, but do not soften major maintainability issues into mild suggestions.

---

## Lead judgment: filtering principles

### Nitpick Gravity

Reviewers, especially adversarial ones, tend to fill their review. If they don't find critical issues, they'll inflate nits to fill the space. If a reviewer's findings are all nits and style preferences, the code is probably fine. Say so.

### Hypothetical vs. Actual

"What if someone passes null here?" is only a finding if the caller can actually pass null. Trace the call site. If the input is validated upstream or the type system prevents it, dismiss the finding. Reviewers working from a diff can't always see the full call chain. You can.

### Premature Abstraction Warnings

Reviewers often suggest extracting functions, adding interfaces, or creating abstractions. Does this code need to change in a second way? If not, the abstraction is premature. Simple inline code that works beats a clean abstraction that's overkill for the current scope.

### "I Would Have Done It Differently"

This is the most common false positive in code review. A finding that amounts to "I prefer a different approach" is not a bug, not a design flaw, and not actionable unless the reviewer shows a concrete problem with the current approach. Dismiss these, and say why.

### Missing Context Signals

Watch for findings that reveal the reviewer didn't understand the context:
- Suggesting changes to code the author didn't write or modify
- Flagging patterns that are consistent with the rest of the codebase (the reviewer just doesn't know that)
- Recommending approaches that conflict with constraints you know about

These are honest mistakes from reviewers working with limited information. Dismiss them gracefully.

### When Reviewers Are Right

Don't dismiss findings just because they're uncomfortable. The whole point of adversarial review is to catch things you'd miss. Signs a finding deserves attention:

- Both reviewers flag the same issue independently (consensus signal)
- The finding identifies a concrete execution path, not a hypothetical
- The finding reveals a gap in your mental model of the code
- You read the finding and think "...yeah, actually"

Be especially careful about dismissing security findings and correctness bugs. These deserve more scrutiny even when they come from a single reviewer.
