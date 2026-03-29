import BrewCoffee46Core
import Factory
import SwiftUI

/// # Input raw configuration data from `SettingView`.
/// SwiftUI view (for example `Slider`) requires `Binding<Double>` rather than `Binding<Int>`
/// so `RawSetting` has some members whose type is `Double`.
struct RawSetting {
    var calculateCoffeeBeansWeightFromWater: Bool
    var waterAmount: Double
    var waterToCoffeeBeansWeightRatio: Double
    var firstWaterPercent: Double
    var partitionsCountOf6: Double
    var totalTimeSec: Double
    var steamingTimeSec: Double
    var coffeeBeansWeight: Double
    var mills: [RawMill]
    var editedAtMilliSec: MilliSecond?

    init(
        calculateCoffeeBeansWeightFromWater: Bool = false,
        waterAmount: Double,
        waterToCoffeeBeansWeightRatio: Double,
        firstWaterPercent: Double,
        partitionsCountOf6: Double,
        totalTimeSec: Double,
        steamingTimeSec: Double,
        coffeeBeansWeight: Double,
        editedAtMilliSec: MilliSecond?,
        mills: [RawMill]
    ) {
        self.calculateCoffeeBeansWeightFromWater = calculateCoffeeBeansWeightFromWater
        self.waterAmount = waterAmount
        self.waterToCoffeeBeansWeightRatio = waterToCoffeeBeansWeightRatio
        self.firstWaterPercent = firstWaterPercent
        self.partitionsCountOf6 = partitionsCountOf6
        self.totalTimeSec = totalTimeSec
        self.steamingTimeSec = steamingTimeSec
        self.coffeeBeansWeight = coffeeBeansWeight
        self.editedAtMilliSec = editedAtMilliSec
        self.mills = mills
    }
}

extension RawSetting {
    static func defaultValue() -> RawSetting {
        let defaultAppConfig = AppConfig.defaultValue()

        return RawSetting(
            waterAmount: defaultAppConfig.totalWaterAmountG(),
            waterToCoffeeBeansWeightRatio: defaultAppConfig.coffeeConfig.waterToCoffeeBeansWeightRatio,
            firstWaterPercent: defaultAppConfig.coffeeConfig.firstWaterPercent,
            partitionsCountOf6: Double(defaultAppConfig.coffeeConfig.partitionsCountOf6),
            totalTimeSec: defaultAppConfig.coffeeConfig.totalTimeSec,
            steamingTimeSec: defaultAppConfig.coffeeConfig.steamingTimeSec,
            coffeeBeansWeight: defaultAppConfig.globalConfig.coffeeBeansWeightG,
            editedAtMilliSec: defaultAppConfig.coffeeConfig.editedAtMilliSec,
            mills: defaultAppConfig.coffeeConfig.mills.map { mill in
                RawMill(name: mill.name, value: mill.value)
            }
        )
    }
}

extension RawSetting: Equatable {
    // `Equatable` instance of `RawSetting` does not contain equality of `editedAtMilliSec`
    // because synchronizing between `CoffeeConfig` & `RawSetting` maybe enter infinite loop to edit each other
    // so we want to stop that when these data are the same except `editedAtMilliSec`.
    static func == (lhs: RawSetting, rhs: RawSetting) -> Bool {
        return lhs.calculateCoffeeBeansWeightFromWater == rhs.calculateCoffeeBeansWeightFromWater
            && lhs.waterAmount == rhs.waterAmount
            && lhs.waterToCoffeeBeansWeightRatio == rhs.waterToCoffeeBeansWeightRatio
            && lhs.firstWaterPercent == rhs.firstWaterPercent
            && lhs.partitionsCountOf6 == rhs.partitionsCountOf6
            && lhs.totalTimeSec == rhs.totalTimeSec
            && lhs.steamingTimeSec == rhs.steamingTimeSec
            && lhs.coffeeBeansWeight == rhs.coffeeBeansWeight
            && lhs.mills == rhs.mills
    }
}
