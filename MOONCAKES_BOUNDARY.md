# Mooncakes Boundary Review

Review date: 2026-10-19

## Published Package

The exact package is published and searchable:

- Package: `Kai-Junhan/moonbit-evidence-bundle`
- Version: `0.2.0` (protocol adds explicit `requires` links and release policy evaluation)
- Repository: `https://github.com/Kai-Junhan/moonbit-evidence-bundle`
- License: `MIT`
- Search API: `https://mooncakes.io/api/v0/search?kw=moonbit-evidence-bundle&limit=20`

The package search result lists the root package and its example/source packages. The root summary describes the Evidence Bundle protocol, six evidence kinds, Moon CLI/JUnit adapters, SHA-256, validation, diff and release gate.

## Search Queries

The following searches were performed against the Mooncakes API before resubmission:

- `evidence`
- `release audit`
- `provenance`
- `moonbit-evidence-bundle`

## Functional Boundary

This project provides a portable data protocol and pure transformation functions:

- `EvidenceBundle` / `EvidenceEntry` JSON model
- `moon test`, `moon check` and JUnit XML summary adapters
- canonical serialization and SHA-256 digesting
- structural validation, bundle diff and failed-evidence query
- release gate based on failed evidence
- evidence policy evaluation with required evidence IDs, required artifact IDs, provenance links and fail-closed reasons

This project does not provide:

- workflow/DAG execution or a CI runner
- a test runner, benchmark engine or telemetry runtime
- SBOM, Merkle-tree, dependency scanning or license auditing
- an Event Bus, Trace SDK, DataFrame or ETL system
- a JSON Schema validator, SARIF parser or diagnostic renderer
- a Mooncakes registry, package index or publishing service

## Similar Search Results

Some search results mention “evidence bundle” as part of a different domain. They are not functional duplicates:

- `wch6766/MoonSecureCodec`: supply-chain manifests, SBOM, Merkle roots and audit policy; this project does not implement those systems.
- `mokomoking2501/lockwire`: deterministic test-run substrate and failure reduction; this project only converts external results into evidence entries.
- `mokomoking2501/isoproject`: engineering workbench runtime observations and resource bundles; this project has no workbench, runtime store or UI.
- `vectie/lunanexa/telemetry`: telemetry, benchmarks and capacity objectives; this project does not collect runtime telemetry or evaluate service objectives.

The overlap is terminology around “evidence”, not the implementation boundary. `moonbit-evidence-bundle` is the protocol and comparison layer between tools, not a replacement for those domain systems.

## Ownership and License

The repository is an original project by `Kai-Junhan`. `LICENSE` contains the MIT copyright notice for `Kai-Junhan`. No third-party source code is copied into the implementation. The SHA-256 implementation is a clean-room implementation of the public FIPS 180-4 algorithm; NIST, node and python values are test references only.
