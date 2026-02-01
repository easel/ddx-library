# Test Suite: TS-{XXX}

| Test Plan | TP-{XXX} |
|-----------|----------|
| Created   | {YYYY-MM-DD} |
| Status    | Red (failing) |

## Test Files Created

| File | Test Count | Covers AC |
|------|------------|-----------|
| tests/unit/{file}.test.ts | {N} | AC1, AC2 |
| tests/integration/{file}.test.ts | {N} | AC3, AC4 |
| tests/e2e/{file}.e2e.test.ts | {N} | AC5 |

## Fixtures Created

| Fixture | Purpose |
|---------|---------|
| tests/fixtures/{name}.ts | {Description} |

## Verification

```bash
# All tests should FAIL (TDD Red phase)
npm test -- --grep "TS-{XXX}"

# Expected output: X failing, 0 passing
```

## Coverage Map

| Acceptance Criterion | Test File | Test Name |
|---------------------|-----------|-----------|
| AC1: {criterion} | unit/{file}.test.ts | should {behavior} |
| AC2: {criterion} | unit/{file}.test.ts | should {behavior} |
| AC3: {criterion} | integration/{file}.test.ts | should {behavior} |

## Ready for Implementation

- [ ] All acceptance criteria have failing tests
- [ ] Tests are isolated and independent
- [ ] Test data fixtures created
- [ ] Error cases covered
- [ ] Verification command works

## Next Step

Create Implementation Plan IP-{XXX} to make these tests pass.
