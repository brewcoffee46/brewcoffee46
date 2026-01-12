public struct Mill: Equatable {
    public let version: Int

    public let name: String

    public let value: String

    enum CodingKeys: String, CodingKey {
        case name
        case value
        case version
    }

    public init(
        name: String,
        value: String,
        version: Int = Mill.currentVersion
    ) {
        self.name = name
        self.value = value
        self.version = version
    }
}

extension Mill {
    public static let currentVersion: Int = 1
}

extension Mill: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        value = try values.decode(String.self, forKey: .value)
        version = try values.decode(Int.self, forKey: .version)
    }
}

extension Mill: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(version, forKey: .version)
    }
}

extension Mill: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(version)
    }
}
