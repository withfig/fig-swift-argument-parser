import Foundation
import FigUtils

public struct FigSpec: Encodable {
    public enum Template: String, Encodable {
        case filepaths
        case folders
        case history
    }

    public enum SuggestionKind: String, Encodable {
        case folder
        case file
        case arg
        case subcommand
        case option
        case special
        case shortcut
    }

    public enum Icon: Encodable {
        // pre-defined icon or file extension
        public struct Preset: ExpressibleByStringLiteral {
            public var rawValue: String
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            public init(stringLiteral value: String) {
                self.rawValue = value
            }
            public static let alert: Preset = "alert"
            public static let android: Preset = "android"
            public static let apple: Preset = "apple"
            public static let asterisk: Preset = "asterisk"
            public static let aws: Preset = "aws"
            public static let azure: Preset = "azure"
            public static let box: Preset = "box"
            public static let carrot: Preset = "carrot"
            public static let characters: Preset = "characters"
            public static let command: Preset = "command"
            public static let commandkey: Preset = "commandkey"
            public static let commit: Preset = "commit"
            public static let database: Preset = "database"
            public static let docker: Preset = "docker"
            public static let firebase: Preset = "firebase"
            public static let gcloud: Preset = "gcloud"
            public static let git: Preset = "git"
            public static let github: Preset = "github"
            public static let gitlab: Preset = "gitlab"
            public static let gradle: Preset = "gradle"
            public static let heroku: Preset = "heroku"
            public static let invite: Preset = "invite"
            public static let kubernetes: Preset = "kubernetes"
            public static let netlify: Preset = "netlify"
            public static let node: Preset = "node"
            public static let npm: Preset = "npm"
            public static let option: Preset = "option"
            public static let package: Preset = "package"
            public static let slack: Preset = "slack"
            public static let string: Preset = "string"
            public static let twitter: Preset = "twitter"
            public static let vercel: Preset = "vercel"
            public static let yarn: Preset = "yarn"
        }

        public struct Overlay {
            public var colorHex: String?
            public var badge: String?

            public init(colorHex: String? = nil, badge: String? = nil) {
                self.colorHex = colorHex
                self.badge = badge
            }

            public func apply(to components: inout URLComponents) {
                var queryItems: [URLQueryItem] = []
                if let colorHex = colorHex {
                    queryItems.append(URLQueryItem(name: "color", value: colorHex))
                }
                if let badge = badge {
                    queryItems.append(URLQueryItem(name: "badge", value: badge))
                }
                guard !queryItems.isEmpty else { return }
                components.queryItems = (components.queryItems ?? []) + queryItems
            }
        }

        case character(Character)
        case path(URL, Overlay?)
        case preset(Preset, Overlay?)
        case template(Overlay)

        private func buildFigURL(_ builder: (inout URLComponents) throws -> Void) rethrows -> String? {
            var components = URLComponents()
            components.scheme = "fig"
            try builder(&components)
            return components.url?.absoluteString
        }

        public var rawValue: String? {
            switch self {
            case .character(let c):
                return "\(c)"
            case let .path(url, overlay):
                return buildFigURL { components in
                    components.path = url.path
                    overlay?.apply(to: &components)
                }
            case let .preset(preset, overlay):
                return buildFigURL { components in
                    components.path = "icon"
                    components.queryItems = [URLQueryItem(name: "type", value: preset.rawValue)]
                    overlay?.apply(to: &components)
                }
            case let .template(overlay):
                return buildFigURL { components in
                    components.path = "template"
                    overlay.apply(to: &components)
                }
            }
        }

        public func encode(to encoder: Encoder) throws {
            guard let rawValue = rawValue else {
                throw ErrorMessage("Could not encode icon \(self)")
            }
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }

    // .option/.flag arguments
    public struct Option: Encodable {
        public struct RepeatCount: Encodable, ExpressibleByIntegerLiteral, Hashable {
            public let value: UInt?
            init(value: UInt?) {
                self.value = value
            }
            public static let infinity = RepeatCount(value: nil)
            public init(integerLiteral value: UInt) {
                self.value = value
            }
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                if let value = value {
                    try container.encode(value)
                } else {
                    try container.encode(true)
                }
            }
        }

        public var names: [String]
        public var arguments: [Argument]?
        public var isPersistent: Bool?
        public var isRequired: Bool?
        public var requiresEquals: Bool?
        public var repeatCount: RepeatCount?
        public var exclusiveOn: [String]?
        public var dependsOn: [String]?

        public var displayName: String?
        public var insertValue: String?
        public var description: String?
        public var icon: Icon?

        public var priority: Double?
        public var isDangerous: Bool?
        public var isHidden: Bool?
        public var isDeprecated: Bool?

