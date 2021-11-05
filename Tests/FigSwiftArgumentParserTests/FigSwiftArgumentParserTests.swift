import XCTest
import ArgumentParser
@testable import FigSwiftArgumentParser

struct AnotherCommand: ParsableCommand {
    @Flag var someFlag = false
    @Option var foo: String
    @Argument var requiredArg: String
    @Argument(
        completion: .file(extensions: [])
    ) var optionalArg: String = "hi"
}

struct TestCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [
            AnotherCommand.self,
            GenerateFigSpecCommand<Self>.self
        ]
    )
}

final class FigSwiftArgumentParserTests: XCTestCase {
    // TODO: Add actual tests
    func testExample() throws {
        TestCommand.main(["generate-fig-spec"])
    }
}
