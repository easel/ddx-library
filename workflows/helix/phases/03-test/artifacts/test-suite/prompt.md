# Test Suite Creation Prompt

Generate actual failing test files from the test plan. This is the TDD Red phase - tests must fail because no implementation exists yet.

## Input Required

- **Test Plan**: TP-{XXX} from Phase 03-test
- **User Stories**: US-{XXX} with acceptance criteria
- **Technical Design**: TD-{XXX} for component structure

## Output: Actual Test Files

Create executable test files in the `tests/` directory that will:
1. **FAIL** when run (no implementation exists)
2. **Define** expected behavior through assertions
3. **Cover** all acceptance criteria from user stories

## Process

### Step 1: Map Acceptance Criteria to Tests

For each acceptance criterion in the user story:
```
AC1: "User can log in with valid credentials"
  -> tests/unit/auth.test.ts: should authenticate user with valid credentials
  -> tests/integration/auth-flow.test.ts: should issue JWT on successful login
```

### Step 2: Write Minimal Failing Tests

Each test should:
- Import the module that WILL exist (causes import error = Red)
- Call the function that WILL exist (causes undefined error = Red)
- Assert the expected behavior (will fail when implemented wrong)

### Step 3: Organize by Test Type

```
tests/
  unit/           # Pure function tests
  integration/    # Component interaction tests
  e2e/            # User journey tests (optional in Red phase)
  fixtures/       # Test data
```

### Step 4: Verify Red State

```bash
npm test  # ALL tests should fail
```

## Test File Template

```typescript
// tests/unit/{feature}.test.ts
import { describe, it, expect } from 'vitest';
import { featureFunction } from '@/modules/feature'; // Will fail - doesn't exist

describe('Feature: {Feature Name}', () => {
  describe('AC1: {Acceptance Criterion}', () => {
    it('should {expected behavior}', () => {
      // Arrange
      const input = { /* test data */ };

      // Act - Will fail (function doesn't exist)
      const result = featureFunction(input);

      // Assert
      expect(result).toEqual({ /* expected */ });
    });

    it('should reject {invalid case}', () => {
      expect(() => featureFunction(null)).toThrow('Invalid input');
    });
  });
});
```

## Naming Convention

| Test Type | File Pattern | Example |
|-----------|--------------|---------|
| Unit | `{module}.test.ts` | `auth.test.ts` |
| Integration | `{feature}-flow.test.ts` | `login-flow.test.ts` |
| E2E | `{journey}.e2e.test.ts` | `checkout.e2e.test.ts` |

## Quality Checklist

Before completing the test suite:

- [ ] Every acceptance criterion has at least one test
- [ ] Tests are organized by type (unit/integration/e2e)
- [ ] All tests FAIL when run (Red phase confirmed)
- [ ] Test fixtures are created for reusable data
- [ ] Tests are independent (no shared state)
- [ ] Error cases are covered

## Output Artifact

After creating tests, generate the Test Suite manifest (TS-{XXX}) documenting:
- Files created
- Test counts per file
- Acceptance criteria coverage
- Verification command

## Anti-Patterns

- Writing tests that pass (means you wrote implementation too)
- Skipping error cases
- Testing implementation details instead of behavior
- Hardcoding test data in each test

## Next: Implementation Plan

With failing tests in place, create IP-{XXX} to plan the implementation that will make these tests pass (Green phase).
