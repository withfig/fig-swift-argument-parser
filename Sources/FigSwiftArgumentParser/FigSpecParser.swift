import Foundation
import FigUtils
import FigSchema
import ArgumentParserToolInfo

fileprivate extension Collection {
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

extension FigSpec {
    init(toolInfo: ToolInfoV0) throws {
        self.init(
            root: try .init(commandInfo: toolInfo.command)
        )
    }
}

extension FigSpec.Subcommand {
    init(commandInfo: CommandInfoV0) throws {
        self.init(
            names: [commandInfo.commandName],
            subcommands: try commandInfo.subcommands?
                .map(FigSpec.Subcommand.init(commandInfo:)),
            options: try commandInfo.arguments?
                .filter { $0.kind != .positional }
                .nonEmpty?
                .map(FigSpec.Option.init(argumentInfo:)),
            arguments: try commandInfo.arguments?
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
        self.init(
            names: (argumentInfo.names ?? []).map(\.formattedName),
            // TODO: ArgumentInfoV0.isOptional doesn't seem to be accurate
//            isRequired: argumentInfo.isOptional ? nil : true,
            repeatCount: argumentInfo.isRepeating ? .infinity : nil,
            description: argumentInfo.discussion,
            isHidden: argumentInfo.shouldDisplay ? nil : true
        )

        if let preferred = argumentInfo.preferredName {
            // move the preferred name to the front
            names.removeAll { $0 == preferred.formattedName }
            names.insert(preferred.formattedName, at: 0)
        }

        if argumentInfo.kind == .option {
            arguments = [
                .init(
                    name: argumentInfo.valueName,
                    default: argumentInfo.defaultValue
                )
            ]
        }
    }
}
