import Foundation

public struct FigScriptGenerator {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            encoder.outputFormatting.insert(.sortedKeys)
        }
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            encoder.outputFormatting.insert(.withoutEscapingSlashes)
        }
        return encoder
    }()

    public init() {}

    public func generate(from spec: FigSpec) throws -> String {
        let data = try Self.encoder.encode(spec)
        let json = String(decoding: data, as: UTF8.self)
        return """
        const completionSpec: Fig.Spec = \(json);

        export default completionSpec;
        """
    }
}

extension FigSpec: CustomStringConvertible {
    public func script() throws -> String {
        try FigScriptGenerator().generate(from: self)
    }

    public var description: String {
        (try? script()) ?? "<could not convert FigSpec to JavaScript>"
    }
}
