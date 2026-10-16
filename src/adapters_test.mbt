///|
test "parses a passing moon test summary" {
  let summary = parse_test_run_summary("Total tests: 3, passed: 3, failed: 0.").unwrap()
  assert_eq(summary.total, 3)
  assert_eq(summary.passed, 3)
  assert_eq(summary.failed, 0)
  assert_true(summary.status() == passed())
  debug_inspect(summary, content="{ total: 3, passed: 3, failed: 0 }")
}

///|
test "parses a failing summary inside noisy output" {
  let output = "[demo] test src/demo_test.mbt:1 (\"build passes\") ok\n[demo] test src/demo_test.mbt:9 (\"layout is stable\") failed\n\nTotal tests: 2, passed: 1, failed: 1.\n"
  let summary = parse_test_run_summary(output).unwrap()
  assert_eq(summary.failed, 1)
  assert_true(summary.status() == failed())
  debug_inspect(
    summary.description(),
    content="\"total 2, passed 1, failed 1\"",
  )
}

///|
test "missing or malformed summary yields none" {
  assert_true(parse_test_run_summary("no summary here") is None)
  assert_true(
    parse_test_run_summary("Total tests: many, passed: 1, failed: 0.") is None,
  )
  assert_true(parse_test_run_summary("Total tests: 1, passed: 1") is None)
}

///|
test "test run entry captures command and counters" {
  let output = "Total tests: 4, passed: 3, failed: 1."
  let entry = test_run_entry(
    "tests",
    "run tests",
    output,
    command="moon test --target wasm-gc",
  ).unwrap()
  assert_true(entry.status == failed())
  assert_true(entry.command == Some("moon test --target wasm-gc"))
  assert_true(entry.detail == Some("total 4, passed 3, failed 1"))
  debug_inspect(entry.detail, content="Some(\"total 4, passed 3, failed 1\")")
}

///|
test "unparseable output yields no entry" {
  assert_true(test_run_entry("tests", "run tests", "boom") is None)
}

///|
test "parses a clean moon check summary" {
  let summary = parse_check_summary(
    "Finished. moon: ran 2 tasks, now up to date",
  ).unwrap()
  assert_eq(summary.warnings, 0)
  assert_eq(summary.errors, 0)
  assert_true(summary.status() == passed())
}

///|
test "parses moon check warnings from the finished line" {
  let output = "Warning: [0001]\n\nFinished. moon: ran 2 tasks, now up to date (1 warnings, 0 errors)\n"
  let summary = parse_check_summary(output).unwrap()
  assert_eq(summary.warnings, 1)
  assert_eq(summary.errors, 0)
  assert_true(summary.status() == passed())
  debug_inspect(summary, content="{ warnings: 1, errors: 0 }")
}

///|
test "parses a failed moon check summary" {
  let output = "Failed with 0 warnings, 1 errors.\nError: failed to run check for target WasmGC\n"
  let summary = parse_check_summary(output).unwrap()
  assert_eq(summary.warnings, 0)
  assert_eq(summary.errors, 1)
  assert_true(summary.status() == failed())
}

///|
test "check run entry captures counters and command" {
  let entry = check_run_entry(
    "check",
    "run moon check",
    "Finished. moon: ran 2 tasks, now up to date",
    command="moon check --target wasm-gc --deny-warn",
  ).unwrap()
  assert_true(entry.status == passed())
  assert_true(entry.command == Some("moon check --target wasm-gc --deny-warn"))
  assert_true(entry.detail == Some("warnings 0, errors 0"))
}

///|
test "unparseable check output yields no summary" {
  assert_true(parse_check_summary("boom") is None)
  assert_true(
    parse_check_summary("Failed with many warnings, 1 errors.") is None,
  )
  assert_true(check_run_entry("check", "run check", "boom") is None)
}

///|
test "parses one junit suite" {
  let xml = "<testsuite name=\"unit\" tests=\"3\" failures=\"1\" errors=\"0\" skipped=\"1\"><testcase /></testsuite>"
  let summary = parse_junit_summary(xml).unwrap()
  assert_eq(summary.tests, 3)
  assert_eq(summary.failures, 1)
  assert_eq(summary.errors, 0)
  assert_eq(summary.skipped, 1)
  assert_true(summary.status() == failed())
  debug_inspect(
    summary,
    content="{ tests: 3, failures: 1, errors: 0, skipped: 1 }",
  )
}

///|
test "sums multiple junit suites" {
  let xml = "<testsuites><testsuite name=\"unit\" tests=\"2\" failures=\"0\" errors=\"0\" skipped=\"0\" /><testsuite name=\"integration\" tests=\"4\" failures=\"0\" errors=\"1\" skipped=\"1\" /></testsuites>"
  let summary = parse_junit_summary(xml).unwrap()
  assert_eq(summary.tests, 6)
  assert_eq(summary.failures, 0)
  assert_eq(summary.errors, 1)
  assert_eq(summary.skipped, 1)
  assert_true(summary.status() == failed())
}

///|
test "parses root-only junit counters" {
  let xml = "<testsuites tests=\"5\" failures=\"0\" errors=\"0\" skipped=\"2\" />"
  let summary = parse_junit_summary(xml).unwrap()
  assert_eq(summary.tests, 5)
  assert_eq(summary.skipped, 2)
  assert_true(summary.status() == passed())
}

///|
test "junit entry preserves command and status" {
  let entry = junit_entry(
    "junit",
    "JUnit report",
    "<testsuite tests=\"1\" failures=\"0\" errors=\"0\" skipped=\"0\" />",
    command="pytest --junitxml=report.xml",
  ).unwrap()
  assert_true(entry.kind == test_kind())
  assert_true(entry.status == passed())
  assert_true(entry.command == Some("pytest --junitxml=report.xml"))
  assert_true(entry.detail == Some("tests 1, failures 0, errors 0, skipped 0"))
}

///|
test "malformed junit yields none" {
  assert_true(
    parse_junit_summary("<testsuite name=\"missing counters\" />") is None,
  )
  assert_true(junit_entry("junit", "JUnit report", "not xml") is None)
}
