///|
fn main {
  let first = sample_bundle(false)
  let second = sample_bundle(true)
  println("moonbit-evidence-bundle demo")
  println("===========================")
  println("project: " + first.project_name())
  println("entries: " + first.entry_count().to_string())
  println("canonical fingerprint: " + @evidence.canonical_fingerprint(first))
  println("")
  println("second run entries: " + second.entry_count().to_string())
  println("second run failed: " + second.failed().length().to_string())
  match @evidence.diff(first, second) {
    @evidence.Identical(fingerprint) =>
      println("diff: identical (" + fingerprint + ")")
    @evidence.Changed(left, right) => {
      println("diff: changed")
      println("  first:  " + left)
      println("  second: " + right)
    }
  }
  println("")
  println("bundle JSON:")
  println(first.as_json().stringify(indent=2))
  println("")
  println("adapter: parse raw moon test output")
  let raw_output = "[demo] test src/evidence_test.mbt:1 (\"bundle records evidence\") ok\n[demo] test src/evidence_test.mbt:39 (\"same fingerprint\") failed\n\nTotal tests: 2, passed: 1, failed: 1.\n"
  match @evidence.parse_test_run_summary(raw_output) {
    Some(summary) => println("summary: " + summary.description())
    None => println("summary: unparseable")
  }
  match
    @evidence.test_run_entry(
      "tests",
      "run tests",
      raw_output,
      command="moon test --target wasm-gc",
    ) {
    Some(entry) => {
      println("collected entry:")
      println(entry.as_json().stringify(indent=2))
    }
    None => println("collected entry: none")
  }
  println("")
  println("adapter: parse raw moon check output")
  let check_output = "Finished. moon: ran 4 tasks, now up to date (2 warnings, 0 errors)"
  match
    @evidence.check_run_entry(
      "check",
      "run moon check",
      check_output,
      command="moon check --target wasm-gc --deny-warn",
    ) {
    Some(entry) => {
      println("collected entry:")
      println(entry.as_json().stringify(indent=2))
    }
    None => println("collected entry: none")
  }
  println("")
  println("release gate:")
  match @evidence.release_gate(first) {
    @evidence.ReadyToShip => println("first bundle: ready to ship")
    @evidence.Blocked(blockers) =>
      println("first bundle: blocked by " + blockers.length().to_string())
  }
  match @evidence.release_gate(second) {
    @evidence.ReadyToShip => println("second bundle: ready to ship")
    @evidence.Blocked(blockers) =>
      println("second bundle: blocked by " + blockers.length().to_string())
  }
  println("")
  println("artifact digest:")
  let report = "demo report: " + first.entry_count().to_string() + " entries"
  let artifact = @evidence.artifact_entry(
    "report", "first bundle report", report,
  )
  match artifact.digest {
    Some(digest) => println("artifact sha256: " + digest)
    None => println("artifact sha256: none")
  }
  println("bundle sha256: " + first.digest())
  match @evidence.validate(first) {
    @evidence.Valid => println("bundle validation: valid")
    @evidence.Invalid(issues) =>
      println(
        "bundle validation: invalid (" +
        issues.length().to_string() +
        " issues)",
      )
  }
}

///|
fn sample_bundle(include_failure : Bool) -> @evidence.EvidenceBundle {
  let bundle = @evidence.EvidenceBundle::new(
      "moonbit-evidence-bundle", "moon 0.1.20260703",
    )
    .add(
      @evidence.EvidenceEntry::new(
        "build",
        @evidence.build_kind(),
        @evidence.passed(),
        "compile source",
        command="moon build --target wasm-gc",
      ),
    )
    .add(
      @evidence.EvidenceEntry::new(
        "tests",
        @evidence.test_kind(),
        if include_failure {
          @evidence.failed()
        } else {
          @evidence.passed()
        },
        "run tests",
        command="moon test --target wasm-gc",
      ),
    )
  if include_failure {
    bundle.add(
      @evidence.EvidenceEntry::new(
        "diagnostic",
        @evidence.diagnostic_kind(),
        @evidence.failed(),
        "one test failed",
        detail="demo failure used to illustrate bundle diff",
      ),
    )
  } else {
    bundle
  }
}
