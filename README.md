# swift-goldilocks

A Swift package that vendors **[libgoldilocks](https://github.com/otrv4/libgoldilocks)**
(Mike Hamburg's Ed448-Goldilocks / libdecaf successor, MIT-licensed) and
exposes a small, idiomatic Swift API on top of it.

It exists to be a **single shared crypto dependency** for Swift
packages that need Ed448 / X448 / SHAKE on platforms where neither
[OpenSSL-Package](https://github.com/krzyzanowskim/OpenSSL-Package) (Apple)
nor a system `libcrypto` (Linux) is available — currently Android and
WebAssembly.

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

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Kingpin-Apps/swift-goldilocks.git", from: "0.1.0"),
],
```

Then add the product to your target. Most consumers want the Swift
wrapper:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "Goldilocks", package: "swift-goldilocks"),
    ]
),
```

Or, for raw C access:

```swift
.product(name: "CGoldilocks", package: "swift-goldilocks"),
```

## Usage

All public APIs are static functions on nested types under the
`Goldilocks` namespace. There is no instance to construct, except for
the streaming SHAKE classes that hold sponge state. Fallible APIs use
Swift 6 typed throws — `throws(Goldilocks.Error)`.

### Ed448 signing (RFC 8032)

Ed448 uses a 57-byte private-key seed, a 57-byte public key, and
produces 114-byte signatures.

```swift
import Goldilocks

let seed: [UInt8] = (0..<Goldilocks.Ed448.privateKeyByteCount).map { _ in
    UInt8.random(in: .min ... .max)
}

let publicKey = try Goldilocks.Ed448.derivePublicKey(privateKey: seed)
let message = Array("hello".utf8)

let signature = try Goldilocks.Ed448.sign(
    message: message,
    privateKey: seed,
    publicKey: publicKey
)

let isValid = try Goldilocks.Ed448.verify(
    signature: signature,
    message: message,
    publicKey: publicKey
)
// isValid == true
```

`sign` requires the public key alongside the private seed — the C API
takes it for efficiency. If you don't have it cached, derive it first
with `derivePublicKey(privateKey:)`.

### X448 key agreement (RFC 7748)

X448 uses a 56-byte scalar (private key), produces 56-byte public keys
(u-coordinates), and yields a 56-byte shared secret.

```swift
import Goldilocks

let aliceScalar: [UInt8] = ... // 56 bytes
let bobScalar:   [UInt8] = ... // 56 bytes

let alicePublic = try Goldilocks.X448.derivePublicKey(scalar: aliceScalar)
let bobPublic   = try Goldilocks.X448.derivePublicKey(scalar: bobScalar)

// Alice and Bob each compute the same shared secret.
let aliceShared = try Goldilocks.X448.sharedSecret(
    scalar: aliceScalar,
    peerPublicKey: bobPublic
)
let bobShared = try Goldilocks.X448.sharedSecret(
    scalar: bobScalar,
    peerPublicKey: alicePublic
)
// aliceShared == bobShared
```

`sharedSecret` throws `Goldilocks.Error.invalidPeerPublicKey` if the
peer's key lies in a small subgroup (which would produce the all-zero
shared point — unsafe to use).

### SHAKE128 / SHAKE256 (FIPS 202)

SHAKE is an extendable-output function: you choose the digest length at
call time. Both variants offer a one-shot API and a streaming API. The
streaming form is useful when the input arrives in pieces or when you
want to draw more output later.

#### One-shot

```swift
import Goldilocks

let digest32 = Goldilocks.SHAKE256.hash(Array("abc".utf8), outputByteCount: 32)
let digest64 = Goldilocks.SHAKE128.hash(Array("abc".utf8), outputByteCount: 64)
```

#### Streaming

```swift
let shake = Goldilocks.SHAKE128()
shake.update(Array("part 1 ".utf8))
shake.update(Array("part 2".utf8))

// Squeeze output incrementally — calls compose into a single stream.
let first32  = shake.output(byteCount: 32)
let next32   = shake.output(byteCount: 32)
// first32 + next32 == single 64-byte squeeze
```

Once you call `output(byteCount:)`, the sponge is in squeeze mode and
must not be `update`'d again. Create a fresh instance for a new input.

### Errors

Every fallible API throws `Goldilocks.Error`:

```swift
public enum Error: Swift.Error, Equatable, Sendable {
    case invalidKeyLength(expected: Int, actual: Int)
    case invalidSignatureLength(expected: Int, actual: Int)
    case invalidPeerPublicKey
}
```

Because the API uses typed throws, a `do / catch` block can match each
case exhaustively without the usual `as Goldilocks.Error` cast.

### Raw C surface

If you'd rather drive libgoldilocks directly — for example to share
state with existing C code — depend on `CGoldilocks` instead and import
its symbols:

```swift
import CGoldilocks

var publicKey = [UInt8](repeating: 0, count: Int(CE_ED448_PUBLIC_KEY_BYTES))
publicKey.withUnsafeMutableBufferPointer { pubBuf in
    privateKey.withUnsafeBufferPointer { privBuf in
        ce_ed448_derive_public_key(pubBuf.baseAddress, privBuf.baseAddress)
    }
}
```

The C surface exposes the `ce_ed448_*`, `ce_x448_*`, and `cg_shake_*`
families. See the headers in
[`Sources/CGoldilocks/include`](Sources/CGoldilocks/include).

## Documentation

API reference is published via DocC. Build it locally with:

```sh
swift package generate-documentation --target Goldilocks
```

Or open the package in Xcode and choose **Product → Build Documentation**.
The hosted reference lives at
[swiftpackageindex.com/Kingpin-Apps/swift-goldilocks](https://swiftpackageindex.com/Kingpin-Apps/swift-goldilocks/documentation/goldilocks).

## License

MIT, with the bundled libgoldilocks code carrying its own MIT
attribution (see `Sources/CGoldilocks/LICENSE.libgoldilocks.txt`).
