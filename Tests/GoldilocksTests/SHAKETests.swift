import Foundation
import Testing
@testable import Goldilocks

@Suite("SHAKE (FIPS 202)")
struct SHAKETests {
    // Known SHAKE128/256 vectors for empty and "abc" inputs.
    // Cross-checked against NIST FIPS 202 examples and independent
    // implementations (e.g. CryptoKit's SHA3, pycryptodome).

    @Test("SHAKE128('', 32 bytes)")
    func shake128Empty() {
        let out = Goldilocks.SHAKE128.hash([UInt8](), outputByteCount: 32)
        #expect(out.hex == "7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef26")
    }

    @Test("SHAKE256('', 64 bytes)")
    func shake256Empty() {
        let out = Goldilocks.SHAKE256.hash([UInt8](), outputByteCount: 64)
        #expect(out.hex == """
            46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762f\
            d75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be
            """)
    }

    @Test("SHAKE128('abc', 32 bytes)")
    func shake128ABC() {
        let abc = [UInt8]("abc".utf8)
        let out = Goldilocks.SHAKE128.hash(abc, outputByteCount: 32)
        #expect(out.hex == "5881092dd818bf5cf8a3ddb793fbcba74097d5c526a6d35f97b83351940f2cc8")
    }

    @Test("SHAKE256('abc', 64 bytes)")
    func shake256ABC() {
        let abc = [UInt8]("abc".utf8)
        let out = Goldilocks.SHAKE256.hash(abc, outputByteCount: 64)
        #expect(out.hex == """
            483366601360a8771c6863080cc4114d8db44530f8f1e1ee4f94ea37e78b5739\
            d5a15bef186a5386c75744c0527e1faa9f8726e462a12a4feb06bd8801e751e4
            """)
    }

    @Test("SHAKE128 streaming matches one-shot")
    func shake128Streaming() {
        let abc = [UInt8]("abc".utf8)
        let oneShot = Goldilocks.SHAKE128.hash(abc, outputByteCount: 64)

        let s = Goldilocks.SHAKE128()
        s.update([UInt8]("a".utf8))
        s.update([UInt8]("b".utf8))
        s.update([UInt8]("c".utf8))
        let streamed = s.output(byteCount: 64)

        #expect(streamed == oneShot)
    }

    @Test("SHAKE256 streaming matches one-shot")
    func shake256Streaming() {
        let abc = [UInt8]("abc".utf8)
        let oneShot = Goldilocks.SHAKE256.hash(abc, outputByteCount: 128)

        let s = Goldilocks.SHAKE256()
        s.update([UInt8]("a".utf8))
        s.update([UInt8]("bc".utf8))
        let streamed = s.output(byteCount: 128)

        #expect(streamed == oneShot)
    }

    @Test("SHAKE128 output can be squeezed incrementally")
    func shake128IncrementalOutput() {
        let input = [UInt8]("hello world".utf8)
        let oneShot = Goldilocks.SHAKE128.hash(input, outputByteCount: 96)

        let s = Goldilocks.SHAKE128()
        s.update(input)
        var stitched = s.output(byteCount: 32)
        stitched.append(contentsOf: s.output(byteCount: 32))
        stitched.append(contentsOf: s.output(byteCount: 32))

        #expect(stitched == oneShot)
    }
}
