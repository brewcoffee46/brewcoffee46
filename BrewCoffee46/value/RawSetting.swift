import BrewCoffee46Core
import Factory
import SwiftUI

/// # Input raw configuration data from `SettingView`.
struct RawSetting: Equatable {
    var calculateCoffeeBeansWeightFromWater: Bool
    var waterAmount: Double

    var waterToCoffeeBeansWeightRatio: Double
    var firstWaterPercent: Double
    var partitionsCountOf6: Double
    var totalTimeSec: Double
    var steamingTimeSec: Double
    var coffeeBeansWeight: Double

    init(
        calculateCoffeeBeansWeightFromWater: Bool = false,
        waterAmount: Double,
        waterToCoffeeBeansWeightRatio: Double,
        firstWaterPercent: Double,
        partitionsCountOf6: Double,
        totalTimeSec: Double,
        steamingTimeSec: Double,
        coffeeBeansWeight: Double
    ) {
        self.calculateCoffeeBeansWeightFromWater = calculateCoffeeBeansWeightFromWater
        self.waterAmount = waterAmount
        self.waterToCoffeeBeansWeightRatio = waterToCoffeeBeansWeightRatio
        self.firstWaterPercent = firstWaterPercent
        self.partitionsCountOf6 = partitionsCountOf6
        self.totalTimeSec = totalTimeSec
        self.steamingTimeSec = steamingTimeSec
        self.coffeeBeansWeight = coffeeBeansWeight
    }
}

extension RawSetting {
    static func defaultValue() -> RawSetting {
        let defaultConfig = BrewCoffee46Core.Config.defaultValue()

        return RawSetting(
            waterAmount: defaultConfig.totalWaterAmount(),
            waterToCoffeeBeansWeightRatio: defaultConfig.waterToCoffeeBeansWeightRatio,
            firstWaterPercent: defaultConfig.firstWaterPercent,
            partitionsCountOf6: defaultConfig.partitionsCountOf6,
            totalTimeSec: defaultConfig.totalTimeSec,
            steamingTimeSec: defaultConfig.steamingTimeSec,
            coffeeBeansWeight: defaultConfig.coffeeBeansWeight
        )
    }
}
