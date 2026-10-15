///|
pub fn canonical_fingerprint(bundle : EvidenceBundle) -> String {
  bundle.as_json().stringify()
}

///|
pub fn compare_fingerprints(
  left : EvidenceBundle,
  right : EvidenceBundle,
) -> Bool {
  canonical_fingerprint(left) == canonical_fingerprint(right)
}

///|
/// SHA-256 digest of the canonical bundle JSON.
pub fn EvidenceBundle::digest(self : EvidenceBundle) -> String {
  sha256_hex(canonical_fingerprint(self))
}
