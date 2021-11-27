import Foundation

public class FigScriptGenerator {
    static let shared = FigScriptGenerator()

    private var encoder: JSONEncoder!

    init() {
        setupEncoder()
    }

    private func setupEncoder() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            encoder.outputFormatting.insert(.sortedKeys)
        }
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            encoder.outputFormatting.insert(.withoutEscapingSlashes)
        }
    }

    public func generate(from spec: FigSpec) throws -> String {
        let data = try encoder.encode(spec)
        let json = String(decoding: data, as: UTF8.self)
        return """
        // Autogenerate by fig-swift-argument-parser package

        const completionSpec: Fig.Spec = \(json);

        export default completionSpec;
        """
    }
}

extension FigSpec: CustomStringConvertible {
    public func script() throws -> String {
        try FigScriptGenerator.shared.generate(from: self)
    }

    public var description: String {
        do {
            return try script()
        } catch {
            return "<could not convert FigSpec to JavaScript>"
        }
    }
}
