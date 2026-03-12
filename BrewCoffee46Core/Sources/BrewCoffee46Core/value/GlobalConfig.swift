import Foundation

public struct GlobalConfig: Equatable, Codable, Hashable {
    public var coffeeBeansWeightMg: MilliGram
    public let version: Int

    public init(
        _ coffeeBeansWeightMg: MilliGram,
        _ version: Int = GlobalConfig.currentVersion
    ) {
        self.coffeeBeansWeightMg = coffeeBeansWeightMg
        self.version = version
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
