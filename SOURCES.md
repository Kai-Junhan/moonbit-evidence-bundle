# Sources and Novelty Review

## Review date

2026-10-19

## Moocakes review

The following Moocakes search areas were reviewed before selecting this project:

- `data`
- `workflow`
- `developer tool`
- `trace`
- `event`
- `schema`

The final pre-review search was run against the Mooncakes search API on 2026-10-19 with these queries:

- `evidence`
- `release audit`
- `provenance`
- `moonbit-evidence-bundle`

The exact published package was found as `Kai-Junhan/moonbit-evidence-bundle@0.2.0`, with repository `https://github.com/Kai-Junhan/moonbit-evidence-bundle` and MIT license. The search also returned unrelated packages whose descriptions mention evidence bundles, including `wch6766/MoonSecureCodec`, `mokomoking2501/lockwire`, and `mokomoking2501/isoproject`.

Relevant existing projects include `moonbitlang/workflow`, `mizchi/bitflow`, `MoonFrame`, `moon_databridge`, `moon-data-contract`, `moon-stream-quality`, `eventrail`, `moonreplaykit`, `moon_tracelens`, `moon_tracekit`, `moonsarif`, `moonreport`, `moon-hive`, `moon-proof`, `moonschema` and `json-schema`.

## Deliberate non-overlap

This project does not implement a workflow executor, event bus, trace SDK, DataFrame, data-contract validator, JSON Schema validator, SARIF parser, CI runner or compiler diagnostic renderer. It stores and compares evidence produced by those tools through adapters.

The functional boundary against similarly described packages is explicit: this package owns the portable `EvidenceBundle`/`EvidenceEntry` protocol, Moon CLI/JUnit input adapters, canonical serialization, SHA-256 digesting, structural validation, diffing and release gating. It does not provide a supply-chain manifest, Merkle tree, dependency scanner, benchmark engine, telemetry runtime, test runner, or registry service. Mentioning “evidence bundle” in another package description is therefore not functional duplication.

## Novel contribution

The independent contribution is a MoonBit-native evidence protocol that connects toolchain, command, dependency, diagnostic, API, test and artifact facts into one deterministic bundle with stable fingerprinting and diff semantics.

SHA-256 is a clean-room implementation of the public FIPS 180-4 algorithm written for this project; no third-party code was copied. Test vectors come from NIST plus independent node/python hashes.

The final submission must repeat the Moocakes search and check exact package names, descriptions and exported APIs immediately before publication.

Detailed package and boundary evidence is recorded in `MOONCAKES_BOUNDARY.md`.

## License ownership

This repository is an original project by `Kai-Junhan`. The MIT notice in `LICENSE` names `Kai-Junhan` as the copyright holder. No third-party source code is copied into the implementation. The SHA-256 code is a clean-room implementation of the public FIPS 180-4 algorithm; external NIST/node/python values are test references only.
