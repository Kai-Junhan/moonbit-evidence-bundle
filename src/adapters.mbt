///|
/// Aggregated counters extracted from a `moon test` summary line.
pub struct TestRunSummary {
  total : Int
  passed : Int
  failed : Int
} derive(Eq, Debug, ToJson)

///|
pub fn TestRunSummary::status(self : TestRunSummary) -> EvidenceStatus {
  if self.failed == 0 {
    passed()
  } else {
    failed()
  }
}

///|
pub fn TestRunSummary::description(self : TestRunSummary) -> String {
  "total " +
  self.total.to_string() +
  ", passed " +
  self.passed.to_string() +
  ", failed " +
  self.failed.to_string()
}

///|
/// Parse the final summary line printed by `moon test`,
/// for example `Total tests: 3, passed: 3, failed: 0.`.
pub fn parse_test_run_summary(output : String) -> TestRunSummary? {
  for line in output.split("\n") {
    if line.has_prefix("Total tests:") {
      match parse_test_run_summary_line(line) {
        Some(summary) => return Some(summary)
        None => ()
      }
    }
  }
  None
}

///|
/// Build a `Test` evidence entry from raw `moon test` output.
pub fn test_run_entry(
  id : String,
  label : String,
  output : String,
  command? : String,
) -> EvidenceEntry? {
  match parse_test_run_summary(output) {
    Some(summary) =>
      Some(
        EvidenceEntry::new(
          id,
          test_kind(),
          summary.status(),
          label,
          command?,
          detail=summary.description(),
        ),
      )
    None => None
  }
}

///|
/// Aggregated counters extracted from a `moon check` summary line.
pub struct CheckSummary {
  warnings : Int
  errors : Int
} derive(Eq, Debug, ToJson)

///|
pub fn CheckSummary::status(self : CheckSummary) -> EvidenceStatus {
  if self.errors == 0 {
    passed()
  } else {
    failed()
  }
}

///|
pub fn CheckSummary::description(self : CheckSummary) -> String {
  "warnings " +
  self.warnings.to_string() +
  ", errors " +
  self.errors.to_string()
}

///|
/// Parse the final summary line printed by `moon check`:
/// `Finished. moon: ran 2 tasks, now up to date (1 warnings, 0 errors)`,
/// `Finished. moon: ran 2 tasks, now up to date` or
/// `Failed with 0 warnings, 1 errors.`.
pub fn parse_check_summary(output : String) -> CheckSummary? {
  for line in output.split("\n") {
    let trimmed = line.trim()
    if trimmed.has_prefix("Failed with ") {
      match
        (
          count_before_marker(trimmed, " warnings"),
          count_before_marker(trimmed, " errors"),
        ) {
        (Some(warnings), Some(errors)) => return Some({ warnings, errors })
        _ => ()
      }
    } else if trimmed.has_prefix("Finished. moon:") {
      let warnings = match count_before_marker(trimmed, " warnings") {
        Some(warnings) => warnings
        None => 0
      }
      let errors = match count_before_marker(trimmed, " errors") {
        Some(errors) => errors
        None => 0
      }
      return Some({ warnings, errors })
    }
  }
  None
}

///|
/// Build a `Build` evidence entry from raw `moon check` output.
pub fn check_run_entry(
  id : String,
  label : String,
  output : String,
  command? : String,
) -> EvidenceEntry? {
  match parse_check_summary(output) {
    Some(summary) =>
      Some(
        EvidenceEntry::new(
          id,
          build_kind(),
          summary.status(),
          label,
          command?,
          detail=summary.description(),
        ),
      )
    None => None
  }
}

///|
/// Aggregated counters extracted from JUnit XML `testsuite` elements.
pub struct JunitSummary {
  tests : Int
  failures : Int
  errors : Int
  skipped : Int
} derive(Eq, Debug, ToJson)

///|
pub fn JunitSummary::status(self : JunitSummary) -> EvidenceStatus {
  if self.failures == 0 && self.errors == 0 {
    passed()
  } else {
    failed()
  }
}

///|
pub fn JunitSummary::description(self : JunitSummary) -> String {
  "tests " +
  self.tests.to_string() +
  ", failures " +
  self.failures.to_string() +
  ", errors " +
  self.errors.to_string() +
  ", skipped " +
  self.skipped.to_string()
}

