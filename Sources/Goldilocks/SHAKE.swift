import CGoldilocks
import Foundation

extension Goldilocks {
    /// FIPS 202 SHAKE128 extendable-output function.
    ///
    /// Use ``SHAKE128/hash(_:outputByteCount:)`` for one-shot hashing or
    /// instantiate `SHAKE128()` and call ``update(_:)`` / ``output(byteCount:)``
    /// for streaming.
    public final class SHAKE128 {
        private let sponge: UnsafeMutablePointer<cg_shake_sponge_s>

        public init() {
            sponge = .allocate(capacity: 1)
            cg_shake_init(sponge, CG_SHAKE_128)
        }

        deinit {
            cg_shake_destroy(sponge)
            sponge.deallocate()
        }

        /// Absorb more input into the sponge. Must not be called after
        /// ``output(byteCount:)``.
        public func update(_ data: some ContiguousBytes) {
            data.withUnsafeBytes { buf in
                _ = cg_shake_update(
                    sponge,
                    buf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    buf.count
                )
            }
        }

        /// Squeeze the next `byteCount` bytes of output. Can be called
        /// multiple times to extend the output stream.
        public func output(byteCount: Int) -> [UInt8] {
            var out = [UInt8](repeating: 0, count: byteCount)
            out.withUnsafeMutableBufferPointer { outBuf in
                _ = cg_shake_output(sponge, outBuf.baseAddress, byteCount)
            }
            return out
        }

        /// One-shot SHAKE128: absorb `data` then squeeze `outputByteCount`
        /// bytes.
        public static func hash(
            _ data: some ContiguousBytes,
            outputByteCount: Int
        ) -> [UInt8] {
            var out = [UInt8](repeating: 0, count: outputByteCount)
            data.withUnsafeBytes { inBuf in
                out.withUnsafeMutableBufferPointer { outBuf in
                    _ = cg_shake_hash(
                        CG_SHAKE_128,
                        inBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        inBuf.count,
                        outBuf.baseAddress,
                        outputByteCount
                    )
                }
            }
            return out
        }
    }

    /// FIPS 202 SHAKE256 extendable-output function.
    ///
    /// Use ``SHAKE256/hash(_:outputByteCount:)`` for one-shot hashing or
    /// instantiate `SHAKE256()` and call ``update(_:)`` / ``output(byteCount:)``
    /// for streaming.
    public final class SHAKE256 {
        private let sponge: UnsafeMutablePointer<cg_shake_sponge_s>

        public init() {
            sponge = .allocate(capacity: 1)
            cg_shake_init(sponge, CG_SHAKE_256)
        }

        deinit {
            cg_shake_destroy(sponge)
            sponge.deallocate()
        }

        public func update(_ data: some ContiguousBytes) {
            data.withUnsafeBytes { buf in
                _ = cg_shake_update(
                    sponge,
                    buf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    buf.count
                )
            }
        }

        public func output(byteCount: Int) -> [UInt8] {
            var out = [UInt8](repeating: 0, count: byteCount)
            out.withUnsafeMutableBufferPointer { outBuf in
                _ = cg_shake_output(sponge, outBuf.baseAddress, byteCount)
            }
            return out
        }

        public static func hash(
            _ data: some ContiguousBytes,
            outputByteCount: Int
        ) -> [UInt8] {
            var out = [UInt8](repeating: 0, count: outputByteCount)
            data.withUnsafeBytes { inBuf in
                out.withUnsafeMutableBufferPointer { outBuf in
                    _ = cg_shake_hash(
                        CG_SHAKE_256,
                        inBuf.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        inBuf.count,
                        outBuf.baseAddress,
                        outputByteCount
                    )
                }
            }
            return out
        }
    }
}
