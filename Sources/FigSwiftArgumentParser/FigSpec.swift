import Foundation

struct FigSpec: Encodable {
    enum Template: String, Encodable {
        case filepaths
        case folders
        case history
    }

    enum SuggestionKind: String, Encodable {
        case folder
        case file
        case arg
        case subcommand
        case option
        case special
        case shortcut
    }

    enum Icon: Encodable {
        // pre-defined icon or file extension
        struct Preset: ExpressibleByStringLiteral {
            var rawValue: String
            init(rawValue: String) {
                self.rawValue = rawValue
            }
            init(stringLiteral value: String) {
                self.rawValue = value
            }
            static let alert: Preset = "alert"
            static let android: Preset = "android"
            static let apple: Preset = "apple"
            static let asterisk: Preset = "asterisk"
            static let aws: Preset = "aws"
            static let azure: Preset = "azure"
            static let box: Preset = "box"
            static let carrot: Preset = "carrot"
            static let characters: Preset = "characters"
            static let command: Preset = "command"
            static let commandkey: Preset = "commandkey"
            static let commit: Preset = "commit"
            static let database: Preset = "database"
            static let docker: Preset = "docker"
            static let firebase: Preset = "firebase"
            static let gcloud: Preset = "gcloud"
            static let git: Preset = "git"
            static let github: Preset = "github"
            static let gitlab: Preset = "gitlab"
            static let gradle: Preset = "gradle"
            static let heroku: Preset = "heroku"
            static let invite: Preset = "invite"
            static let kubernetes: Preset = "kubernetes"
            static let netlify: Preset = "netlify"
            static let node: Preset = "node"
            static let npm: Preset = "npm"
            static let option: Preset = "option"
            static let package: Preset = "package"
            static let slack: Preset = "slack"
            static let string: Preset = "string"
            static let twitter: Preset = "twitter"
            static let vercel: Preset = "vercel"
            static let yarn: Preset = "yarn"
        }

        struct Overlay {
            var colorHex: String?
            var badge: String?

            func apply(to components: inout URLComponents) {
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

        var rawValue: String? {
            switch self {
            case .character(let c):
                return "\(c)"
            case let .path(url, overlay):
                var components = URLComponents()
                components.scheme = "fig"
                components.path = url.path
                overlay?.apply(to: &components)
                return components.url?.absoluteString
            case let .preset(preset, overlay):
                var components = URLComponents()
                components.scheme = "fig"
                components.path = "icon"
                components.queryItems = [URLQueryItem(name: "type", value: preset.rawValue)]
                overlay?.apply(to: &components)
                return components.url?.absoluteString
            case let .template(overlay):
                var components = URLComponents()
                components.scheme = "fig"
                components.path = "template"
                overlay.apply(to: &components)
                return components.url?.absoluteString
            }
        }

        func encode(to encoder: Encoder) throws {
            guard let rawValue = rawValue else {
                throw ErrorMessage("Could not encode icon \(self)")
            }
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }

    // .option/.flag arguments
    struct Option: Encodable {
        struct RepeatCount: Encodable, ExpressibleByIntegerLiteral {
            let value: UInt?
            private init(value: UInt?) {
                self.value = value
            }
            static let infinity = RepeatCount(value: nil)
            init(integerLiteral value: UInt) {
                self.value = value
            }
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                if let value = value {
                    try container.encode(value)
                } else {
                    try container.encode(true)
                }
            }
        }

        var names: [String]
        var arguments: [Argument]?
        var isPersistent: Bool?
        var isRequired: Bool?
        var requiresEquals: Bool?
        var repeatCount: RepeatCount?
        var exclusiveOn: [String]?
        var dependsOn: [String]?

        var displayName: String?
        var insertValue: String?
        var description: String?
        var icon: Icon?

        var priority: Double?
        var isDangerous: Bool?
        var isHidden: Bool?
        var isDeprecated: Bool?

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
    struct Argument: Encodable {
        struct ParserDirectives: Encodable {
            var alias: String?
        }

        var name: String?
        var description: String?
        var templates: [Template]?
        var `default`: String?
        var parserDirectives: ParserDirectives?

        var isDangerous: Bool?
        var isVariadic: Bool?
        var optionsCanBreakVariadicArg: Bool?
        var isOptional: Bool?
        var isCommand: Bool?
        var isScript: Bool?
        var debounce: Bool?

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

    struct Subcommand: Encodable {
        struct ParserDirectives: Encodable {
            var flagsArePosixNoncompliant: Bool?
        }

        var names: [String]
        var subcommands: [Subcommand]?
        var options: [Option]?
        var arguments: [Argument]?
        var parserDirectives: ParserDirectives?

        var displayName: String?
        var insertValue: String?
        var description: String?
        var icon: Icon?

        var priority: Double?
        var isDangerous: Bool?
        var isHidden: Bool?
        var isDeprecated: Bool?

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

    var root: Subcommand

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(root)
    }
}