///|
/// Parse numeric counters from JUnit XML `testsuite` elements.
/// Multiple suites are summed; a root-only `testsuites` document is supported.
pub fn parse_junit_summary(xml : String) -> JunitSummary? {
  let mut rest = xml
  let mut tests = 0
  let mut failures = 0
  let mut errors = 0
  let mut skipped = 0
  let mut suite_count = 0
  while true {
    match rest.find("<testsuite") {
      None => break
      Some(index) => {
        let candidate = rest[index + 10:]
        if candidate.has_prefix(" ") || candidate.has_prefix(">") {
          match candidate.find(">") {
            Some(close) => {
              let tag = candidate[:close]
              match junit_count(tag, "tests") {
                Some(value) => {
                  tests = tests + value
                  failures = failures + junit_count_or_zero(tag, "failures")
                  errors = errors + junit_count_or_zero(tag, "errors")
                  skipped = skipped + junit_count_or_zero(tag, "skipped")
                  suite_count = suite_count + 1
                }
                None => ()
              }
              rest = candidate[close + 1:].to_owned()
            }
            None => break
          }
        } else {
          rest = candidate.to_owned()
        }
      }
    }
  }
  if suite_count > 0 {
    Some({ tests, failures, errors, skipped })
  } else {
    match xml.find("<testsuites") {
      Some(index) => {
        let candidate = xml[index + 10:]
        match candidate.find(">") {
          Some(close) => {
            let tag = candidate[:close]
            match junit_count(tag, "tests") {
              Some(tests) =>
                Some({
                  tests,
                  failures: junit_count_or_zero(tag, "failures"),
                  errors: junit_count_or_zero(tag, "errors"),
                  skipped: junit_count_or_zero(tag, "skipped"),
                })
              None => None
            }
          }
          None => None
        }
      }
      None => None
    }
  }
}

///|
/// Build a `Test` evidence entry from JUnit XML output.
pub fn junit_entry(
  id : String,
  label : String,
  xml : String,
  command? : String,
) -> EvidenceEntry? {
  match parse_junit_summary(xml) {
    Some(summary) =>
      Some(
        EvidenceEntry::new(
          id,
          test_kind(),
          summary.status(),
          label,
          command?,
          detail=summary.description(),
        ),
      )
    None => None
  }
}

///|
fn parse_test_run_summary_line(line : StringView) -> TestRunSummary? {
  let mut total : Int? = None
  let mut passed_count : Int? = None
  let mut failed_count : Int? = None
  for part in line.split(",") {
    let trimmed = part.trim()
    if trimmed.has_prefix("Total tests:") {
      total = count_value(trimmed)
    } else if trimmed.has_prefix("passed:") {
      passed_count = count_value(trimmed)
    } else if trimmed.has_prefix("failed:") {
      failed_count = count_value(trimmed)
    }
  }
  match (total, passed_count, failed_count) {
    (Some(total), Some(passed), Some(failed)) => Some({ total, passed, failed })
    _ => None
  }
}

///|
fn count_value(part : StringView) -> Int? {
  match part.split_once(": ") {
    Some((_, value)) => parse_leading_uint(value)
    None => None
  }
}

///|
fn junit_count(tag : StringView, name : StringView) -> Int? {
  let marker = (name.to_owned() + "=\"")[:]
  match tag.find(marker) {
    Some(index) => parse_leading_uint(tag[index + marker.length():])
    None => None
  }
}

///|
fn junit_count_or_zero(tag : StringView, name : StringView) -> Int {
  match junit_count(tag, name) {
    Some(value) => value
    None => 0
  }
}

///|
fn parse_leading_uint(text : StringView) -> Int? {
  let mut index = 0
  let mut value = 0
  let mut digits = 0
  while index < text.length() {
    let digit = text.at(index).to_int() - 48
    if digit < 0 || digit > 9 {
      break
    }
    value = value * 10 + digit
    digits = digits + 1
    index = index + 1
  }
  if digits == 0 {
    None
  } else {
    Some(value)
  }
}

///|
fn count_before_marker(text : StringView, marker : StringView) -> Int? {
  match text.find(marker) {
    Some(index) => {
      let mut cursor = index - 1
      while cursor >= 0 && text.at(cursor).to_int() == 32 {
        cursor = cursor - 1
      }
      let mut value = 0
      let mut place = 1
      let mut digits = 0
      while cursor >= 0 {
        let digit = text.at(cursor).to_int() - 48
        if digit < 0 || digit > 9 {
          break
        }
        value = value + digit * place
        place = place * 10
        digits = digits + 1
        cursor = cursor - 1
      }
      if digits == 0 {
        None
      } else {
        Some(value)
      }
    }
    None => None
  }
}
