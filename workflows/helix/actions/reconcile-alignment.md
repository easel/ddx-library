# HELIX Action: Reconcile Alignment

You are performing an iterative top-down reconciliation review of a HELIX
project.

Your goal is to re-align the implementation with the authoritative planning
stack, identify explicit divergence, determine whether additional execution
work remains for the reviewed scope, and produce deterministic next steps using
upstream Beads (`bd`).

This action is read-only with respect to product code unless explicitly told to
make fixes. It may create or update:

- upstream review beads in `bd`
- upstream execution beads in `bd`
- one durable alignment report in `docs/helix/06-iterate/alignment-reviews/`

## Action Input

You will receive a review scope as an argument, for example:

- `ddx workflow helix execute reconcile-alignment repo`
- `ddx workflow helix execute reconcile-alignment auth`
- `ddx workflow helix execute reconcile-alignment FEAT-003`
- `ddx workflow helix execute reconcile-alignment US-042`

If no scope is given, default to the repository.

## Authority Order

When artifacts disagree, use this authority order:

1. Product Vision
2. Product Requirements
3. Feature Specs / User Stories
4. Architecture / ADRs
5. Solution Designs / Technical Designs
6. Test Plans / Tests
7. Implementation Plans
8. Source Code / Build Artifacts

Rules:

- Higher layers govern lower layers.
- Tests govern build execution but do not override requirements or design.
- Source code reflects current state but does not redefine the plan.
- If a higher layer is missing or contradictory, do not infer intent from lower layers.
- Prefer aligning code to plan. Propose plan changes only when strongly justified.

## Beads Rules

Use native upstream Beads only. Follow:

- `workflows/helix/BEADS.md`
- <https://github.com/steveyegge/beads>
- <https://steveyegge.github.io/beads/>

Do not create custom HELIX bead files.

### Review Structure

Use two bead categories:

1. Review epic
   - native `type: epic`
   - labels: `helix`, `phase:review`, `kind:review`
   - title pattern: `HELIX alignment review: <scope>`

2. Review beads
   - native `type: task`
   - parented to the review epic
   - labels: `helix`, `phase:review`, `kind:review`, plus area labels

Only after consolidation, create execution beads for approved follow-up work.
Execution beads must use native `bd` IDs, `parent`, `deps`, `spec-id`, and
HELIX labels appropriate to the work phase.

## PHASE 0 - Review Bootstrap

1. Verify upstream Beads is available.
   - If `.beads/` is missing, initialize with `bd init`.
2. Determine the review scope.
3. Break the scope into functional areas.
4. Reconcile any existing review epic and review beads for the same scope.
   - Reuse and update existing review work where possible.
   - Mark stale review work as closed, superseded, or split as appropriate.
5. Create or update:
   - one review epic for the run
   - one review bead per functional area
6. Record the epic ID and review bead IDs in the alignment report.

## PHASE 1 - Reconstruct Intent

Using planning artifacts only, summarize:

- product vision
- product requirements
- feature specs
- user stories
- architecture decisions / ADRs
- solution designs
- technical designs
- test plans
- implementation plans

Do not use source code to fill planning gaps in this phase.

## PHASE 2 - Planning Stack Consistency

Validate traceability as a dependency graph, not a forced linear chain.

Check for:

- Vision -> Requirements
- Requirements -> Feature Specs / User Stories
- Requirements / Feature Specs -> Architecture
- Architecture / User Stories / Feature Specs -> Solution or Technical Designs
- Technical Designs / Test Plans -> Implementation Plans
- Specs / Stories / Designs -> Tests

Identify:

- contradictions
- missing links
- underspecified areas
- stale artifacts
- same-layer conflicts
- downstream artifacts that no longer match upstream authority

## PHASE 3 - Implementation Review

Inspect implementation and map it to the planning stack.

Identify:

- workspace/package/module topology
- runtime entry points
- public interfaces
- tests
- feature flags and config switches
- build and deploy surfaces
- major unplanned code paths
- dead or orphaned implementations

## PHASE 4 - Gap Classification

For each relevant area, assign exactly one classification:

- ALIGNED
- INCOMPLETE
- DIVERGENT
- UNDERSPECIFIED
- STALE_PLAN
- BLOCKED

Each classification must include:

- planning evidence
- implementation evidence
- explanation
- default resolution direction: `code-to-plan`, `plan-to-code`, or `decision-needed`
- owning review bead ID

## PHASE 5 - Traceability Matrix

Produce a matrix with:

- Vision item
- Requirement
- Feature Spec / User Story
- Architecture / ADR reference
- Solution / Technical Design reference
- Test reference
- Implementation Plan reference
- Code status
- Classification

## PHASE 6 - Consolidated Report

Create or update the durable report at:

- `docs/helix/06-iterate/alignment-reviews/AR-YYYY-MM-DD[-scope].md`

Use the template at:

- `workflows/helix/templates/alignment-review.md`

The report must consolidate all review beads into one coherent repo artifact.
It is the durable output of the review run.

## PHASE 7 - Execution Beads

After consolidation, create or update deterministic execution beads only for
real gaps that require follow-up work.

Execution bead rules:

- one coherent gap per bead
- use native upstream types such as `task`, `chore`, or `decision`
- assign HELIX phase/kind labels that match the actual work
- set `spec-id` to the nearest governing canonical artifact
- link to the source review bead using description, parenting, or `discovered-from` dependencies
- add explicit blockers with `bd dep add`
- if canonical docs must change before implementation, create the doc/design bead before the code bead
- do not create duplicate beads for the same gap

## PHASE 8 - Execution Order

Output:

- dependency chain
- critical path
- parallelizable execution beads
- blockers
- first recommended execution set
- queue health and exhaustion assessment for the reviewed scope

## Evidence Requirements

Every non-trivial claim must cite:

- planning evidence with file path and line reference where practical
- implementation evidence with file path and line reference where practical

Be explicit about inference when a conclusion is not directly stated by the
artifacts.

## Output Format

Produce these sections in order:

1. Review Metadata
2. Scope and Governing Artifacts
3. Intent Summary
4. Planning Stack Findings
5. Implementation Map
6. Gap Register
7. Traceability Matrix
8. Review Bead Summary
9. Execution Beads Generated
10. Execution Order
11. Open Decisions
12. Queue Health and Exhaustion Assessment

Be precise, deterministic, and evidence-driven.
