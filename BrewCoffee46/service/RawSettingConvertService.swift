import BrewCoffee46Core
import Factory

/// # Provide both converters `RawSetting` to `Config` and its inverse.
protocol RawSettingConvertService: Sendable {
    func toConfig(_ rawSetting: RawSetting, _ currentConfig: Config) -> ResultNea<Config, CoffeeError>

    func fromConfig(_ config: Config, _ previousRawSetting: RawSetting) -> RawSetting
}

final class RawSettingConvertServiceImpl: RawSettingConvertService {
    private let validateInputService = Container.shared.validateInputService()
    private let dateService = Container.shared.dateService()

    func toConfig(_ rawSetting: RawSetting, _ currentConfig: Config) -> ResultNea<Config, CoffeeError> {
        let coffeeBeansWeight =
            if rawSetting.calculateCoffeeBeansWeightFromWater {
                roundCentesimal(rawSetting.waterAmount / rawSetting.waterToCoffeeBeansWeightRatio)
            } else {
                rawSetting.coffeeBeansWeight
            }

        let config = Config.init(
            coffeeBeansWeight: coffeeBeansWeight,
            partitionsCountOf6: rawSetting.partitionsCountOf6,
            waterToCoffeeBeansWeightRatio: rawSetting.waterToCoffeeBeansWeightRatio,
            firstWaterPercent: rawSetting.firstWaterPercent,
            totalTimeSec: rawSetting.totalTimeSec,
            steamingTimeSec: rawSetting.steamingTimeSec,
            note: currentConfig.note,
            beforeChecklist: currentConfig.beforeChecklist,
            editedAtMilliSec: dateService.nowEpochTimeMillis()
        )

        return validateInputService.validate(config: config).map { () in config }
    }

    func fromConfig(_ config: Config, _ previousRawSetting: RawSetting) -> RawSetting {
        let waterAmount =
            if previousRawSetting.calculateCoffeeBeansWeightFromWater {
                previousRawSetting.waterAmount
            } else {
                config.totalWaterAmount()
            }

        return RawSetting(
            calculateCoffeeBeansWeightFromWater: previousRawSetting.calculateCoffeeBeansWeightFromWater,
            waterAmount: waterAmount,
            waterToCoffeeBeansWeightRatio: config.waterToCoffeeBeansWeightRatio,
            firstWaterPercent: config.firstWaterPercent,
            partitionsCountOf6: config.partitionsCountOf6,
            totalTimeSec: config.totalTimeSec,
            steamingTimeSec: config.steamingTimeSec,
            coffeeBeansWeight: config.coffeeBeansWeight
        )
    }
}

extension Container {
    var rawSettingConvertService: Factory<RawSettingConvertService> {
        Factory(self) { RawSettingConvertServiceImpl() }
    }
}
