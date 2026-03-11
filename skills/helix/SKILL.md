---
name: helix-workflow
description: HELIX is a test-first development workflow with an authority-ordered planning stack and upstream Beads execution tracking. Use when the user mentions HELIX, wants structured TDD guidance, needs help moving through Frame/Design/Test/Build/Deploy/Iterate, wants implementation work aligned to requirements, design, and tests, wants a repo-wide alignment review or traceability audit, or wants to backfill missing HELIX documentation for an existing codebase.
---

# HELIX Workflow Skill

Guide development using the HELIX methodology: a test-first workflow with a
canonical planning stack and an execution layer tracked in upstream Beads
(`bd`).

## Use This Skill When

- the user is building or refining a feature under HELIX
- the repo has `docs/helix/` or `workflows/helix/`
- the user wants TDD phase guidance or artifact sequencing
- the user wants implementation kept aligned to requirements, design, and tests
- the user wants a ready HELIX bead executed end-to-end with the right quality gates
- the user wants to know whether more HELIX work remains or what the next action should be
- the user wants a repo-wide reconciliation, drift analysis, or traceability audit
- the user wants to backfill HELIX documentation from an existing repo or subsystem

For alignment review, documentation backfill, or other cross-phase repo work, read:

- [cross-phase-actions.md](references/cross-phase-actions.md)

The separate `helix-alignment-review` skill remains available as a narrower
specialist alias for review-heavy requests.

## HELIX Phases

`FRAME -> DESIGN -> TEST -> BUILD -> DEPLOY -> ITERATE`

- `Frame`: define the problem, users, requirements, and acceptance criteria
- `Design`: define architecture, contracts, and technical approach
- `Test`: write failing tests that specify behavior
- `Build`: implement the minimum code to make tests pass
- `Deploy`: release with monitoring and rollback readiness
- `Iterate`: learn from production and plan the next cycle

## Authority Order

When artifacts disagree, prefer:

1. Product Vision
2. Product Requirements
3. Feature Specs / User Stories
4. Architecture / ADRs
5. Solution / Technical Designs
6. Test Plans / Tests
7. Implementation Plans
8. Source Code / Build Artifacts

Tests govern build execution, but they do not override upstream requirements or
design.

## Execution Layer

HELIX uses upstream Beads (`bd`) for execution tracking.

- Use `bd` issues, dependencies, parents, `spec-id`, and labels.
- Do not invent custom bead files or custom status taxonomies.
- Typical labels: `helix`, plus one of `phase:build`, `phase:deploy`,
  `phase:iterate`, or `phase:review`.

If the repo vendors DDx HELIX, read:

- `workflows/helix/README.md`
- `workflows/helix/BEADS.md`
- `workflows/helix/actions/check.md` when the user wants queue health or the next action
- `workflows/helix/actions/implementation.md` when the user wants ready work executed
- relevant phase README and artifact prompts/templates

## How To Work

1. Identify the current phase from the docs and tests.
2. Do the minimum correct work for that phase.
3. Preserve traceability to upstream artifacts.
4. Keep Build subordinate to failing tests.
5. If implementation reveals plan drift, refine upstream artifacts explicitly.

## Core Questions

- `Frame`: what problem are we solving, for whom, and how will we know it works?
- `Design`: what structure, contracts, and constraints satisfy the requirement?
- `Test`: what failing tests prove the behavior?
- `Build`: what is the minimum implementation to make those tests pass?
- `Deploy`: how do we release safely and observe health?
- `Iterate`: what did we learn, and what follow-up work belongs in `bd`?

## Notes

- Use TDD strictly: Red -> Green -> Refactor.
- Security belongs in every phase.
- Escalate contradictions instead of patching around them in code.
- For repo-wide reconciliation or traceability work, use the alignment review flow.
- For repo-wide documentation reconstruction, use the backfill flow rather than inventing requirements from code alone.
- When the ready queue drains, use the check flow before deciding to align, backfill, wait, or stop.

### Test Phase Artifacts
- Test Plan
- Test Suites
- Security Tests

### Build Phase Artifacts
- Implementation Plan
- Secure Coding Guidelines

### Deploy Phase Artifacts
- Deployment Checklist
- Monitoring Setup
- Runbooks

### Iterate Phase Artifacts
- Metrics Dashboard
- Lessons Learned
- Improvement Backlog

## When to Use HELIX

**Good fit**:
- New products or features requiring high quality
- Mission-critical systems where bugs are expensive
- Teams practicing or adopting TDD
- AI-assisted development needing structure
- Security-sensitive applications

**Not ideal for**:
- Quick prototypes or POCs
- Simple scripts with minimal complexity
- Emergency fixes needing immediate deployment

Always enforce the test-first approach: specifications drive implementation, quality is built in from the start.
