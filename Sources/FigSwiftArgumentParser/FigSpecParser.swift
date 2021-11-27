import ArgumentParserToolInfo
import FigSchema
import FigUtils
import Foundation

private extension Collection {
    var nonEmpty: Self? { isEmpty ? nil : self }
}

struct FigSpecParser {
    private static let decoder = JSONDecoder()

    func parse(data: Data) throws -> FigSpec {
        let header = try Self.decoder.decode(ToolInfoHeader.self, from: data)
        switch header.serializationVersion {
        case 0:
            return try FigSpec(
                toolInfo: Self.decoder.decode(ToolInfoV0.self, from: data)
            )
        default:
            throw ErrorMessage(
                "Unsupported swift-argument-parser serialization version: \(header.serializationVersion)"
            )
        }
    }
}

// MARK: - V0

private extension ArgumentInfoV0.NameInfoV0 {
    var formattedName: String {
        switch kind {
        case .long:
            return "--\(name)"
        case .longWithSingleDash, .short:
            // TODO: Set flagsArePosixNoncompliant if we see longWithSingleDash
            return "-\(name)"
        }
    }
}

public extension FigSpec {
    init(toolInfo: ToolInfoV0) throws {
        self.init(root: try FigSpec.Subcommand(commandInfo: toolInfo.command))
    }
}

public extension FigSpec.Subcommand {
    init(commandInfo: CommandInfoV0) throws {
        self.init(
            name: [commandInfo.commandName],
            subcommands: try commandInfo.subcommands?
                .map(FigSpec.Subcommand.init(commandInfo:)),
            options: try commandInfo.arguments?
                .filter { $0.kind != .positional }
                .nonEmpty?
                .map(FigSpec.Option.init(argumentInfo:)),
            args: try commandInfo.arguments?
                .filter { $0.kind == .positional }
                .nonEmpty?
                .map(FigSpec.Argument.init(argumentInfo:)),
            description: commandInfo.abstract
        )
    }
}

extension FigSpec.Argument {
    init(argumentInfo: ArgumentInfoV0) throws {
        self.init(
            name: argumentInfo.valueName,
            description: argumentInfo.abstract,
            default: argumentInfo.defaultValue,
            isVariadic: argumentInfo.isRepeating ? true : nil,
            isOptional: argumentInfo.isOptional ? true : nil
        )
    }
}

extension FigSpec.Option {
    init(argumentInfo: ArgumentInfoV0) throws {
        let formattedNames = (argumentInfo.names ?? []).map(\.formattedName)
        let isHelp = formattedNames.contains("--help")

        self.init(
            name: formattedNames,
            isRequired: isHelp || argumentInfo.isOptional ? nil : true,
            isRepeatable: argumentInfo.isRepeating ? .infinity : nil,
            description: argumentInfo.abstract,
            hidden: argumentInfo.shouldDisplay ? nil : true
        )

        if let preferred = argumentInfo.preferredName {
            // move the preferred name to the front
            name.removeAll { $0 == preferred.formattedName }
            name.insert(preferred.formattedName, at: 0)
        }

        if argumentInfo.kind == .option {
            args = [
                FigSpec.Argument(
                    name: argumentInfo.valueName,
                    default: argumentInfo.defaultValue
                ),
            ]
        }
    }
}
