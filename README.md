# swift-goldilocks

A Swift package that vendors **[libgoldilocks](https://github.com/otrv4/libgoldilocks)**
(Mike Hamburg's Ed448-Goldilocks / libdecaf successor, MIT-licensed) and
exposes a small, idiomatic Swift API on top of it.

It exists to be a **single shared crypto dependency** for Cardano-Swift
packages that need Ed448 / X448 / SHAKE on platforms where neither
[OpenSSL-Package](https://github.com/krzyzanowskim/OpenSSL-Package) (Apple)
nor a system `libcrypto` (Linux) is available — currently Android and
WebAssembly.

Before this package, [swift-curve448](https://github.com/Kingpin-Apps/swift-curve448)
vendored a copy of libgoldilocks for its own Ed448/X448 needs, and
[swift-cose](https://github.com/Kingpin-Apps/swift-cose) was about to vendor
*another* copy for SHAKE128/256. Both now depend on this package instead.

## What it provides

- **`Goldilocks.Ed448`** — RFC 8032 pure Ed448 signing, verification, and
  public-key derivation.
- **`Goldilocks.X448`** — RFC 7748 X448 key agreement and public-key
  derivation.
- **`Goldilocks.SHAKE128` / `Goldilocks.SHAKE256`** — FIPS 202 SHAKE
  extendable-output functions, one-shot and streaming.

The underlying C symbols are also available via the `CGoldilocks` module
for consumers that want to skip the Swift wrapper.

## Platforms

This package builds and runs everywhere Swift does. It carries no
external crypto dependencies — Keccak/SHAKE is implemented in the
vendored libgoldilocks code, so it works on Android and Wasm where
`libcrypto` is unavailable.

## Usage

```swift
.package(url: "https://github.com/Kingpin-Apps/swift-goldilocks.git", from: "0.1.0"),
```

```swift
import Goldilocks

// Ed448 signing
let publicKey = Goldilocks.Ed448.derivePublicKey(privateKey: seed)
let signature = Goldilocks.Ed448.sign(message: msg, privateKey: seed, publicKey: publicKey)
let ok = Goldilocks.Ed448.verify(signature: signature, message: msg, publicKey: publicKey)

// X448 key agreement
let shared = Goldilocks.X448.sharedSecret(scalar: mine, peerPublicKey: theirs)

// SHAKE one-shot
let digest = Goldilocks.SHAKE256.hash(input, outputByteCount: 32)

// SHAKE streaming
let shake = Goldilocks.SHAKE128()
shake.update(part1)
shake.update(part2)
let out = shake.output(byteCount: 64)
```

## License

MIT, with the bundled libgoldilocks code carrying its own MIT
attribution (see `Sources/CGoldilocks/LICENSE.libgoldilocks.txt`).
