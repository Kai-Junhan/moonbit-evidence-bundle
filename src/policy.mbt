///|
/// Required evidence for a release decision.
pub struct ReleasePolicy {
  required_ids : Array[String]
  required_artifact_ids : Array[String]
} derive(Eq, Debug, ToJson)

///|
pub fn ReleasePolicy::new(
  required_ids : Array[String],
  required_artifact_ids : Array[String],
) -> ReleasePolicy {
  { required_ids, required_artifact_ids }
}

///|
pub enum PolicyDecision {
  Allowed
  Blocked(Array[String])
} derive(Eq, Debug)

///|
pub fn PolicyDecision::is_allowed(self : PolicyDecision) -> Bool {
  match self {
    Allowed => true
    Blocked(_) => false
  }
}

///|
pub fn PolicyDecision::reasons(self : PolicyDecision) -> Array[String] {
  match self {
    Allowed => []
    Blocked(reasons) => reasons
  }
}

///|
/// Evaluate missing, failed and unlinked evidence before release.
pub fn evaluate_policy(
  bundle : EvidenceBundle,
  policy : ReleasePolicy,
) -> PolicyDecision {
  let reasons : Array[String] = []
  for required_id in policy.required_ids {
    match bundle.find(required_id) {
      None => reasons.push("missing required evidence: " + required_id)
      Some(entry) =>
        if entry.status is Failed {
          reasons.push("required evidence failed: " + required_id)
        }
    }
  }
  for artifact_id in policy.required_artifact_ids {
    match bundle.find(artifact_id) {
      None => reasons.push("missing required artifact: " + artifact_id)
      Some(entry) => {
        if entry.kind is Artifact && entry.digest is None {
          reasons.push("artifact has no digest: " + artifact_id)
        } else if !(entry.kind is Artifact) {
          reasons.push("required artifact has wrong kind: " + artifact_id)
        }
        if entry.status is Failed {
          reasons.push("required artifact failed: " + artifact_id)
        }
      }
    }
  }
  for entry in bundle.entries {
    for required_id in entry.requires {
      match bundle.find(required_id) {
        None =>
          reasons.push(
            "broken evidence link: " + entry.id + " -> " + required_id,
          )
        Some(required) =>
          if required.status is Failed {
            reasons.push(
              "linked evidence failed: " + entry.id + " -> " + required_id,
            )
          }
      }
    }
  }
  if reasons.length() == 0 {
    Allowed
  } else {
    Blocked(reasons)
  }
}
