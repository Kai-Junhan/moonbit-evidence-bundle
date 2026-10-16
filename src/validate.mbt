///|
/// Result of validating the structural invariants of an evidence bundle.
pub enum BundleValidation {
  Valid
  Invalid(Array[String])
} derive(Eq, Debug)

///|
pub fn BundleValidation::is_valid(self : BundleValidation) -> Bool {
  match self {
    Valid => true
    Invalid(_) => false
  }
}

///|
pub fn BundleValidation::issues(self : BundleValidation) -> Array[String] {
  match self {
    Valid => []
    Invalid(issues) => issues
  }
}

///|
/// Validate format, required fields, unique entry IDs and digest syntax.
pub fn validate(bundle : EvidenceBundle) -> BundleValidation {
  let issues : Array[String] = []
  if bundle.format_version != "0.1" {
    issues.push("unsupported format_version: " + bundle.format_version)
  }
  if bundle.project == "" {
    issues.push("project must not be empty")
  }
  if bundle.toolchain == "" {
    issues.push("toolchain must not be empty")
  }
  let ids : Array[String] = []
  for entry in bundle.entries {
    if entry.id == "" {
      issues.push("entry id must not be empty")
    } else if ids.contains(entry.id) {
      issues.push("duplicate entry id: " + entry.id)
    } else {
      ids.push(entry.id)
    }
    if entry.label == "" {
      issues.push("entry " + entry.id + " label must not be empty")
    }
    match entry.digest {
      Some(digest) =>
        if !is_sha256_hex(digest) {
          issues.push(
            "entry " + entry.id + " digest must be 64 lowercase hex characters",
          )
        }
      None => ()
    }
  }
  if issues.length() == 0 {
    Valid
  } else {
    Invalid(issues)
  }
}

///|
fn is_sha256_hex(value : String) -> Bool {
  if value.length() != 64 {
    false
  } else {
    let mut index = 0
    let mut valid = true
    while index < value.length() {
      let code = value.at(index).to_int()
      if !((code >= 48 && code <= 57) || (code >= 97 && code <= 102)) {
        valid = false
        break
      }
      index = index + 1
    }
    valid
  }
}
