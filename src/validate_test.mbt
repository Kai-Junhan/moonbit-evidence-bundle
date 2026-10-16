///|
test "valid bundle passes validation" {
  let bundle = EvidenceBundle::new("demo", "moon").add(
    artifact_entry("report", "report", "payload"),
  )
  let result = validate(bundle)
  assert_true(result.is_valid())
  assert_eq(result.issues().length(), 0)
}

///|
test "validation reports required field and version errors" {
  let bundle = EvidenceBundle::new("", "")
  let result = validate(bundle)
  assert_true(result.is_valid() == false)
  assert_eq(result.issues().length(), 2)
}

///|
test "validation reports duplicate IDs and invalid digest" {
  let first = EvidenceEntry::new(
    "same",
    test_kind(),
    passed(),
    "first",
    digest="not-a-digest",
  )
  let second = EvidenceEntry::new("same", test_kind(), passed(), "second")
  let result = validate(
    EvidenceBundle::new("demo", "moon").add(first).add(second),
  )
  assert_true(result.is_valid() == false)
  assert_eq(result.issues().length(), 2)
}

///|
test "validation accepts entries without optional digest" {
  let result = validate(
    EvidenceBundle::new("demo", "moon").add(
      EvidenceEntry::new("tests", test_kind(), passed(), "run tests"),
    ),
  )
  assert_true(result is Valid)
}
