import Foundation
import FigSchema
import ArgumentParser

extension ParsableArguments {
    public static func generateFigSpec() throws -> FigSpec {
        try FigSpecParser().parse(data: Data(_dumpHelp().utf8))
    }

    public static func dumpFigSpec() throws -> String {
        try generateFigSpec().toJS()
    }
}
