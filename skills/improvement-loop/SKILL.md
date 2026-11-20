---
name: improvement-loop
description: "Run a fleet of agents as a measured improvement loop: register a hypothesis before any build, change one variable per system at a time, classify every failure by cause, distill a failed task instead of repeating it, keep every worker profile's queue stocked from a bench, and close each cycle with a weekly scorecard verdict. Use when operating a multi-agent fleet whose quality should compound week over week instead of improving only when an incident forces a fix."
---

# Improvement loop

A fleet improves in one of two ways: by incident, where each fix answers the
failure that just happened, or by loop, where a metric movement becomes a
registered hypothesis, a tested change, and a verdict on a cadence. This skill
is the loop. It has five working parts: a hypothesis register (the loop's
memory), a failure-cause taxonomy, a distill policy for failed tasks, a bench
that keeps queues stocked, and a weekly scorecard that judges every cycle.
A scheduled weekly driver runs the cadence; the operator keeps the decisions
the loop is not allowed to make (money, deletions, product gating, anything
irreversible).

The method is tool-agnostic. It assumes a task board with worker profiles,
a task checker that validates new tasks mechanically, a verification stack
that gates merges, and a scorecard computed from the board's own records.
Two companion files ship with this skill: `register-template.md` (the
register entry skeleton) and `bench-format.md` (the bench file contract).

## 1. The loop

Every cycle runs the same six steps, in order:

1. **Measure.** Read the current state from the weekly scorecard (§6):
   first-run value success, the failure-cause split, token accounting,
   estimate calibration.
2. **Register the hypothesis before any build.** The change is written
   into the register first (§2). A change with no register entry that
   predates it is not a loop cycle; it is an incident fix, and it does
   not get to claim a metric movement.
3. **Build.** One owner carries the change end-to-end: plan, build, test,
   merge. No relay handoffs mid-cycle.
4. **Test.** Tests are written with the change, and the set includes one
   adversarial case designed to break it — for a measurement change, the
   case that would make the metric lie; for a behavior change, the input
   the change most wants to ignore.
5. **Apply.** The change lands only when the full verification stack is
   green: automated checks, review verdicts where the setup runs them,
   and the evidence checklist on the change's record. A red stack means
   no merge, with no override lane inside the loop.
6. **Re-measure and record the verdict.** The hypothesis is judged over
   the next two weekly scorecard windows. The verdict — confirmed,
   refuted, or inconclusive — is appended to the register entry.

Register entries are never rewritten. Corrections, status changes, and
verdicts are appended lines, so the register stays a faithful history of
what was believed, what was tried, and what the numbers said.

## 2. Register the hypothesis before building

Every register entry names, before the build starts:

