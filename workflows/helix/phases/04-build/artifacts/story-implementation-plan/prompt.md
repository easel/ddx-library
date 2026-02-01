# Story Implementation Plan Generation

## Required Inputs
- `docs/helix/03-test/story-test-plans/TP-{XXX}-*.md` - Failing tests for story
- `docs/helix/02-design/technical-designs/TD-{XXX}-*.md` - Technical design

## Produced Output
- `docs/helix/04-build/story-implementation-plans/IP-{XXX}-*.md` - Implementation plan for story

## Prompt

You are creating an implementation plan for a specific user story. Your goal is to make all the failing tests pass using TDD.

Based on the test plan (TP-{XXX}) and technical design (TD-{XXX}), create:

1. **Implementation Sequence**
   Order of implementation to satisfy tests incrementally:
   1. [First component/function to implement]
   2. [Second component/function]
   3. [Continue until all tests pass]

2. **Per-Test Implementation**
   For each failing test:
   | Test | Implementation | Files Modified | Estimated LOC |
   |------|----------------|----------------|---------------|
   | [Test name] | [What to implement] | [Files] | [Lines] |

3. **Code Structure**
   - New files to create
   - Existing files to modify
   - Refactoring needed

4. **Dependencies**
   - External libraries needed
   - Internal module dependencies
   - API contracts to implement

5. **Implementation Checklist**
   - [ ] All unit tests passing
   - [ ] All integration tests passing
   - [ ] Code review completed
   - [ ] Documentation updated

Use the template at `workflows/helix/phases/04-build/artifacts/story-implementation-plan/template.md`.

## Completion Criteria
- [ ] Implementation sequence covers all failing tests
- [ ] Each test has a clear implementation path
- [ ] No `[NEEDS CLARIFICATION]` markers remain
