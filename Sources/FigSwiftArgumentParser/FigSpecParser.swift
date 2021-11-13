import Foundation
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

private extension FigSpec {
    init(toolInfo: ToolInfoV0) throws {
        root = try .init(commandInfo: toolInfo.command)
    }
}

private extension FigSpec.Subcommand {
    init(commandInfo: CommandInfoV0) throws {
        names = [commandInfo.commandName]
        description = commandInfo.abstract
        subcommands = try commandInfo.subcommands?.map(FigSpec.Subcommand.init(commandInfo:))
        arguments = try commandInfo.arguments?.filter { $0.kind == .positional }.nonEmpty?.map(FigSpec.Argument.init(argumentInfo:))
        options = try commandInfo.arguments?.filter { $0.kind != .positional }.nonEmpty?.map(FigSpec.Option.init(argumentInfo:))
    }
}

private extension FigSpec.Argument {
    init(argumentInfo: ArgumentInfoV0) throws {
        name = argumentInfo.valueName
        description = argumentInfo.abstract
        `default` = argumentInfo.defaultValue
        isVariadic = argumentInfo.isRepeating ? true : nil
        isOptional = argumentInfo.isOptional ? true : nil
    }
}

private extension FigSpec.Option {
    init(argumentInfo: ArgumentInfoV0) throws {
        names = (argumentInfo.names ?? []).map(\.formattedName)
        if let preferred = argumentInfo.preferredName {
            // move the preferred name to the front
            names.removeAll { $0 == preferred.formattedName }
            names.insert(preferred.formattedName, at: 0)
        }
        description = argumentInfo.discussion
        // TODO: ArgumentInfoV0.isOptional doesn't seem to be accurate
//        isRequired = argumentInfo.isOptional ? nil : true
        isHidden = argumentInfo.shouldDisplay ? nil : true
        repeatCount = argumentInfo.isRepeating ? .infinity : nil
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
