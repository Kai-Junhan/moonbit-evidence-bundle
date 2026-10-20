# Evidence Policy Cases

This document shows the complete input -> evidence bundle -> decision path requested for release review.

## Case A: Missing Artifact Evidence

Input policy:

```text
required evidence: check, tests
required artifact: report
```

Input observations:

```text
moon check: passed
moon test: passed
report artifact: not produced
```

Bundle entries:

```json
[
  {"id":"check","kind":"Build","status":"Passed","requires":[]},
  {"id":"tests","kind":"Test","status":"Passed","requires":[]}
]
```

Decision:

```text
Blocked
reason: missing required artifact: report
```

The absence is not treated as success. The policy names the artifact as required, so the gate fails closed.

## Case B: Complete Linked Evidence

Input observations:

```text
moon check: passed
moon test: passed, requires check
release report: produced, requires tests, digest present
```

Bundle entries:

```json
[
  {"id":"check","kind":"Build","status":"Passed","requires":[]},
  {"id":"tests","kind":"Test","status":"Passed","requires":["check"]},
  {"id":"report","kind":"Artifact","status":"Passed","digest":"<64 lowercase hex>","requires":["tests"]}
]
```

Decision:

```text
Allowed
```

The gate is allowed because every required observation exists, every dependency link resolves to a passing entry, and the required artifact has a digest.

## Case C: Broken Provenance Link

Input observations:

```text
moon check: passed
moon test: passed
release report: produced, requires missing-tests
```

Decision:

```text
Blocked
reason: broken evidence link: report -> missing-tests
```

The artifact exists, but the release is still blocked because its claimed upstream test evidence cannot be resolved.

## Case D: Failed Upstream Evidence

Input observations:

```text
moon check: failed
moon test: passed, requires check
release report: produced, requires tests
```

Decision:

```text
Blocked
reason: required evidence failed: check
reason: linked evidence failed: tests -> check
```

This prevents a passing downstream summary from hiding a failed prerequisite.
