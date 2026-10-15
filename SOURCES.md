# Sources and Novelty Review

## Review date

2026-10-15

## Moocakes review

The following Moocakes search areas were reviewed before selecting this project:

- `data`
- `workflow`
- `developer tool`
- `trace`
- `event`
- `schema`

Relevant existing projects include `moonbitlang/workflow`, `mizchi/bitflow`, `MoonFrame`, `moon_databridge`, `moon-data-contract`, `moon-stream-quality`, `eventrail`, `moonreplaykit`, `moon_tracelens`, `moon_tracekit`, `moonsarif`, `moonreport`, `moon-hive`, `moon-proof`, `moonschema` and `json-schema`.

## Deliberate non-overlap

This project does not implement a workflow executor, event bus, trace SDK, DataFrame, data-contract validator, JSON Schema validator, SARIF parser, CI runner or compiler diagnostic renderer. It stores and compares evidence produced by those tools through adapters.

## Novel contribution

The independent contribution is a MoonBit-native evidence protocol that connects toolchain, command, dependency, diagnostic, API, test and artifact facts into one deterministic bundle with stable fingerprinting and diff semantics.

SHA-256 is a clean-room implementation of the public FIPS 180-4 algorithm written for this project; no third-party code was copied. Test vectors come from NIST plus independent node/python hashes.

The final submission must repeat the Moocakes search and check exact package names, descriptions and exported APIs immediately before publication.
