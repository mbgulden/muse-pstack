# Bench format — the stocking contract

A bench file is the pre-specced stock the stocking monitor reads. Each
program or workstream keeps its own bench file. The monitor reads the
board plus the bench files and reports, per worker profile, the queue
depth against the floor (default: at least 2 ready tasks behind every
running profile) and the next QUEUED items when a profile sits below
the floor. The monitor is read-only: it never authors tasks. Authoring
a bench item into a task — and flipping its state to DONE — is the
operator's move.

## Entry contract

One entry per work item, in this exact shape:

- A heading line: `## <item title>`
- Field lines, one per line, immediately under the heading:
  - `Owner: <profile>` — the worker profile the item fits.
  - `Source: <paths or links>` — where the item's source material lives:
    the documents, data, or prior deliverables the task author will work
    from.
  - `State: QUEUED` or `State: DONE` — QUEUED means the item is stock,
    available to author; DONE means it has been authored into a task
    (or completed another way) and is no longer stock.
- An optional free-text paragraph under the field lines: scope notes for
  the task author. Tooling ignores it; the author reads it.

Rules the tooling relies on:

- The three field lines appear in the order Owner, Source, State, with
  those exact labels. A missing or renamed field makes the entry
  unreadable, and the monitor reports the entry as malformed rather
  than guessing at it.
- State changes are one word: when an item is authored, the operator
  edits `State: QUEUED` to `State: DONE` in place. Entries are not
  deleted — a bench file with its DONE entries intact shows what the
  program has already drawn from.
- Items are consumed roughly top to bottom within a profile; the
  monitor lists the next QUEUED items in file order.

## Worked example (invented)

# Bench — example content program

## Draft the spring launch announcement post
Owner: writer
Source: docs/launch-brief.md, docs/voice-notes.md
State: DONE
Drafted from the launch brief; keep it under 400 words and in the
program's standard announcement shape.

## Research three competitor pricing pages
Owner: researcher
Source: docs/competitor-list.md
State: QUEUED
Capture each page's tiers and per-seat figures into the comparison
table; cite the page and the date captured for every figure.

## Build the signup form validation pass
Owner: builder
Source: src/signup/, docs/form-spec.md
State: QUEUED
Server-side validation for every field in the form spec, with the
error copy taken from the spec verbatim.
