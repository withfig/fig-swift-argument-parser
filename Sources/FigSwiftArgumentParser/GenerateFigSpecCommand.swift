import Foundation
import ArgumentParser

/// A type used to add the `--generate-fig-spec` flag to your command.
///
/// Add this type as an `@OptionGroup` on your root ParsableCommand,
/// ensuring that it is the _first_ (instance) variable declaration.
/// Pass `Self` as the generic `Root` argument. For example:
///
/// ```swift
/// struct MyCommand: ParsableCommand {
///     @OptionGroup var generateFigSpec: GenerateFigSpec<Self>
///
///     // other variables and methods...
/// }
/// ```
///
/// To generate Fig specs and scripts programmatically, use
/// `ParsableArguments.figSpec()` or `ParsableArguments.figScript()`
/// respectively.
public struct GenerateFigSpec<Root: ParsableArguments>: ParsableArguments {
    @Flag(
        help: .init(
            "Generate a Fig autocomplete specification",
            shouldDisplay: false
        )
    ) var generateFigSpec = false

    public init() {}

    public func validate() throws {
        guard generateFigSpec else { return }
        let script = try Root.figScript()
        throw CleanExit.message(script)
    }
}
