import XCTest
import ArgumentParser
@testable import FigSwiftArgumentParser

struct TestSubcommand: ParsableCommand {}

struct TestCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [TestSubcommand.self]
    )

    // must be declared first so that its validate() gets called before
    // all others
    @OptionGroup var generateFigSpec: GenerateFigSpec<Self>

    @Option var myOption: String = "defaultValue"

    func run() throws {}
}

final class CLITests: XCTestCase {

    func testGeneratePrintsSpec() throws {
        let spec = try TestCommand.dumpFigSpec()
        XCTAssertThrowsError(try TestCommand.parseAsRoot(["--generate-fig-spec"])) { error in
            let exitCode = TestCommand.exitCode(for: error)
            XCTAssertEqual(exitCode, .success, "Received a non-success exit code: \(exitCode)")
            let fullMessage = TestCommand.fullMessage(for: error)
            XCTAssertEqual(fullMessage, spec, "--generate-fig-spec should print exactly the value of generateFigSpec()")
        }
    }

    func testRootNoOptsNoGenerate() throws {
        let parsed = try TestCommand.parseAsRoot([])
        _ = try XCTUnwrap(parsed as? TestCommand, "Expected root command")
    }

    func testRootOptsNoGenerate() throws {
        let parsed = try TestCommand.parseAsRoot(["--my-option", "customValue"])
        let root = try XCTUnwrap(parsed as? TestCommand, "Expected root command")
        XCTAssertEqual(root.myOption, "customValue")
    }

    func testSubcommandNoGenerate() throws {
        let parsed = try TestCommand.parseAsRoot(["test-subcommand"])
        _ = try XCTUnwrap(parsed as? TestSubcommand, "Expected subcommand")
    }

}
