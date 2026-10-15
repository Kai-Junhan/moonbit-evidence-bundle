///|
/// SHA-256 round constants from FIPS 180-4.
let sha256_k : FixedArray[UInt] = [
  0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU, 0x59f111f1U, 0x923f82a4U,
  0xab1c5ed5U, 0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U, 0x72be5d74U, 0x80deb1feU,
  0x9bdc06a7U, 0xc19bf174U, 0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU, 0x2de92c6fU,
  0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU, 0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U,
  0xc6e00bf3U, 0xd5a79147U, 0x06ca6351U, 0x14292967U, 0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU,
  0x53380d13U, 0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U, 0xa2bfe8a1U, 0xa81a664bU,
  0xc24b8b70U, 0xc76c51a3U, 0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U, 0x19a4c116U,
  0x1e376c08U, 0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU, 0x682e6ff3U,
  0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U, 0x90befffaU, 0xa4506cebU, 0xbef9a3f7U,
  0xc67178f2U,
]

///|
/// Lowercase hex SHA-256 digest of the UTF-8 encoding of `text`.
pub fn sha256_hex(text : String) -> String {
  sha256_hex_of_bytes(sha256_utf8_bytes(text))
}

///|
/// Lowercase hex SHA-256 digest of raw bytes.
pub fn sha256_hex_of_bytes(input : Array[Byte]) -> String {
  let message = input.copy()
  let mut bit_len : UInt64 = 0UL
  let mut counted = 0
  while counted < message.length() {
    bit_len = bit_len + 8UL
    counted = counted + 1
  }
  message.push(b'\x80')
  while message.length() % 64 != 56 {
    message.push(b'\x00')
  }
  let mut length_index = 0
  while length_index < 8 {
    let shift = (7 - length_index) * 8
    let length_byte = (bit_len >> shift) & 0xFFUL
    message.push(length_byte.to_uint().to_byte())
    length_index = length_index + 1
  }
  let mut h0 = 0x6a09e667U
  let mut h1 = 0xbb67ae85U
  let mut h2 = 0x3c6ef372U
  let mut h3 = 0xa54ff53aU
  let mut h4 = 0x510e527fU
  let mut h5 = 0x9b05688cU
  let mut h6 = 0x1f83d9abU
  let mut h7 = 0x5be0cd19U
  let block_count = message.length() / 64
  let mut block = 0
  while block < block_count {
    let w : Array[UInt] = []
    let mut schedule = 0
    while schedule < 16 {
      let base = block * 64 + schedule * 4
      let word = (message[base].to_int().reinterpret_as_uint() << 24) |
        (message[base + 1].to_int().reinterpret_as_uint() << 16) |
        (message[base + 2].to_int().reinterpret_as_uint() << 8) |
        message[base + 3].to_int().reinterpret_as_uint()
      w.push(word)
      schedule = schedule + 1
    }
    while schedule < 64 {
      let w15 = w[schedule - 15]
      let w2 = w[schedule - 2]
      let s0 = sha256_rotr(w15, 7) ^ sha256_rotr(w15, 18) ^ (w15 >> 3)
      let s1 = sha256_rotr(w2, 17) ^ sha256_rotr(w2, 19) ^ (w2 >> 10)
      w.push(w[schedule - 16] + s0 + w[schedule - 7] + s1)
      schedule = schedule + 1
    }
    let mut a = h0
    let mut b = h1
    let mut c = h2
    let mut d = h3
    let mut e = h4
    let mut f = h5
    let mut g = h6
    let mut h = h7
    let mut round = 0
    while round < 64 {
      let s1 = sha256_rotr(e, 6) ^ sha256_rotr(e, 11) ^ sha256_rotr(e, 25)
      let ch = (e & f) ^ (e.lnot() & g)
      let temp1 = h + s1 + ch + sha256_k[round] + w[round]
      let s0 = sha256_rotr(a, 2) ^ sha256_rotr(a, 13) ^ sha256_rotr(a, 22)
      let maj = (a & b) ^ (a & c) ^ (b & c)
      let temp2 = s0 + maj
      h = g
      g = f
      f = e
      e = d + temp1
      d = c
      c = b
      b = a
      a = temp1 + temp2
      round = round + 1
    }
    h0 = h0 + a
    h1 = h1 + b
    h2 = h2 + c
    h3 = h3 + d
    h4 = h4 + e
    h5 = h5 + f
    h6 = h6 + g
    h7 = h7 + h
    block = block + 1
  }
  sha256_hex_word(h0) +
  sha256_hex_word(h1) +
  sha256_hex_word(h2) +
  sha256_hex_word(h3) +
  sha256_hex_word(h4) +
  sha256_hex_word(h5) +
  sha256_hex_word(h6) +
  sha256_hex_word(h7)
}

///|
fn sha256_rotr(x : UInt, n : Int) -> UInt {
  (x >> n) | (x << (32 - n))
}

///|
fn sha256_hex_word(word : UInt) -> String {
  let hex = word.to_string(radix=16)
  let mut padded = ""
  let mut pad = 8 - hex.length()
  while pad > 0 {
    padded = padded + "0"
    pad = pad - 1
  }
  padded + hex
}

///|
fn sha256_utf8_bytes(text : String) -> Array[Byte] {
  let bytes : Array[Byte] = []
  for c in text {
    let code = c.to_int()
    if code < 0x80 {
      bytes.push(code.to_byte())
    } else if code < 0x800 {
      bytes.push((0xC0 | (code >> 6)).to_byte())
      bytes.push((0x80 | (code & 0x3F)).to_byte())
    } else if code < 0x10000 {
      bytes.push((0xE0 | (code >> 12)).to_byte())
      bytes.push((0x80 | ((code >> 6) & 0x3F)).to_byte())
      bytes.push((0x80 | (code & 0x3F)).to_byte())
    } else {
      bytes.push((0xF0 | (code >> 18)).to_byte())
      bytes.push((0x80 | ((code >> 12) & 0x3F)).to_byte())
      bytes.push((0x80 | ((code >> 6) & 0x3F)).to_byte())
      bytes.push((0x80 | (code & 0x3F)).to_byte())
    }
  }
  bytes
}
