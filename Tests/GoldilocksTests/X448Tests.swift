import Foundation
import Testing
@testable import Goldilocks

@Suite("X448 (RFC 7748)")
struct X448Tests {
    // RFC 7748 §6.2 — Diffie-Hellman vector.
    private let aliceScalar: [UInt8] = .init(hex: """
        9a8f4925d1519f5775cf46b04b5800d4
        ee9ee8bae8bc5565d498c28dd9c9baf5
        74a9419744897391006382a6f127ab1d
        9ac2d8c0a598726b
        """)
    private let alicePublic: [UInt8] = .init(hex: """
        9b08f7cc31b7e3e67d22d5aea121074a
        273bd2b83de09c63faa73d2c22c5d9bb
        c836647241d953d40c5b12da88120d53
        177f80e532c41fa0
        """)
    private let bobScalar: [UInt8] = .init(hex: """
        1c306a7ac2a0e2e0990b294470cba339
        e6453772b075811d8fad0d1d6927c120
        bb5ee8972b0d3e21374c9c921b09d1b0
        366f10b65173992d
        """)
    private let bobPublic: [UInt8] = .init(hex: """
        3eb7a829b0cd20f5bcfc0b599b6feccf
        6da4627107bdb0d4f345b43027d8b972
        fc3e34fb4232a13ca706dcb57aec3dae
        07bdc1c67bf33609
        """)
    private let sharedSecret: [UInt8] = .init(hex: """
        07fff4181ac6cc95ec1c16a94a0f74d1
        2da232ce40a77552281d282bb60c0b56
        fd2464c335543936521c24403085d59a
        449a5037514a879d
        """)

    @Test("byte counts match RFC 7748")
    func byteCounts() {
        #expect(Goldilocks.X448.scalarByteCount == 56)
        #expect(Goldilocks.X448.publicKeyByteCount == 56)
        #expect(Goldilocks.X448.sharedSecretByteCount == 56)
    }

    @Test("derivePublicKey produces Alice's public key from her scalar")
    func deriveAlicePublic() throws {
        let derived = try Goldilocks.X448.derivePublicKey(scalar: aliceScalar)
        #expect(derived == alicePublic)
    }

    @Test("derivePublicKey produces Bob's public key from his scalar")
    func deriveBobPublic() throws {
        let derived = try Goldilocks.X448.derivePublicKey(scalar: bobScalar)
        #expect(derived == bobPublic)
    }

    @Test("Alice + Bob's keys agree on the shared secret")
    func aliceComputesSharedSecret() throws {
        let shared = try Goldilocks.X448.sharedSecret(
            scalar: aliceScalar,
            peerPublicKey: bobPublic
        )
        #expect(shared == sharedSecret)
    }

    @Test("Bob + Alice's keys agree on the shared secret")
    func bobComputesSharedSecret() throws {
        let shared = try Goldilocks.X448.sharedSecret(
            scalar: bobScalar,
            peerPublicKey: alicePublic
        )
        #expect(shared == sharedSecret)
    }

    @Test("invalid scalar length throws")
    func invalidScalarLength() {
        #expect(throws: Goldilocks.Error.invalidKeyLength(expected: 56, actual: 32)) {
            _ = try Goldilocks.X448.derivePublicKey(scalar: [UInt8](repeating: 0, count: 32))
        }
    }
}
