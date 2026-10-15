# Development Notes

## Non-overlap rule

Every new feature must answer: does it model, collect, compare or gate evidence? If it executes workflows, validates arbitrary schemas, renders diagnostics or acts as a generic event/log system, it belongs in an adapter or is out of scope.

## Determinism

- Evidence serialization must be stable.
- Canonical fingerprints must not depend on wall-clock time, random values or map iteration order.
- Environment-dependent fields must be explicit and normalized before hashing.
- Diff output must identify the evidence dimension that changed.

## Digests

- `EvidenceEntry.digest` stores a lowercase SHA-256 hex of entry content (UTF-8 for text) or `None`.
- Digests never store raw content; they must be reproducible across targets.
- `EvidenceBundle::digest` is SHA-256 over the canonical bundle JSON.
- SHA-256 is implemented in pure MoonBit (`src/sha256.mbt`) and verified against NIST vectors plus independent node/python hashes.

## Verification

```sh
moon fmt --check
moon info
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
```

New public fields require snapshot updates, compatibility notes and tests for missing, failed and changed evidence.

## Moon CLI output formats

Adapters parse only these documented summary lines (verified on `moon 0.1.20260703`); any other output yields `None` and the caller must handle it:

- `moon test`: `Total tests: 3, passed: 3, failed: 0.`
- `moon check` success: `Finished. moon: ran 2 tasks, now up to date` or `Finished. moon: ran 2 tasks, now up to date (1 warnings, 0 errors)`
- `moon check` failure: `Failed with 0 warnings, 1 errors.`
