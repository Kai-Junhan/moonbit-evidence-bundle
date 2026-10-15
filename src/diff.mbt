///|
pub enum EvidenceDiff {
  Identical(String)
  Changed(String, String)
} derive(Eq, Debug)

///|
pub fn diff(left : EvidenceBundle, right : EvidenceBundle) -> EvidenceDiff {
  let left_fingerprint = canonical_fingerprint(left)
  let right_fingerprint = canonical_fingerprint(right)
  if left_fingerprint == right_fingerprint {
    Identical(left_fingerprint)
  } else {
    Changed(left_fingerprint, right_fingerprint)
  }
}
