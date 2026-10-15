///|
/// Release decision derived from a bundle's evidence.
pub enum GateDecision {
  ReadyToShip
  Blocked(Array[EvidenceEntry])
} derive(Eq, Debug)

///|
pub fn GateDecision::is_ready(self : GateDecision) -> Bool {
  match self {
    ReadyToShip => true
    Blocked(_) => false
  }
}

///|
pub fn GateDecision::blockers(self : GateDecision) -> Array[EvidenceEntry] {
  match self {
    ReadyToShip => []
    Blocked(entries) => entries
  }
}

///|
/// A bundle ships only when it contains no failed evidence entry.
pub fn release_gate(bundle : EvidenceBundle) -> GateDecision {
  let failures = bundle.failed()
  if failures.length() == 0 {
    ReadyToShip
  } else {
    Blocked(failures)
  }
}
