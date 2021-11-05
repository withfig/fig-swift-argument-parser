import ArgumentParser
import Foundation

public struct GenerateFigSpecCommand<Parent: ParsableCommand>: ParsableCommand {
    public static var configuration: CommandConfiguration {
        .init(
            commandName: "generate-fig-spec"
        )
    }

    public init() {}

    public func run() throws {
        let helpString = Parent._dumpHelp()
        let spec = try FigSpecParser().parse(data: Data(helpString.utf8))
        let js = try FigJSGenerator().generate(from: spec)
        print(js)
    }
}
