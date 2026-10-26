---
name: muse-in-your-own-words
description: "Restate the problem in your own plain words before acting: the user's goals, the underlying issue, and what done looks like — so misunderstandings surface before any work happens. Use at the start of investigation, bug-fix, and report-driven tasks, and whenever a request arrives as a noisy thread or forwarded message."
upstream: cursor/plugins pstack/skills/in-your-own-words/SKILL.md @ d4575673 (v0.15.28)
port_notes: "Adapted 2026-10-24. Upstream body is a single instruction (kept verbatim as the first line below); the application notes are ours, from the Pt. 2 guide: restate before doing anything else, never lead with your own hypotheses, and let the user correct the restatement before work starts. Slash trigger replaced by skill invocation."
---
> **Provenance:** Ported from [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, © 2026 Lauren Tan / poteto).
> Upstream SHA and port notes are in the frontmatter above. Cursor-specific
> mechanics (Task tool, slash triggers, .mdc rules) were replaced with
> platform-generic equivalents. "Jimmy" references rebranded to "Muse" for
> the Muse.ai platform. See [UPSTREAM.md](../../UPSTREAM.md) for the full
> port manifest.


Restate in your own words what you think the user's goals are and what problem they're trying to solve.

How we use it here:
- Do this BEFORE investigating, fixing, or building anything. The restatement is the first artifact, not a byproduct.
- Plain words, structured: the goal, the underlying issue as you understand it, and what a finished result looks like.
- Do not smuggle in your own hypotheses or a proposed solution. A leading restatement limits what you would otherwise find.
- If the user (or task author) corrects the restatement, the correction replaces your read completely — proceed from theirs.
- On kanban tasks: post the restatement as your first comment, then work.
