///|
pub enum EvidenceStatus {
  Passed
  Failed
  Skipped
} derive(Eq, Debug, ToJson)

///|
pub fn passed() -> EvidenceStatus {
  Passed
}

///|
pub fn failed() -> EvidenceStatus {
  Failed
}

///|
pub fn skipped() -> EvidenceStatus {
  Skipped
}

///|
pub enum EvidenceKind {
  Build
  Test
  Run
  Diagnostic
  Artifact
  Dependency
} derive(Eq, Debug, ToJson)

///|
pub fn build_kind() -> EvidenceKind {
  Build
}

///|
pub fn test_kind() -> EvidenceKind {
  Test
}

///|
pub fn run_kind() -> EvidenceKind {
  Run
}

///|
pub fn diagnostic_kind() -> EvidenceKind {
  Diagnostic
}

///|
pub fn artifact_kind() -> EvidenceKind {
  Artifact
}

///|
pub fn dependency_kind() -> EvidenceKind {
  Dependency
}

///|
pub struct EvidenceEntry {
  id : String
  kind : EvidenceKind
  status : EvidenceStatus
  label : String
  command : String?
  detail : String?
  digest : String?
  requires : Array[String]
} derive(Eq, Debug, ToJson)

///|
pub struct EvidenceBundle {
  format_version : String
  project : String
  toolchain : String
  entries : Array[EvidenceEntry]
} derive(Eq, Debug, ToJson)

///|
pub fn EvidenceEntry::new(
  id : String,
  kind : EvidenceKind,
  status : EvidenceStatus,
  label : String,
  command? : String,
  detail? : String,
  digest? : String,
  requires? : Array[String],
) -> EvidenceEntry {
  let requires = match requires {
    Some(requires) => requires
    None => []
  }
  { id, kind, status, label, command, detail, digest, requires }
}

///|
/// Record content as `Artifact` evidence; `digest` is the SHA-256 hex of the content.
pub fn artifact_entry(
  id : String,
  label : String,
  content : String,
  command? : String,
  detail? : String,
  requires? : Array[String],
) -> EvidenceEntry {
  EvidenceEntry::new(
    id,
    artifact_kind(),
    passed(),
    label,
    command?,
    detail?,
    digest=sha256_hex(content),
    requires?,
  )
}

///|
pub fn EvidenceBundle::new(
  project : String,
  toolchain : String,
) -> EvidenceBundle {
  { format_version: "0.1", project, toolchain, entries: [] }
}

///|
pub fn EvidenceBundle::add(
  self : EvidenceBundle,
  entry : EvidenceEntry,
) -> EvidenceBundle {
  let entries = self.entries.copy()
  entries.push(entry)
  { ..self, entries, }
}

///|
pub fn EvidenceBundle::entry_count(self : EvidenceBundle) -> Int {
  self.entries.length()
}

///|
pub fn EvidenceBundle::find(
  self : EvidenceBundle,
  id : String,
) -> EvidenceEntry? {
  for entry in self.entries {
    if entry.id == id {
      return Some(entry)
    }
  }
  None
}

///|
pub fn EvidenceBundle::project_name(self : EvidenceBundle) -> String {
  self.project
}

///|
pub fn EvidenceBundle::failed(self : EvidenceBundle) -> Array[EvidenceEntry] {
  self.entries.filter(fn(entry) { entry.status is Failed })
}

///|
pub fn EvidenceEntry::as_json(self : EvidenceEntry) -> Json {
  self.to_json()
}

///|
pub fn EvidenceBundle::as_json(self : EvidenceBundle) -> Json {
  self.to_json()
}