- **System** — the one system the change touches (an authoring rule, a
  recovery step, a checker gate, a profile's queue policy).
- **Isolation** — why the effect is isolated and readable: what the
  change does not touch, and what comparison the untouched parts provide.
- **Baseline window** — the measurement window the baseline figure comes
  from, with the figure itself.
- **Target window** — the windows the result will be read in (two weekly
  windows by default).
- **Primary metric and numeric target** — one metric, one number. A
  hypothesis with two primary metrics has none.
- **Guard metrics** — the metrics that must not worsen while the primary
  metric moves. A cycle that hits its target by breaking a guard is
  recorded as refuted, not confirmed.

Two discipline rules keep causation readable:

- **One variable per system at a time.** Two changes touching the same
  system run in sequence, never in the same window. Changes on different
  systems may run in parallel.
- **Systemic changes are allowed on isolated systems.** A change does not
  have to be small or safe-sized to enter the loop; it has to act on an
  isolated system and carry a hypothesis aimed at an overall goal, with
  causation identifiable from the data. A sweeping change to a shared
  system with no comparison left standing stays out until it can be
  staged onto an isolated part.

The entry skeleton, with every field and the verdict slot, is
`register-template.md`.

*Example (invented):* a hypothesis on the task-authoring system — build
tasks that name two deliverable files are split at authoring into one
task per file. Isolation: the rule applies to the builder profile only;
the researcher and writer profiles keep the current authoring and serve
as the comparison group in the same weeks. Primary metric: timed-out
hours share, baseline 22% over the last two windows, target under 15%.
Guards: weekly completions do not fall; the builder profile's share of
completed tasks does not fall.

## 3. Classify every failure by cause

Every failure is recorded with its cause from the first failure onward,
in one of five classes. The weekly reporting carries the split — counts
and share per class — so fixes get built against the class that is
failing, not against failure in general.

- **infrastructure** — the environment failed the task: a dead worker or
  an orphaned claim, an endpoint or tunnel outage, a host replacement, a
  dispatcher stall. The task itself was not wrong.
- **task shape** — the task's shape failed it: the run burned its cap
  with no deliverable movement, or recon and setup consumed the run
  before the work started.
- **task execution** — the work failed: a deliverable was produced but
  earned a FAIL verdict, the worker gave up mid-work, or a protocol
  violation ended the run.
- **external dependency** — the task is blocked on something outside the
  fleet: an outside reply, a credential, or a decision. Determine this
  class by reading the task's own block text first; keyword matching on
  the record is a fallback only, because keywords misfire on ordinary
  prose.
- **unclassified** — the record cannot support a class. Unclassified is
  shown as its own slice in every report, never redistributed into the
  other classes. A rising unclassified share is a recording problem to
  fix, not a rounding error to absorb.

Classification is mechanical wherever the record allows it: run outcome,
cap and error text, heartbeat and claim state, and the task's own block
text. A failure the evidence cannot place stays unclassified — the
classifier fails closed rather than guess.

## 4. Distill on task-caused failure

The response to a failure follows its cause class (§3):

- **Task-caused failure (task shape or task execution): the task is
  never repeated as-is.** The first failure triggers a distillation. The
  successor is a rewritten task — smaller scope, clarified body, the
  failure's lesson written into it, reassigned to a different profile
  where that fits — and the original is marked superseded. Every
  distillation is recorded: what failed, its cause class, and what
  changed in the successor.
- **Infrastructure carve-out: an infrastructure-caused failure is
  re-run as-is.** The task was not wrong, and distilling it would waste
  a good task and muddy the data — the retry measures the environment's
  recovery, not the task.
- **The strike ladder still bounds every lineage.** Distillation never
  extends a lineage past the existing 3-strike escalation to the
  operator: after the third strike, the lineage leaves the fleet's
  hands, distilled or not.

Distillation records feed the weekly driver (§7): the lessons that recur
are pushed back into the authoring skill and the task checker, so initial
task assignments improve, not only retries.

## 5. Keep the queues stocked

Each worker profile keeps a queue floor: by default, **at least 2 ready
tasks behind every running profile**, so a finished run is followed by
the next task without an idle gap.

Stock comes from bench files — pre-specced work items waiting to be
authored into tasks. The bench file contract is `bench-format.md`. The
stocking monitor reads the board and the benches and reports, per
profile, the queue depth against the floor and the next QUEUED bench
items when a profile sits below it. The monitor is read-only: authoring
tasks from the bench stays with the operator.

A profile sitting idle while QUEUED bench items remain is a stocking
failure, not a status to report. The stock is the operator's job to keep
current: when a program's bench runs dry, refilling it outranks starting
new work that has no queue behind it.

## 6. Measurement definitions

The scorecard computes four things from the board's records. The
definitions below are the contract; a scorecard that computes them
differently is a different scorecard and must say so.

### First-run value success

A task counts as a first-run value success when **its first run completes
AND the deliverable earns a reviewer-authored PASS verdict**. A completed
run with no value is not a success. A task whose first run fails and
whose retry succeeds is a recovery, and it counts in the run-success
figures — never in first-run value success.

Tasks carrying no verdict count in neither numerator nor denominator.
**Verdict coverage — the share of done tasks carrying a parseable
reviewer-authored verdict — is printed beside the rate everywhere the
rate appears.** A rate without its coverage is not reported: at low
coverage the rate describes the reviewed subset, not the fleet.

### Failure-cause split

The five-class split from §3, computed per window: failed first runs and
failed runs overall, each shown as counts and share per class, with
unclassified as its own slice. The task-caused share (task shape plus
task execution) is the slice the distill policy (§4) is expected to
shrink over time.

### Token accounting

Input and output tokens are reported with **recorded and estimated
amounts always shown separately, never blended**. A run that reports its
own token counts contributes recorded tokens; a run that does not is
estimated from the recorded population's per-profile medians, and the
estimate stays labeled as one wherever it appears.

Money figures are **replacement cost at stated proxy rates**: the
scorecard configuration names a reference model and its per-million
input and output prices, and every money figure names those rates as its
basis. Replacement cost answers "what would this token volume cost at
API prices" — it is not money spent. The running cost of the local
models (electricity, computed from engaged GPU hours) is reported
separately, on its own line.

*Example configuration (invented):* reference rates of $2.50 per million
input tokens and $10.00 per million output tokens. At those rates,
40 million recorded input tokens carry a replacement cost of $100.00;
the same volume estimated is reported as an estimated $100.00, on a
separate line from the recorded figure.

### Estimate calibration

Each task states a human-equivalent estimate at authoring. The scorecard
compares the estimate against actual run time per work class (build,
drafts, research, and so on) and reports the median overrun per class. A
class whose median overrun stays high across windows gets its authoring
factor raised; the calibration comes from the fleet's own history, not
from a flat multiplier applied to everything.

## 7. The weekly driver

A scheduled weekly driver (Friday, after the scorecard refresh) owns the
cadence. Session attention is not a mechanism; the driver is. Each run it:

1. **Closes the windows that ended.** For every hypothesis whose target
   window closed, read the primary and guard metrics from the fresh
   scorecard and append the verdict — confirmed, refuted, or
   inconclusive. Apply the attribution check before confirming: re-read
   the target metric with the window shifted one week earlier. Movement
   that appears in the shifted window as well is recorded as
   inconclusive, not confirmed.
2. **Extracts the week's distillation lessons.** Read the distillation
   log (§4). A lesson that recurs twice becomes a rule in the authoring
   skill and, where it is mechanically checkable, a gate in the task
   checker. One-off lessons stay in the log; twice is the promotion
   threshold.
3. **Picks the next hypothesis.** The next registered hypothesis whose
   system is free (no active change on that system, per §2) moves into
   build, with one owner end-to-end.
4. **Publishes the scorecard.** First-run value success with verdict
   coverage beside it, the failure-cause split, token accounting with
   recorded and estimated kept separate, and estimate calibration — the
   four definitions in §6, computed the same way every week.

The driver reports outcomes: cycles closed, verdicts recorded, lessons
promoted, the next build started. A week in which no hypothesis is
active and a breached metric sits unaddressed is a driver failure, and
the driver says so in its report.
