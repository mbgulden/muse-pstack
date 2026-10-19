# Engineering Principles — distilled from pstack
> **Provenance:** Distilled from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto), upstream SHA `99743e9c151c8537cbbf1f98bb38f34ef3368453`.
> These are the 24 upstream principles rewritten as enforceable engineering rules.
> See [UPSTREAM.md](../UPSTREAM.md) for the full port manifest.

**Source:** 24 principle files from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto), distilled into actionable rules.
**Method:** Each upstream principle was read in full, then rewritten as a concrete rule with a named enforcement mechanism.
**Result:** 21 principles below, plus 3 that were already covered by common practice (listed at the bottom).

---

## Debugging

**Attack the premise (new):** When two fixes built on the same assumption fail the same check, stop fixing and test the assumption itself. Write the one sentence every failed fix assumed, find one observation that would come out different if it were false, and check that before writing a third fix.
*Enforcement:* the "3 routes before reporting" rule gets a stop condition — the third route is always "test the premise," and no further fix starts until the premise is written down and checked.

**Fix root causes (new):** Fix where the system first went wrong, not where the symptom showed. A guard, retry, or swallowed error counts as a fix only when the state it handles is legitimate — otherwise it's hiding the bug. If a workaround needs a paragraph to justify, the code is wrong.
*Enforcement:* bug-fix plans name the root-cause location and answer "why isn't this a guard?" before approval.

## Design

**Data structures first (new):** Get the shape of the data right before writing logic. Three similar statements beat a premature abstraction. Scaffold (CI, lint, shared types) goes before features, because everything after benefits.
*Enforcement:* plan template asks "are the core data shapes settled?" before logic gets written.

**Model the domain (new):** Put the real-world shape into a structure — state machine, lookup table, typed model — instead of scattering it across conditionals. The tell you skipped it: a new feature adds one more branch to an if/else chain.
*Enforcement:* design review flags branch-chain growth; new booleans that must stay in sync get challenged.

**Redesign, don't bolt on (new):** When a new requirement hits an existing design, ask what you'd build if it had been there from day one — then build that, instead of gluing it onto the side.
*Enforcement:* plan template asks the from-scratch question for any change touching existing design.

**Prototype novel calls (new):** When there's no precedent and feel matters more than logic, build 2–3 competing sketches and compare side by side before committing. Throwaway beats wrong.
*Enforcement:* novel UI/architecture decisions list the prototypes compared, or say why none was needed.

## Code shaping

**Subtract before you add (new):** Delete the dead code, redundant validators, and stub references first, then build on what's left. Cut before you polish. Leave the design slightly simpler than you found it.
*Enforcement:* plans carry a "what gets deleted" line; empty means you haven't looked.

**Smallest diff that solves it (new):** Bias toward deletion. One source of truth per decision, passed around as a simple value — not the same choice repeated in five places.
*Enforcement:* review asks "could this be smaller?" — bigger needs a reason.

**Reader load is the metric (new):** Count the layers between a question and its answer, and the hidden state a reader must hold in their head. Collapse one-caller wrappers, shrink mutable scope, prefer pure functions. The test: can someone new answer "where does X come from?" in 30 seconds?
*Enforcement:* code review checklist; interrogate-skill rubric.

**Boundaries do the guarding (new):** Validate at the edges — CLI args, config, network, external APIs — and trust the types inside. Business logic lives in pure functions the shell just calls, testable without the framework.
*Enforcement:* review flags validation deep in call chains; new code parses at the boundary.

**Types that make bad states impossible (new):** Brand your primitives (a UserId isn't a bare string), parse untyped input once at the boundary, derive types from the schema that owns the shape instead of hand-copying it.
*Enforcement:* review checklist for typed code.

**Migrate callers, delete the old API, same wave (new):** No compatibility layers that live forever. If nothing outside depends on the old shape, move every caller and delete it in one go — tests included.
*Enforcement:* refactor PRs show the old API deleted, not deprecated.

## Verification & measurement

**Tests assert behavior (new):** A test should fail when the behavior breaks and survive a refactor. Two checks before keeping one: break the behavior on purpose — does the test catch it? Restructure the internals — does it still pass? Rewrite or delete the rest. Expected values come from the requirement, never from a run of the code.
*Enforcement:* test review runs the two imagined edits.

**Explain the number (new):** Before reporting a measurement — speedup, latency, benchmark — name what limits it, from a profile or counters, not a guess. Rule out what else the number could be measuring: errors, cached or skipped work, noise, an untuned side. A number ships with its run count, spread, and limiter, or it doesn't ship.
*Enforcement:* benchmark reports carry limiter + runs + spread; missing any one means it's not a result.

## Operations

**Safe to re-run (new):** Every state-mutating script or job answers three questions: what if this runs twice? What if it crashed halfway last time? Does re-running converge on the same end state? Derive each step from current state vs goal — not from what the last run meant to do. Anything left behind (locks, temp files, claimed jobs) must be recognizable as stale by the next run.
*Enforcement:* scripts and crons carry the three answers in a header comment. The Fred DB repair script is the reference example.

**Separate first, serialize only if you must (new):** When parallel workers share mutable state, give each its own owned file, key, or branch and merge at the read boundary. "We'll be careful" is not concurrency control. Locks are a last resort, not the default.
*Enforcement:* new shared-state files are per-writer or structurally serialized; the existing shared ones (audit signals, seen-lists, night logs) get audited for races.

## Process

**Outcome over smooth intermediates (new):** On a planned rewrite or migration, converge on the target — don't build throwaway compatibility scaffolding to keep every intermediate step pretty. Declare up front where temporary breakage is acceptable, keep checks on the areas being touched, verify fully at the end.
*Enforcement:* migration plans name their breakage boundaries. (Red-merge rule untouched: nothing lands on main red.)

**Sequence verifiable units (new):** Break multi-step work into small units that each end in a checkable state; don't start the next until the current is green. Stack commits so the sequence argues for itself — failing test first, then the fix.
*Enforcement:* multi-step work opens a todo list with a verify step per unit; PR stacks follow story order.

**Ship less, ship better (new):** When implementation convenience and the user's experience conflict, the user wins. Every feature and option must be justified; three polished beats ten rough.
*Enforcement:* feature proposals name the user and the delight in one line each, or the scope gets cut.

## Meta

**Build the lever (new):** For non-trivial work, build the tool — script, codemod, generator, delegate skill — instead of doing it by hand. The tool is the artifact a reviewer reruns; "trust me" becomes "run this." First unit by hand to learn the recipe is fine; the second unit builds the tool. If you claim this principle and there's no script in the diff, you didn't apply it.
*Enforcement:* PR checklist: "rerunnable artifact included, or triviality justified."

**Structure over prose (new):** When a lesson can be enforced by a lint rule, test, or script, build that — don't add another paragraph to the instructions. Text is the fallback for judgment calls, not the default.
*Enforcement:* every proposed standing-rule addition first answers "can this be enforced structurally?" and records the answer.

---

## Already covered — no change proposed

- **prove-it-works** → "Verify before claiming" — never report success without mechanical evidence
- **never-block-on-the-human** → "Decide more, ask less" — act on authorized work without re-asking
- **guard-the-context-window** → subagent delegation discipline: summaries to parent, bulk to children
