---
name: muse-loop-discipline
description: "Run iterative build/verify work as a measured loop: freeze one spec as the source of truth, verify the fixture set before building on it, measure before approximating, diff against both the reference and your last approved version, promote every defect class into a standing check, and stop only after two consecutive clean rounds. Use whenever a deliverable is built or verified over multiple versions against a reference, a spec, or an approved baseline — artwork, renders, ports, migrations, generated files, reconstructions."
---

# Loop discipline

Some deliverables are built in one pass. Others converge: build, compare against a reference or an approved baseline, fix, compare again. This skill is the discipline for the second kind. It was distilled from the Human Design bodygraph artwork loop (Nov 4, 2026), where versions v0–v7 were counted and every defect was attributed to who caught it. The pattern in that record drives everything below: the worker's own checks caught instances; the reviewer and the owner caught categories nobody had named yet. A loop that only fixes instances spends its versions rediscovering categories.

## 1. Freeze the spec before the first build

- One file is the source of truth for what the deliverable must be: measurements, values, geometry, rules. Everything else — builders, checkers, task bodies — references it. No second copy of a value lives anywhere else.
- Spec the construction system, not just the outputs: the rules that generate the pieces (shared constructions, spacing families, ordering and layering rules, exception lists) are named spec objects, versioned and diffed the same way outputs are. A spec that lists only final positions forces every later worker to re-derive the system from the positions.
- A spec change is a change: version it, diff it, say why. Baselines and approved versions update only through review, never silently mid-loop.

## 2. Verify the fixtures before building on them

- The fixture set is the loop's ground truth, so its own data gets verified against its source (source documents, engine output, the reference itself) before the first build or render that uses it. A wrong fixture manufactures defects that do not exist and hides ones that do.
- Choose fixtures for combination coverage, not convenience: across the set, every element class and every state the deliverable can take appears at least once — dense and sparse, common and edge. Two favorite fixtures re-run ten times prove less than a coverage set run twice.
- When a fixture is found wrong mid-loop, fix the fixture, name the find in the metrics file, and re-run: earlier rounds judged against it are suspect.

## 3. Measure first; validate the instrument

- Extract measurements from the reference before building. Approximation rounds are spent versions: in the origin run, three versions burned on approximate geometry, and the first fully measured build was clean on arrival.
- A measurement is only as good as the instrument. Before a measurement method's output enters the spec, cross-check it against a second, independent method on a sample. A method the cross-check proves biased is dropped and named in the report — never averaged in.
- Declare tolerances before judging: what deviation counts as a defect, per quantity. Tolerances set after seeing the results are not tolerances.

## 4. Run rounds; diff against two baselines

- Work in rounds: build one version, diff it, batch every fix the diff produces into the next version. One fix per version hides the burn-down rate.
- Diff against the reference: the trend. Track a similarity or changed-mass number per version where the medium allows one (image similarity, diff size, failing-check count). The trend is a measurement, not a gate — pipelines and renderers differ, and an absolute threshold against an external reference punishes the wrong things.
- Diff against your own last approved version: the gate. Your own pipeline is deterministic, so unintended change anywhere — including regions nobody re-examined this round — is a defect by default. Whole-output comparison catches what property checks cannot, because property checks only verify what someone named in advance.
- Check at more than one scale: the production size and the working size (a small render, a reduced input, a summary view). Defects hide at scales nobody opened.

## 5. Promote every defect to a category check

- Every defect found — by you, by a reviewer, by the owner — gets classified before it gets fixed. If it names a class (a shape class, an alignment family, an ordering rule, a data-source error), the class becomes a named standing check that runs every round from then on, kept in the work's own check list or audit script.
- Fixing the instance without promoting the class is half a fix: the same class returns in the next view, the next port, the next worker.
- Reviewers: a verdict names the class of each defect it reports, not only the instance, and fails a deliverable whose fix did not promote a class-level find into a check.

## 6. Stop rule and version metrics

- Stop when the diff list is empty and two consecutive confirmation rounds over the full fixture set come back clean. No fixed round cap: late rounds in the origin run were still finding substance, and a cap ships what the next round would have caught.
- Count versions. Each deliverable keeps a metrics file (named by its task or its workflow doc) with one row per version: diff items found, items fixed, the trend number where one exists, and who caught each defect — worker, reviewer, or owner.
- The process health number is owner-caught defects trending to zero. A version the owner had to correct is data about the loop, and it goes in the metrics file, not just into the fix.

## 7. Where this plugs in

- `pstack-create-verification-skill`: a verification skill generated for an iterative deliverable carries the frozen spec it verifies against, the verified fixture set, the standing category checks, and the metrics file (§§1–2, 5–6 here).
- `pstack-maintain-verification-skill`: maintenance triage is where category promotion happens for existing verification skills — a drift finding that names a class becomes a standing check in the map (§5).
- Formal verification (`pstack-create-formal-verification-skill`, `pstack-maintain-formal-verification-skill`): when a counterexample names a class, strengthen the property set; do not patch the model to absorb the single case (§5).
- Kanban authoring (`hermes-kanban-tasks` §3c, Muse-side): a task body for iterative work names the frozen spec, the fixture/coverage set, the standing category checks, and the version-metrics file before dispatch.
