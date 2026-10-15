///|
fn repeat_ascii(unit : String, count : Int) -> String {
  let mut result = ""
  let mut index = 0
  while index < count {
    result = result + unit
    index = index + 1
  }
  result
}

///|
test "sha256 matches nist vectors" {
  assert_eq(
    sha256_hex(""),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
  assert_eq(
    sha256_hex("abc"),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
  assert_eq(
    sha256_hex("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
    "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1",
  )
}

///|
test "sha256 handles padding boundaries" {
  assert_eq(
    sha256_hex(repeat_ascii("a", 55)),
    "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318",
  )
  assert_eq(
    sha256_hex(repeat_ascii("a", 64)),
    "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb",
  )
  assert_eq(
    sha256_hex("The quick brown fox jumps over the lazy dog"),
    "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592",
  )
}

///|
test "sha256 encodes utf-8 for unicode text" {
  assert_eq(
    sha256_hex("\u{4e2d}\u{6587}\u{8bc1}\u{636e}"),
    "24e44dbb5b4eec00bde3c7a551acf2754dffffddc8d2a95bb43ffe380370d802",
  )
  assert_eq(
    sha256_hex("moonbit \u{1F680} evidence"),
    "5193896ff5f72f483012ac1acdadb5e90265d7159a6e6b6410e5367eb3aecc08",
  )
}

///|
test "sha256 hex of bytes matches utf-8 text" {
  let bytes : Array[Byte] = [b'\x61', b'\x62', b'\x63']
  assert_eq(sha256_hex_of_bytes(bytes), sha256_hex("abc"))
}
