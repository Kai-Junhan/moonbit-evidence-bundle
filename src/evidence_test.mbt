///|
fn sample_bundle() -> EvidenceBundle {
  EvidenceBundle::new("demo", "moon 0.1.20260703")
  .add(
    EvidenceEntry::new(
      "build",
      build_kind(),
      passed(),
      "compile source",
      command="moon build --target wasm-gc",
    ),
  )
  .add(
    EvidenceEntry::new(
      "tests",
      test_kind(),
      passed(),
      "run tests",
      command="moon test --target wasm-gc",
    ),
  )
}

///|
test "bundle records reproducible execution evidence" {
  let bundle = sample_bundle()
  assert_eq(bundle.entry_count(), 2)
  assert_eq(bundle.failed().length(), 0)
  assert_true(
    bundle.as_json().stringify().contains("\"format_version\":\"0.1\""),
  )
  debug_inspect(
    [bundle.entry_count(), bundle.failed().length()],
    content="[2, 0]",
  )
}

///|
test "same evidence produces same fingerprint" {
  let left = sample_bundle()
  let right = sample_bundle()
  assert_true(compare_fingerprints(left, right))
  match diff(left, right) {
    Identical(_) => ()
    Changed(_, _) => fail("equal bundles must not differ")
  }
}

///|
test "failed evidence is queryable" {
  let bundle = EvidenceBundle::new("demo", "moon").add(
    EvidenceEntry::new("lint", diagnostic_kind(), failed(), "lint failed"),
  )
  assert_eq(bundle.failed().length(), 1)
}
