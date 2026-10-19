# Updating this repo

How `pstack-muse-hermes` stays in sync with upstream pstack.

## The principle

**The live setup is the source of truth. The repo is a snapshot.**

Updates flow one direction: live → repo. Never the other way around. We never break a working system trying to keep a public repo pretty.

## The pipeline

```
Upstream pstack changes
        │
        ▼
Weekly upstream watch (automated)
        │
        ▼
Port the changes (adapt Cursor-specific → generic)
        │
        ▼
Update the live skills (Muse.ai side + Hermes side)
        │
        ▼
Verify (all skills load, no regressions)
        │
        ▼
Update this repo (copy, rebrand check, docs)
        │
        ▼
Push (tagged release)
```

## The weekly watch

A scheduled job checks the upstream repo for changes:

- **What it checks:** new commits to `cursor/plugins` `main` branch, `pstack/` directory
- **What it reports:** which files changed, whether they touch already-ported skills or deferred items
- **What it doesn't do:** auto-port, auto-merge, auto-push. A human reviews the diff and decides.

When the watch finds meaningful changes:

1. **Port** — adapt the upstream changes using the same method as the original port (see port notes in each skill's frontmatter for the adaptation patterns).
2. **Update live** — deploy to the working skills directories first.
3. **Verify** — every skill file loads, frontmatter valid, no broken references.
4. **Update repo** — copy the updated skills, re-run the rebrand check (`grep -ri "jimmy\|michael"` should return nothing outside provenance notes).
5. **Push** — commit with a message naming the upstream SHA, tag the release.

## Porting deferred items

The [UPSTREAM.md](../UPSTREAM.md) deferred list is the backlog. When porting a deferred skill:

1. Read the upstream files in full.
2. Identify Cursor-specific mechanics (Task tool, slash triggers, `.mdc`, `/loop`, model slugs).
3. Replace with platform-generic equivalents per the established patterns.
4. Write port notes in the frontmatter explaining every adaptation.
5. Add to both `skills/` (Muse.ai) and `hermes/skills/` (Hermes) as appropriate.
6. Update UPSTREAM.md to move it from deferred to ported.

## Release tagging

- `v1.0.0` — initial public release (Wave 1 + Wave 2 + formal verification pair)
- Minor versions for new ported skills
- Patch versions for fixes and doc updates
- Each release notes the upstream SHA it was verified against