        public init(
            names: [String],
            arguments: [FigSpec.Argument]? = nil,
            isPersistent: Bool? = nil,
            isRequired: Bool? = nil,
            requiresEquals: Bool? = nil,
            repeatCount: FigSpec.Option.RepeatCount? = nil,
            exclusiveOn: [String]? = nil,
            dependsOn: [String]? = nil,
            displayName: String? = nil,
            insertValue: String? = nil,
            description: String? = nil,
            icon: FigSpec.Icon? = nil,
            priority: Double? = nil,
            isDangerous: Bool? = nil,
            isHidden: Bool? = nil,
            isDeprecated: Bool? = nil
        ) {
            self.names = names
            self.arguments = arguments
            self.isPersistent = isPersistent
            self.isRequired = isRequired
            self.requiresEquals = requiresEquals
            self.repeatCount = repeatCount
            self.exclusiveOn = exclusiveOn
            self.dependsOn = dependsOn
            self.displayName = displayName
            self.insertValue = insertValue
            self.description = description
            self.icon = icon
            self.priority = priority
            self.isDangerous = isDangerous
            self.isHidden = isHidden
            self.isDeprecated = isDeprecated
        }

        private enum CodingKeys: String, CodingKey {
            case names = "name"
            case arguments = "args"
            case isPersistent
            case isRequired
            case requiresEquals
            case repeatCount = "isRepeatable"
            case exclusiveOn
            case dependsOn

            case displayName
            case insertValue
            case description
            case icon

            case priority
            case isDangerous
            case isHidden = "hidden"
            case isDeprecated = "deprecated"
        }
    }

    // .positional arguments in ArgumentParser parlance
    public struct Argument: Encodable {
        public struct ParserDirectives: Encodable {
            public var alias: String?
        }

        public var name: String?
        public var description: String?
        public var templates: [Template]?
        public var `default`: String?
        public var parserDirectives: ParserDirectives?

        public var isDangerous: Bool?
        public var isVariadic: Bool?
        public var optionsCanBreakVariadicArg: Bool?
        public var isOptional: Bool?
        public var isCommand: Bool?
        public var isScript: Bool?
        public var debounce: Bool?

        public init(
            name: String? = nil,
            description: String? = nil,
            templates: [FigSpec.Template]? = nil,
            default: String? = nil,
            parserDirectives: FigSpec.Argument.ParserDirectives? = nil,
            isDangerous: Bool? = nil,
            isVariadic: Bool? = nil,
            optionsCanBreakVariadicArg: Bool? = nil,
            isOptional: Bool? = nil,
            isCommand: Bool? = nil,
            isScript: Bool? = nil,
            debounce: Bool? = nil
        ) {
            self.name = name
            self.description = description
            self.templates = templates
            self.default = `default`
            self.parserDirectives = parserDirectives
            self.isDangerous = isDangerous
            self.isVariadic = isVariadic
            self.optionsCanBreakVariadicArg = optionsCanBreakVariadicArg
            self.isOptional = isOptional
            self.isCommand = isCommand
            self.isScript = isScript
            self.debounce = debounce
        }

        private enum CodingKeys: String, CodingKey {
            case name
            case description
            case templates = "template"
            case `default`
            case parserDirectives

            case isDangerous
            case isVariadic
            case optionsCanBreakVariadicArg
            case isOptional
            case isCommand
            case isScript
            case debounce
        }
    }

    public struct Subcommand: Encodable {
        public struct ParserDirectives: Encodable {
            public var flagsArePosixNoncompliant: Bool?
        }

        public var names: [String]
        public var subcommands: [Subcommand]?
        public var options: [Option]?
        public var arguments: [Argument]?
        public var parserDirectives: ParserDirectives?

        public var displayName: String?
        public var insertValue: String?
        public var description: String?
        public var icon: Icon?

        public var priority: Double?
        public var isDangerous: Bool?
        public var isHidden: Bool?
        public var isDeprecated: Bool?

        public init(
            names: [String],
            subcommands: [FigSpec.Subcommand]? = nil,
            options: [FigSpec.Option]? = nil,
            arguments: [FigSpec.Argument]? = nil,
            parserDirectives: FigSpec.Subcommand.ParserDirectives? = nil,
            displayName: String? = nil,
            insertValue: String? = nil,
            description: String? = nil,
            icon: FigSpec.Icon? = nil,
            priority: Double? = nil,
            isDangerous: Bool? = nil,
            isHidden: Bool? = nil,
            isDeprecated: Bool? = nil
        ) {
            self.names = names
            self.subcommands = subcommands
            self.options = options
            self.arguments = arguments
            self.parserDirectives = parserDirectives
            self.displayName = displayName
            self.insertValue = insertValue
            self.description = description
            self.icon = icon
            self.priority = priority
            self.isDangerous = isDangerous
            self.isHidden = isHidden
            self.isDeprecated = isDeprecated
        }

        private enum CodingKeys: String, CodingKey {
            case names = "name"
            case subcommands
            case options
            case arguments = "args"
            case parserDirectives

            case displayName
            case insertValue
            case description
            case icon

            case priority
            case isDangerous
            case isHidden = "hidden"
            case isDeprecated = "deprecated"
        }
    }

    public var root: Subcommand

    public init(root: Subcommand) {
        self.root = root
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(root)
    }
}
