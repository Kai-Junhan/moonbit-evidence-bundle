# Release Checklist

This checklist maps the repository to the MoonBit Hackathon acceptance requirements.

## Repository

- [x] Public GitHub repository: https://github.com/Kai-Junhan/moonbit-evidence-bundle
- [x] MIT license in `LICENSE`
- [x] Meaningful development history with separate feature commits
- [x] MoonBit module metadata in `moon.mod`

## Reproducibility

- [x] README includes installation, API usage and runnable examples
- [x] `cmd/demo` shows test/check adapters, diff, digest, validation and release gate
- [x] `examples/quickstart` shows the smallest complete bundle flow
- [x] `examples/junit` shows JUnit XML ingestion
- [x] CI runs formatting, check, build and test on `wasm-gc` and `js`
- [x] Local verification passes on both targets

## Core Coverage

- [x] Evidence Bundle protocol and JSON serialization
- [x] Moon test and Moon check adapters
- [x] JUnit XML adapter for single, multiple and root-only suites
- [x] SHA-256 artifact and bundle digests
- [x] Bundle validation
- [x] Bundle diff and failed-evidence query
- [x] Release gate

## Before Submission

- [x] Publish `Kai-Junhan/moonbit-evidence-bundle` to Mooncakes at `0.1.0`
- [x] Confirm the authenticated Mooncakes username is `Kai-Junhan`
- [x] Confirm the latest GitHub Actions run is green
- [ ] Submit the one-page proposal with at least three concrete use cases; draft: `PROPOSAL_DRAFT.md`
- [ ] Join the event group and use the GitHub ID as the group nickname
- [ ] Record the demo video if requested by the event staff

## Local Commands

```sh
moon fmt
moon info
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc
moon test --target wasm-gc --deny-warn
moon check --target js --deny-warn
moon build --target js
moon test --target js --deny-warn
moon run --target js cmd/demo
moon run --target js examples/quickstart
moon run --target js examples/junit
moon publish --dry-run
```
