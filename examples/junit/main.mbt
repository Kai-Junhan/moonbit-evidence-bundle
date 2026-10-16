///|
fn main {
  let junit = "<testsuites><testsuite name=\"unit\" tests=\"3\" failures=\"0\" errors=\"0\" skipped=\"1\" /><testsuite name=\"integration\" tests=\"2\" failures=\"1\" errors=\"0\" skipped=\"0\" /></testsuites>"
  match
    @evidence.junit_entry(
      "junit",
      "JUnit report",
      junit,
      command="test-runner --junitxml=report.xml",
    ) {
    Some(entry) => {
      println(entry.as_json().stringify(indent=2))
      println("release status: " + status_text(entry.status))
    }
    None => println("invalid JUnit report")
  }
}

///|
fn status_text(status : @evidence.EvidenceStatus) -> String {
  match status {
    @evidence.Passed => "passed"
    @evidence.Failed => "failed"
    @evidence.Skipped => "skipped"
  }
}
