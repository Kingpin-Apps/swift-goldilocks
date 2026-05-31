# ``Goldilocks``

Ed448, X448, and SHAKE128/256 in pure Swift, with no external crypto
dependencies — works on every Swift-supported platform including
Android and WebAssembly.

## Overview

`Goldilocks` is a thin, idiomatic Swift wrapper over a vendored copy of
[libgoldilocks](https://github.com/otrv4/libgoldilocks) — Mike
Hamburg's MIT-licensed Ed448-Goldilocks / libdecaf successor. It
bundles libgoldilocks' own Keccak/SHAKE implementation, so it has no
dependency on OpenSSL or `libcrypto` and builds anywhere Swift does.

All public entry points are static functions on nested types under the
``Goldilocks`` namespace. There is no instance to construct, except for
the streaming SHAKE classes (``Goldilocks/SHAKE128`` and
``Goldilocks/SHAKE256``) that hold sponge state.

```swift
import Goldilocks

let pub = try Goldilocks.Ed448.derivePublicKey(privateKey: seed)
let sig = try Goldilocks.Ed448.sign(message: msg, privateKey: seed, publicKey: pub)
let ok  = try Goldilocks.Ed448.verify(signature: sig, message: msg, publicKey: pub)
```

### Errors

Every fallible API uses Swift 6 typed throws — `throws(Goldilocks.Error)`.
You don't have to catch a generic `Error`; the compiler knows exactly
which cases can fire. See ``Goldilocks/Error``.

### Skipping the wrapper

If you'd rather call libgoldilocks directly, depend on the
**`CGoldilocks`** product instead. It exposes the `ce_ed448_*`,
`ce_x448_*`, and `cg_shake_*` C symbols.

## Topics

### Ed448 signing

- ``Goldilocks/Ed448``

### X448 key agreement

- ``Goldilocks/X448``

### SHAKE extendable-output functions

- ``Goldilocks/SHAKE128``
- ``Goldilocks/SHAKE256``

### Errors

- ``Goldilocks/Error``
