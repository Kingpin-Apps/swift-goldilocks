import CGoldilocks
import Foundation

extension Goldilocks {
    /// RFC 7748 X448 Diffie-Hellman key agreement.
    public enum X448 {
        /// Length of an X448 scalar (private key) in bytes (56).
        public static let scalarByteCount = Int(CE_X448_PRIVATE_KEY_BYTES)
        /// Length of an X448 public key (u-coordinate) in bytes (56).
        public static let publicKeyByteCount = Int(CE_X448_PUBLIC_KEY_BYTES)
        /// Length of an X448 shared secret in bytes (56).
        public static let sharedSecretByteCount = Int(CE_X448_SHARED_SECRET_BYTES)

        /// Derive the X448 public key (u-coordinate) corresponding to a
        /// 56-byte scalar.
        public static func derivePublicKey(
            scalar: some ContiguousBytes
        ) throws(Goldilocks.Error) -> [UInt8] {
            try validate(scalar, length: scalarByteCount)
            var pub = [UInt8](repeating: 0, count: publicKeyByteCount)
            pub.withUnsafeMutableBufferPointer { pubBuf in
                scalar.withUnsafeBytes { scalarBuf in
                    ce_x448_derive_public_key(
                        pubBuf.baseAddress,
                        scalarBuf.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    )
                }
            }
            return pub
        }

        /// Compute the X448 shared secret between our `scalar` and the peer's
        /// public key. Throws ``Goldilocks/Error/invalidPeerPublicKey`` if
        /// the peer's key is in a small subgroup (yielding an unsafe
        /// all-zero shared point).
        public static func sharedSecret(
            scalar: some ContiguousBytes,
            peerPublicKey: some ContiguousBytes
        ) throws(Goldilocks.Error) -> [UInt8] {
            try validate(scalar, length: scalarByteCount)
            try validate(peerPublicKey, length: publicKeyByteCount)
            var shared = [UInt8](repeating: 0, count: sharedSecretByteCount)
            let result: ce_ed448_result = shared.withUnsafeMutableBufferPointer { sharedBuf in
                scalar.withUnsafeBytes { scalarBuf in
                    peerPublicKey.withUnsafeBytes { peerBuf in
                        ce_x448_shared_secret(
                            sharedBuf.baseAddress,
                            scalarBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            peerBuf.baseAddress?.assumingMemoryBound(to: UInt8.self)
                        )
                    }
                }
            }
            guard result == CE_ED448_SUCCESS else {
                throw .invalidPeerPublicKey
            }
            return shared
        }
    }
}
