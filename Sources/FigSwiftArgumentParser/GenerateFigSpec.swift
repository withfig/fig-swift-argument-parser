import Foundation
import FigSchema
import ArgumentParser

extension ParsableArguments {

    /// Generates a `FigSpec` for the caller.
    ///
    /// To add a `--generate-fig-spec` flag to your command,
    /// use ``GenerateFigSpec``.
    ///
    /// - Returns: The generated `FigSpec`.
    public static func figSpec() throws -> FigSpec {
        try FigSpecParser().parse(data: Data(_dumpHelp().utf8))
    }

    /// Generates a `FigSpec` for the caller and dumps
    /// its completion script.
    ///
    /// To add a `--generate-fig-spec` flag to your command,
    /// use ``GenerateFigSpec``.
    ///
    /// - Returns: The generated completion script.
    public static func figScript() throws -> String {
        try figSpec().script()
    }

}
