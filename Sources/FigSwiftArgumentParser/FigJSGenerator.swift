import Foundation

struct FigJSGenerator {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            encoder.outputFormatting.insert(.sortedKeys)
        }
        return encoder
    }()

    func generate(from spec: FigSpec) throws -> String {
        let data = try Self.encoder.encode(spec)
        let json = String(decoding: data, as: UTF8.self)

        // TODO: Maybe wrap in JSON.parse if `spec` is large?
        // https://v8.dev/blog/cost-of-javascript-2019#json
        return """
        const completionSpec: Fig.Spec = \(json);

        export default completionSpec;
        """
    }
}
