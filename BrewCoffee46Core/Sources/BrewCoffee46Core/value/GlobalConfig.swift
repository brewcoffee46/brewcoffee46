import Foundation

public struct GlobalConfig: Equatable, Hashable {
    public var coffeeBeansWeightMg: MilliGram

    // Use HARIO Switch-specific controls and timings.
    public var useSwitch: Bool

    public let version: Int

    enum CodingKeys: String, CodingKey {
        case coffeeBeansWeightMg
        case useSwitch
        case version
    }

    public init(
        _ coffeeBeansWeightMg: MilliGram,
        _ useSwitch: Bool = false,
        _ version: Int = GlobalConfig.currentVersion
    ) {
        self.coffeeBeansWeightMg = coffeeBeansWeightMg
        self.useSwitch = useSwitch
        self.version = version
    }

}

extension GlobalConfig: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coffeeBeansWeightMg = try values.decode(MilliGram.self, forKey: .coffeeBeansWeightMg)
        useSwitch = try values.decodeIfPresent(Bool.self, forKey: .useSwitch) ?? false
        version = try values.decode(Int.self, forKey: .version)
    }
}

extension GlobalConfig: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coffeeBeansWeightMg, forKey: .coffeeBeansWeightMg)
        try container.encode(useSwitch, forKey: .useSwitch)
        try container.encode(version, forKey: .version)
    }
}

extension GlobalConfig {
    public static let currentVersion: Int = 1
    public static let initCoffeeBeansWeightMg: UInt64 = 30_000

    public static func defaultValue() -> GlobalConfig {
        GlobalConfig(GlobalConfig.initCoffeeBeansWeightMg)
    }

    public var coffeeBeansWeightG: Double {
        Double(coffeeBeansWeightMg) / 1000.0
    }
}
