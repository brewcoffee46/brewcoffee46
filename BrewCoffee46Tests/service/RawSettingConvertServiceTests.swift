import BrewCoffee46Core
import BrewCoffee46TestsShared
import Factory
import XCTest

@testable import BrewCoffee46

final class MockValidateInputService: ValidateInputService {
    let dummyResult: ResultNea<Void, CoffeeError>

    init(dummyResult: ResultNea<Void, CoffeeError>) {
        self.dummyResult = dummyResult
    }

    func validate(_ config: AppConfig) -> ResultNea<Void, CoffeeError> {
        dummyResult
    }
}

final class RawSettingConvertServiceTests: XCTestCase {
    let dummyValue = 99999.9
    let ms = [
        RawMill(name: "Comandante C60", value: "4.5")
    ]
    let initConfig = CoffeeConfig(
        partitionsCountOf6: 4,
        waterToCoffeeBeansWeightRatio: 15.9,
        firstWaterPercent: 0.5,
        totalTimeMilliSec: 210_000,
        steamingTimeMilliSec: 40_000,
        note: "",
        beforeChecklist: [],
        editedAtMilliSec: BrewCoffee46TestsShared.epochTimeMillis,
        mills: [
            Mill(name: "Comandante C60", value: "4.5")
        ]
    )
    let globalConfig = GlobalConfig(11_800)

    override class func setUp() {
        Container.shared.reset()
        let mockValidateInputService = MockValidateInputService(dummyResult: .success(()))
        Container.shared.validateInputService.register {
            mockValidateInputService
        }
        Container.shared.dateService.register {
            MockDateService()
        }
        super.setUp()
    }

    func testConvertToOnCalculateCoffeeBeansWeightFromWaterIsFalse() {
        let appConfig = AppConfig(initConfig, globalConfig)
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: false,
            waterAmount: dummyValue,
            waterToCoffeeBeansWeightRatio: 0.5,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: 11.8,
            editedAtMilliSec: BrewCoffee46TestsShared.epochTimeMillis,
            mills: ms
        )
        let sut = RawSettingConvertServiceImpl()

        let actual = sut.toConfig(rawSetting, appConfig)

        XCTAssertTrue(actual.isSuccess())
        actual.forEach { (config: AppConfig) in
            XCTAssertEqual(config.globalConfig.coffeeBeansWeightG, rawSetting.coffeeBeansWeight)
        }
    }

    func testConvertToOnCalculateCoffeeBeansWeightFromWaterIsTrue() {
        let appConfig = AppConfig(initConfig, globalConfig)
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: true,
            waterAmount: 187.6,
            waterToCoffeeBeansWeightRatio: 0.5,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: dummyValue,
            editedAtMilliSec: BrewCoffee46TestsShared.epochTimeMillis,
            mills: ms
        )
        let sut = RawSettingConvertServiceImpl()

        let actual = sut.toConfig(rawSetting, appConfig)

        XCTAssertTrue(actual.isSuccess())
        actual.forEach { (config: AppConfig) in
            XCTAssertEqual(config.totalWaterAmountG(), rawSetting.waterAmount)
        }
    }

    func testConvertToAndConvertFrom() {
        let appConfig = AppConfig(initConfig, globalConfig)
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: false,
            waterAmount: dummyValue,
            waterToCoffeeBeansWeightRatio: 0.5,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: 11.8,
            editedAtMilliSec: BrewCoffee46TestsShared.epochTimeMillis,
            mills: ms
        )

        let sut = RawSettingConvertServiceImpl()

        let actual1 = sut.fromConfig(appConfig, rawSetting)
        let actual2 = sut.toConfig(actual1, appConfig)

        XCTAssertTrue(actual2.isSuccess())
        actual2.forEach { actualConfig in
            XCTAssertEqual(appConfig, actualConfig)
        }
    }

    func testWaterAmountOfConfigEqaulsToRawSettingWhenCalculateCoffeeBeansWeightFromWaterIsTrue() {
        let appConfig = AppConfig(initConfig, globalConfig)
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: true,
            waterAmount: 400.2,
            waterToCoffeeBeansWeightRatio: 14.6,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: 27.4,
            editedAtMilliSec: BrewCoffee46TestsShared.epochTimeMillis,
            mills: ms
        )

        let sut = RawSettingConvertServiceImpl()

        let actual1 = sut.toConfig(rawSetting, appConfig)
        XCTAssertTrue(actual1.isSuccess())

        actual1.forEach { config in
            let actual2 = sut.fromConfig(config, rawSetting)
            XCTAssertEqual(actual2.waterAmount, rawSetting.waterAmount)
        }
    }
}
