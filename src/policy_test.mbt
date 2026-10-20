///|
fn policy_bundle(include_artifact : Bool, broken_link : Bool) -> EvidenceBundle {
  let bundle = EvidenceBundle::new("demo", "moon")
    .add(EvidenceEntry::new("check", build_kind(), passed(), "moon check"))
    .add(
      EvidenceEntry::new("tests", test_kind(), passed(), "moon tests", requires=[
        "check",
      ]),
    )
  if include_artifact {
    let content = "release artifact"
    let artifact = if broken_link {
      artifact_entry("artifact", "release artifact", content, requires=[
        "missing-tests",
      ])
    } else {
      artifact_entry("artifact", "release artifact", content, requires=["tests"])
    }
    bundle.add(artifact)
  } else {
    bundle
  }
}

///|
test "policy allows complete linked evidence" {
  let result = evaluate_policy(
    policy_bundle(true, false),
    ReleasePolicy::new(["check", "tests"], ["artifact"]),
  )
  assert_true(result.is_allowed())
  assert_eq(result.reasons().length(), 0)
}

///|
test "policy reports missing artifact and broken link" {
  let missing = evaluate_policy(
    policy_bundle(false, false),
    ReleasePolicy::new(["check", "tests"], ["artifact"]),
  )
  assert_true(missing.is_allowed() == false)
  assert_true(missing.reasons().contains("missing required artifact: artifact"))

  let broken = evaluate_policy(
    policy_bundle(true, true),
    ReleasePolicy::new(["check", "tests"], ["artifact"]),
  )
  assert_true(broken.is_allowed() == false)
  assert_true(
    broken.reasons().contains("broken evidence link: artifact -> missing-tests"),
  )
}

///|
test "policy reports failed linked evidence" {
  let bundle = EvidenceBundle::new("demo", "moon")
    .add(EvidenceEntry::new("check", build_kind(), failed(), "moon check"))
    .add(
      EvidenceEntry::new("tests", test_kind(), passed(), "moon tests", requires=[
        "check",
      ]),
    )
    .add(artifact_entry("artifact", "release artifact", "payload"))
  let result = evaluate_policy(
    bundle,
    ReleasePolicy::new(["check", "tests"], ["artifact"]),
  )
  assert_true(result.is_allowed() == false)
  assert_true(result.reasons().contains("required evidence failed: check"))
  assert_true(
    result.reasons().contains("linked evidence failed: tests -> check"),
  )
}
