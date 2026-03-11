# Story Deploy Bead Template Guidance

Story deployment work is stored as deploy beads, not as markdown deployment
plans.

Use upstream Beads via `bd create`, `bd update`, `bd dep add`, and `bd ready`.
See `workflows/helix/BEADS.md`.

## Required Story Deploy Bead Mapping

- native upstream `type: task`
- labels:
  - `helix`
  - `phase:deploy`
  - `kind:deploy`
  - `story:US-XXX`
- governing references in `spec-id` and/or description to:
  - dependent build bead(s)
  - `docs/helix/05-deploy/deployment-checklist.md`
  - `docs/helix/05-deploy/monitoring-setup.md`
  - `docs/helix/05-deploy/runbook.md`
- rollout steps in `description` / `design`
- rollback triggers and verification in `acceptance`
- blockers in dependency links rather than a custom blocked field

## Example Query

`bd list --label helix --label phase:deploy --label story:US-{story-id}`
