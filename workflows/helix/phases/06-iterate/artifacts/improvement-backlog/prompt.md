# Improvement Backlog Generation

## Required Inputs
- `docs/helix/06-iterate/lessons-learned.md` - Lessons learned
- `docs/helix/06-iterate/feedback-analysis.md` - User feedback
- `docs/helix/06-iterate/metrics-dashboard.md` - Production metrics

## Produced Output
- `docs/helix/06-iterate/improvement-backlog.md` - Prioritized improvement items

## Prompt

You are creating an improvement backlog for the next iteration. Your goal is to prioritize and document all improvement opportunities.

Based on lessons learned, user feedback, and metrics, create:

1. **Improvement Categories**
   - Feature enhancements
   - Bug fixes
   - Technical debt
   - Performance improvements
   - Security hardening
   - Process improvements

2. **Prioritized Backlog**
   | Priority | Type | Item | Impact | Effort | Source |
   |----------|------|------|--------|--------|--------|
   | P0 | [Category] | [Description] | H/M/L | H/M/L | [Feedback/Metrics/Team] |

3. **Impact Analysis**
   For high-priority items:
   - User impact
   - Business value
   - Technical dependencies
   - Risk if not addressed

4. **Effort Estimation**
   - T-shirt sizing (S/M/L/XL)
   - Dependencies between items
   - Recommended groupings

5. **Next Iteration Candidates**
   - Recommended scope for next iteration
   - Items deferred and why
   - Items requiring more research

Use the template at `workflows/helix/phases/06-iterate/artifacts/improvement-backlog/template.md`.

## Completion Criteria
- [ ] All improvement sources reviewed
- [ ] Items prioritized consistently
- [ ] Next iteration scope recommended
- [ ] Dependencies identified
