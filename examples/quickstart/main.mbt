///|
fn main {
  let test_output = "Total tests: 3, passed: 3, failed: 0."
  let check_output = "Finished. moon: ran 2 tasks, now up to date"
  let bundle = @evidence.EvidenceBundle::new("quickstart", "moon 0.1.20260703")
  let bundle = match
    @evidence.test_run_entry(
      "tests",
      "run tests",
      test_output,
      command="moon test --target wasm-gc",
    ) {
    Some(entry) => bundle.add(entry)
    None => bundle
  }
  let bundle = match
    @evidence.check_run_entry(
      "check",
      "run moon check",
      check_output,
      command="moon check --target wasm-gc --deny-warn",
    ) {
    Some(entry) => bundle.add(entry)
    None => bundle
  }
  println(bundle.as_json().stringify(indent=2))
  println("digest: " + bundle.digest())
  match @evidence.release_gate(bundle) {
    @evidence.ReadyToShip => println("release gate: ready")
    @evidence.Blocked(blockers) =>
      println("release gate: blocked by " + blockers.length().to_string())
  }
}
