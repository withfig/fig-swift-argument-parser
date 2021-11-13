import Foundation
import ArgumentParser

public struct GenerateFigSpec<Root: ParsableArguments>: ParsableArguments {
    @Flag(
        help: "Generate a Fig autocomplete specification"
    ) var generateFigSpec = false

    public init() {}

    public func validate() throws {
        guard generateFigSpec else { return }
        let spec = try Root.dumpFigSpec()
        throw CleanExit.message(spec)
    }
}
