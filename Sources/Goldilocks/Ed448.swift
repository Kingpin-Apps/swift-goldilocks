import CGoldilocks
import Foundation

extension Goldilocks {
    /// RFC 8032 pure Ed448 (context = empty, prehashed = no).
    public enum Ed448 {
        /// Length of an Ed448 private-key seed in bytes (57).
        public static let privateKeyByteCount = Int(CE_ED448_PRIVATE_KEY_BYTES)
        /// Length of an Ed448 public key in bytes (57).
        public static let publicKeyByteCount = Int(CE_ED448_PUBLIC_KEY_BYTES)
        /// Length of an Ed448 signature in bytes (114).
        public static let signatureByteCount = Int(CE_ED448_SIGNATURE_BYTES)

        /// Derive the Ed448 public key corresponding to a 57-byte private
        /// seed.
        public static func derivePublicKey(
            privateKey: some ContiguousBytes
        ) throws(Goldilocks.Error) -> [UInt8] {
            try validate(privateKey, length: privateKeyByteCount)
            var pub = [UInt8](repeating: 0, count: publicKeyByteCount)
            pub.withUnsafeMutableBufferPointer { pubBuf in
                privateKey.withUnsafeBytes { privBuf in
                    ce_ed448_derive_public_key(
                        pubBuf.baseAddress,
                        privBuf.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    )
                }
            }
            return pub
        }

        /// Sign `message` with the given Ed448 private key + matching public
        /// key. The public key is required by the C API for efficiency; if
        /// you don't have it, derive it first with ``derivePublicKey(privateKey:)``.
        public static func sign(
            message: some ContiguousBytes,
            privateKey: some ContiguousBytes,
            publicKey: some ContiguousBytes
        ) throws(Goldilocks.Error) -> [UInt8] {
            try validate(privateKey, length: privateKeyByteCount)
            try validate(publicKey, length: publicKeyByteCount)
            var sig = [UInt8](repeating: 0, count: signatureByteCount)
            sig.withUnsafeMutableBufferPointer { sigBuf in
                privateKey.withUnsafeBytes { privBuf in
                    publicKey.withUnsafeBytes { pubBuf in
                        message.withUnsafeBytes { msgBuf in
                            ce_ed448_sign(
                                sigBuf.baseAddress,
                                privBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                                pubBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                                msgBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                                msgBuf.count
                            )
                        }
                    }
                }
            }
            return sig
        }

        /// Verify an Ed448 signature over `message` for the given public key.
        /// Returns `true` if the signature is valid, `false` otherwise.
        /// Throws ``Goldilocks/Error`` only if the input lengths are wrong.
        public static func verify(
            signature: some ContiguousBytes,
            message: some ContiguousBytes,
            publicKey: some ContiguousBytes
        ) throws(Goldilocks.Error) -> Bool {
            let sigLen = signature.withUnsafeBytes { $0.count }
            guard sigLen == signatureByteCount else {
                throw .invalidSignatureLength(expected: signatureByteCount, actual: sigLen)
            }
            try validate(publicKey, length: publicKeyByteCount)
            return signature.withUnsafeBytes { sigBuf in
                publicKey.withUnsafeBytes { pubBuf in
                    message.withUnsafeBytes { msgBuf in
                        ce_ed448_verify(
                            sigBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            pubBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            msgBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            msgBuf.count
                        ) == CE_ED448_SUCCESS
                    }
                }
            }
        }
    }
}

@inline(__always)
internal func validate(
    _ bytes: some ContiguousBytes,
    length expected: Int
) throws(Goldilocks.Error) {
    let actual = bytes.withUnsafeBytes { $0.count }
    guard actual == expected else {
        throw .invalidKeyLength(expected: expected, actual: actual)
    }
}
