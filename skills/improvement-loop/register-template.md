# Improvement Loop Register — entry template

The register is the loop's memory: one entry per hypothesis, registered
BEFORE its build starts. Entries are never rewritten; status changes and
verdicts are appended as dated lines under the entry. Copy the skeleton
below for each new hypothesis and fill every field — an entry with an
empty field is not registered.

## Entry skeleton

## H-<year>-<number> — <short name of the change>
- Registered: <date>. Status: REGISTERED.
- System: <the one system this change touches>.
- Isolation: <why the effect is isolated and readable — what the change
  does not touch, and what comparison the untouched parts provide>.
- Hypothesis: <the mechanism, in one or two sentences: because X, doing
  Y should move Z>.
- Baseline window: <the measurement window(s) the baseline comes from>.
- Target window: <the two weekly windows the result will be read in>.
- Primary metric: <one metric> — baseline <figure>. Target: <numeric
  target>.
- Guard metrics: <each metric that must not worsen, with its floor or
  ceiling where one applies>.
- Build: <the change's record — task id, branch, or PR link, added when
  the build starts>.
- Appended lines (status changes, notes — dated, never edits):
  - <date>: <status change or note>.

### Verdict (appended when the target window closes)
- Verdict: <confirmed | refuted | inconclusive>. Recorded: <date>.
- Readings: <primary metric in the target window, against baseline and
  target; each guard metric's movement>.
- Attribution check: <the target metric re-read with the window shifted
  one week earlier — movement present there as well means the verdict is
  inconclusive>.
- Follow-up: <what happens next — the change stays, is reverted, or a
  successor hypothesis is registered, with its entry id>.

## Worked example (invented)

## H-2030-01 — split two-file build tasks at authoring
- Registered: Jan 6, 2030. Status: IN BUILD.
- System: task authoring for build-class tasks on the builder profile.
- Isolation: the splitting rule applies to one profile's new build
  tasks; the researcher and writer profiles keep the current authoring
  and serve as the comparison group in the same weeks. Caps, the task
  checker, and recovery handling are untouched.
- Hypothesis: build tasks that name two deliverable files concentrate
  the builder profile's timed-out hours; splitting them at authoring
  into one task per file cuts the timeout load without cutting output.
- Baseline window: the two scorecard windows ending Jan 4, 2030.
- Target window: the two scorecard windows after the rule takes effect.
- Primary metric: timed-out hours share — baseline 22%. Target: under
  15%.
- Guard metrics: weekly completions do not fall; the builder profile's
  share of completed tasks does not fall.
- Build: authoring-skill edit, PR #example-114.
- Appended lines:
  - Jan 9, 2030: rule live; target window opens with the Jan 11
    scorecard.

### Verdict (appended when the target window closes)
- Verdict: confirmed. Recorded: Jan 25, 2030.
- Readings: timed-out hours share 13% across the target window, against
  a 22% baseline and a target of under 15%. Weekly completions rose
  slightly; the builder profile's share of completed tasks held.
- Attribution check: the shifted window (one week earlier) reads 21% —
  the movement does not appear there, so the verdict stands as
  confirmed.
- Follow-up: the rule stays. No successor hypothesis; the next entry
  takes the researcher profile's estimate calibration.
