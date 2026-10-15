///|
test "artifact entry carries content digest" {
  let entry = artifact_entry("report", "bundle report", "payload")
  assert_true(entry.kind == artifact_kind())
  assert_true(entry.status == passed())
  assert_true(entry.digest == Some(sha256_hex("payload")))
}

///|
test "text entries carry no digest by default" {
  let entry = EvidenceEntry::new("tests", test_kind(), passed(), "run tests")
  assert_true(entry.digest is None)
}

///|
test "bundle digest is stable and sensitive to content" {
  let first = EvidenceBundle::new("demo", "moon").add(
    artifact_entry("report", "bundle report", "payload"),
  )
  let same = EvidenceBundle::new("demo", "moon").add(
    artifact_entry("report", "bundle report", "payload"),
  )
  let changed = EvidenceBundle::new("demo", "moon").add(
    artifact_entry("report", "bundle report", "payload!"),
  )
  assert_eq(first.digest().length(), 64)
  assert_eq(first.digest(), same.digest())
  assert_true(first.digest() != changed.digest())
  match diff(first, changed) {
    Identical(_) => fail("digest change must alter bundle diff")
    Changed(_, _) => ()
  }
}
