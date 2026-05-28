import Foundation
import Testing
@testable import Goldilocks

@Suite("Ed448 (RFC 8032)")
struct Ed448Tests {
    // RFC 8032 §7.4 — "Test 1" (zero-length message).
    private let privateKey: [UInt8] = .init(hex: """
        6c82a562cb808d10d632be89c8513ebf
        6c929f34ddfa8c9f63c9960ef6e348a3
        528c8a3fcc2f044e39a3fc5b94492f8f
        032e7549a20098f95b
        """)
    private let publicKey: [UInt8] = .init(hex: """
        5fd7449b59b461fd2ce787ec616ad46a
        1da1342485a70e1f8a0ea75d80e96778
        edf124769b46c7061bd6783df1e50f6c
        d1fa1abeafe8256180
        """)
    private let signature: [UInt8] = .init(hex: """
        533a37f6bbe457251f023c0d88f976ae
        2dfb504a843e34d2074fd823d41a591f
        2b233f034f628281f2fd7a22ddd47d78
        28c59bd0a21bfd3980ff0d2028d4b18a
        9df63e006c5d1c2d345b925d8dc00b41
        04852db99ac5c7cdda8530a113a0f4db
        b61149f05a7363268c71d95808ff2e65
        2600
        """)

    @Test("byte counts match RFC 8032")
    func byteCounts() {
        #expect(Goldilocks.Ed448.privateKeyByteCount == 57)
        #expect(Goldilocks.Ed448.publicKeyByteCount == 57)
        #expect(Goldilocks.Ed448.signatureByteCount == 114)
    }

    @Test("derive public key matches RFC 8032 vector")
    func derivePublicKey() throws {
        let derived = try Goldilocks.Ed448.derivePublicKey(privateKey: privateKey)
        #expect(derived == publicKey)
    }

    @Test("sign produces RFC 8032 signature")
    func sign() throws {
        let sig = try Goldilocks.Ed448.sign(
            message: [UInt8](),
            privateKey: privateKey,
            publicKey: publicKey
        )
        #expect(sig == signature)
    }

    @Test("verify accepts a valid signature")
    func verifyValid() throws {
        let ok = try Goldilocks.Ed448.verify(
            signature: signature,
            message: [UInt8](),
            publicKey: publicKey
        )
        #expect(ok)
    }

    @Test("verify rejects a tampered signature")
    func verifyTampered() throws {
        var bad = signature
        bad[0] ^= 0x01
        let ok = try Goldilocks.Ed448.verify(
            signature: bad,
            message: [UInt8](),
            publicKey: publicKey
        )
        #expect(!ok)
    }

    @Test("verify rejects a wrong-message signature")
    func verifyWrongMessage() throws {
        let ok = try Goldilocks.Ed448.verify(
            signature: signature,
            message: [UInt8]("not-the-original-message".utf8),
            publicKey: publicKey
        )
        #expect(!ok)
    }

    @Test("invalid private-key length throws")
    func invalidPrivateKeyLength() {
        #expect(throws: Goldilocks.Error.invalidKeyLength(expected: 57, actual: 32)) {
            _ = try Goldilocks.Ed448.derivePublicKey(privateKey: [UInt8](repeating: 0, count: 32))
        }
    }

    @Test("invalid signature length throws")
    func invalidSignatureLength() {
        #expect(throws: Goldilocks.Error.invalidSignatureLength(expected: 114, actual: 100)) {
            _ = try Goldilocks.Ed448.verify(
                signature: [UInt8](repeating: 0, count: 100),
                message: [UInt8](),
                publicKey: publicKey
            )
        }
    }
}
