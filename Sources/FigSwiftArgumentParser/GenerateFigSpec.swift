import Foundation
import ArgumentParser

//public struct FigConfiguration {
//    public init() {}
//}
//
//public protocol FigConfigurable: ParsableArguments {
//    static var figConfiguration: FigConfiguration { get }
//}

extension ParsableArguments {
    public static func generateFigSpec() throws -> String {
        let helpString = _dumpHelp()
        let spec = try FigSpecParser().parse(data: Data(helpString.utf8))
        return try FigJSGenerator().generate(from: spec)
    }
}

public struct GenerateFigSpec<Root: ParsableArguments>: ParsableArguments {
    @Flag(
        help: "Generate a Fig autocomplete specification"
    ) var generateFigSpec = false

    public init() {}

    public func validate() throws {
        guard generateFigSpec else { return }
        let spec = try Root.generateFigSpec()
        throw CleanExit.message(spec)
    }
}
