/// Idiomatic Swift API for the vendored libgoldilocks Ed448-Goldilocks /
/// libdecaf code.
///
/// Use the nested types directly — `Goldilocks.Ed448`, `Goldilocks.X448`,
/// `Goldilocks.SHAKE128`, `Goldilocks.SHAKE256` — there is no instance to
/// construct.
public enum Goldilocks {
    /// Errors thrown by the `Goldilocks` API.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// An input key did not have the expected byte length.
        case invalidKeyLength(expected: Int, actual: Int)
        /// An input signature did not have the expected byte length.
        case invalidSignatureLength(expected: Int, actual: Int)
        /// The peer's X448 public key was in a small subgroup (the shared
        /// secret would be the all-zero point and is unsafe to use).
        case invalidPeerPublicKey
    }
}
