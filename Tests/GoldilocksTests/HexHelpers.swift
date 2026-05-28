import Foundation

extension Array where Element == UInt8 {
    init(hex: String) {
        let stripped = hex.filter { !$0.isWhitespace }
        precondition(stripped.count.isMultiple(of: 2), "Hex string must have even length")
        var out: [UInt8] = []
        out.reserveCapacity(stripped.count / 2)
        var index = stripped.startIndex
        while index < stripped.endIndex {
            let next = stripped.index(index, offsetBy: 2)
            guard let byte = UInt8(stripped[index..<next], radix: 16) else {
                preconditionFailure("Invalid hex byte: \(stripped[index..<next])")
            }
            out.append(byte)
            index = next
        }
        self = out
    }

    var hex: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
