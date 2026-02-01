# Iteration Planning Generation

## Required Inputs
- `docs/helix/06-iterate/improvement-backlog.md` - Improvement backlog
- `docs/helix/06-iterate/lessons-learned.md` - Lessons learned
- Resource availability

## Produced Output
- `docs/helix/06-iterate/iteration-planning.md` - Next iteration plan

## Prompt

You are planning the next iteration. Your goal is to define scope, goals, and success criteria.

Create a plan that includes:

1. **Iteration Goals**
   - Primary objectives
   - Success criteria
   - Key results

2. **Scope Definition**
   | Item | Type | Priority | Estimated Effort |
   |------|------|----------|------------------|
   | [From backlog] | Feature/Fix/Debt | P0/P1/P2 | S/M/L/XL |

3. **Resource Allocation**
   - Team assignments
   - Skills needed
   - External dependencies

4. **Timeline**
   - Iteration duration
   - Key milestones
   - Phase allocations (Frame/Design/Test/Build/Deploy)

5. **Risk Assessment**
   - Scope risks
   - Technical risks
   - Resource risks
   - Mitigation plans

6. **Success Metrics**
   - How success will be measured
   - Baseline values
   - Target values

Use the template at `workflows/helix/phases/06-iterate/artifacts/iteration-planning/template.md`.

## Completion Criteria
- [ ] Scope is well-defined
- [ ] Goals are measurable
- [ ] Resources allocated
- [ ] Risks identified with mitigations
