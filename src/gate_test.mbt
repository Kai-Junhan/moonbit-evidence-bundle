///|
test "passing bundle is ready to ship" {
  let bundle = EvidenceBundle::new("demo", "moon").add(
    EvidenceEntry::new("tests", test_kind(), passed(), "run tests"),
  )
  let decision = release_gate(bundle)
  assert_true(decision.is_ready())
  assert_eq(decision.blockers().length(), 0)
}

///|
test "failed evidence blocks release" {
  let bundle = EvidenceBundle::new("demo", "moon").add(
    EvidenceEntry::new("tests", test_kind(), failed(), "run tests"),
  )
  let decision = release_gate(bundle)
  assert_true(decision.is_ready() == false)
  assert_eq(decision.blockers().length(), 1)
  assert_true(decision.blockers()[0].status == failed())
  assert_true(decision.blockers()[0].id == "tests")
}

///|
test "gate decision renders deterministically" {
  let bundle = EvidenceBundle::new("demo", "moon").add(
    EvidenceEntry::new("lint", diagnostic_kind(), failed(), "lint failed"),
  )
  debug_inspect(release_gate(bundle).is_ready(), content="false")
}
