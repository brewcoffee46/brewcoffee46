import BrewCoffee46Core
import Factory

/// # Provide both converters `RawSetting` to `Config` and its inverse.
protocol RawSettingConvertService: Sendable {
    func toConfig(
        _ rawSetting: RawSetting,
        _ appConfig: AppConfig
    ) -> ResultNea<AppConfig, CoffeeError>

    func fromConfig(
        _ appConfig: AppConfig,
        _ previousRawSetting: RawSetting,
    ) -> RawSetting
}

final class RawSettingConvertServiceImpl: RawSettingConvertService {
    private let validateInputService = Container.shared.validateInputService()
    private let dateService = Container.shared.dateService()

    func toConfig(
        _ rawSetting: RawSetting,
        _ appConfig: AppConfig
    ) -> ResultNea<AppConfig, CoffeeError> {
        let coffeeBeansWeight =
            if rawSetting.calculateCoffeeBeansWeightFromWater {
                roundCentesimal(rawSetting.waterAmount / rawSetting.waterToCoffeeBeansWeightRatio)
            } else {
                rawSetting.coffeeBeansWeight
            }

        let config = CoffeeConfig(
            partitionsCountOf6: Int(rawSetting.partitionsCountOf6),
            waterToCoffeeBeansWeightRatio: rawSetting.waterToCoffeeBeansWeightRatio,
            firstWaterPercent: rawSetting.firstWaterPercent,
            totalTimeMilliSec: MilliSecond.fromSecond(rawSetting.totalTimeSec),
            steamingTimeMilliSec: MilliSecond.fromSecond(rawSetting.steamingTimeSec),
            note: appConfig.coffeeConfig.note,
            beforeChecklist: appConfig.coffeeConfig.beforeChecklist,
            editedAtMilliSec: dateService.nowEpochTimeMillis(),
            mills: rawSetting.mills.map { mill in
                Mill(name: mill.name, value: mill.value)
            }
        )
        let globalConfig = GlobalConfig(MilliGram.fromGram(coffeeBeansWeight))
        let appConfig = AppConfig(config, globalConfig)

        return validateInputService.validate(appConfig).map { () in appConfig }
    }

    func fromConfig(
        _ appConfig: AppConfig,
        _ previousRawSetting: RawSetting,
    ) -> RawSetting {
        let waterAmount =
            if previousRawSetting.calculateCoffeeBeansWeightFromWater {
                previousRawSetting.waterAmount
            } else {
                appConfig.totalWaterAmountG()
            }

        return RawSetting(
            calculateCoffeeBeansWeightFromWater: previousRawSetting.calculateCoffeeBeansWeightFromWater,
            waterAmount: waterAmount,
            waterToCoffeeBeansWeightRatio: appConfig.coffeeConfig.waterToCoffeeBeansWeightRatio,
            firstWaterPercent: appConfig.coffeeConfig.firstWaterPercent,
            partitionsCountOf6: Double(appConfig.coffeeConfig.partitionsCountOf6),
            totalTimeSec: appConfig.coffeeConfig.totalTimeSec,
            steamingTimeSec: appConfig.coffeeConfig.steamingTimeSec,
            coffeeBeansWeight: appConfig.globalConfig.coffeeBeansWeightMg.gram,
            mills: appConfig.coffeeConfig.mills.map { mill in
                RawMill(name: mill.name, value: mill.value)
            }
        )
    }
}

extension Container {
    var rawSettingConvertService: Factory<RawSettingConvertService> {
        Factory(self) { RawSettingConvertServiceImpl() }
    }
}
