public struct AppConfig: Equatable, Codable, Hashable {
    public var coffeeConfig: CoffeeConfig
    public var globalConfig: GlobalConfig

    public init(_ coffeeConfig: CoffeeConfig, _ globalConfig: GlobalConfig) {
        self.coffeeConfig = coffeeConfig
        self.globalConfig = globalConfig
    }
}

extension AppConfig {
    public static func defaultValue() -> Self {
        AppConfig(CoffeeConfig.defaultValue(), GlobalConfig.defaultValue())
    }

    public func totalWaterAmountG() -> Double {
        roundCentesimal(Double(self.globalConfig.coffeeBeansWeightMg) / 1000 * self.coffeeConfig.waterToCoffeeBeansWeightRatio)
    }

    public func fortyPercentWaterAmountG() -> Double {
        roundCentesimal(self.totalWaterAmountG() * 0.4)
    }
}
