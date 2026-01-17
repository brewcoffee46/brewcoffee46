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

    func validate(config: Config) -> ResultNea<Void, CoffeeError> {
        dummyResult
    }
}

final class RawSettingConvertServiceTests: XCTestCase {
    let dummyValue = 99999.9
    let ms = [
        RawMill(name: "Comandante C60", value: "4.5")
    ]
    let initConfig = Config(
        coffeeBeansWeight: 11.8,
        partitionsCountOf6: 4.0,
        waterToCoffeeBeansWeightRatio: 15.9,
        firstWaterPercent: 0.5,
        totalTimeSec: 210.0,
        steamingTimeSec: 40.0,
        note: .none,
        beforeChecklist: [],
        editedAtMilliSec: BrewCoffee46TestsShared.epochTimeMillis,
        mills: [
            Mill(name: "Comandante C60", value: "4.5")
        ]
    )

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
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: false,
            waterAmount: dummyValue,
            waterToCoffeeBeansWeightRatio: 0.5,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: 11.8,
            mills: ms
        )
        let sut = RawSettingConvertServiceImpl()

        let actual = sut.toConfig(rawSetting, initConfig)

        XCTAssertTrue(actual.isSuccess())
        actual.forEach { config in
            XCTAssertEqual(config.coffeeBeansWeight, rawSetting.coffeeBeansWeight)
        }
    }

    func testConvertToOnCalculateCoffeeBeansWeightFromWaterIsTrue() {
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: true,
            waterAmount: 187.6,
            waterToCoffeeBeansWeightRatio: 0.5,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: dummyValue,
            mills: ms
        )
        let sut = RawSettingConvertServiceImpl()

        let actual = sut.toConfig(rawSetting, initConfig)

        XCTAssertTrue(actual.isSuccess())
        actual.forEach { config in
            XCTAssertEqual(config.totalWaterAmount(), rawSetting.waterAmount)
        }
    }

    func testConvertToAndConvertFrom() {
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: false,
            waterAmount: dummyValue,
            waterToCoffeeBeansWeightRatio: 0.5,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: 11.8,
            mills: ms
        )

        let sut = RawSettingConvertServiceImpl()

        let actual1 = sut.fromConfig(initConfig, rawSetting)
        let actual2 = sut.toConfig(actual1, initConfig)

        XCTAssertTrue(actual2.isSuccess())
        actual2.forEach { actualConfig in
            XCTAssertEqual(initConfig, actualConfig)
        }
    }

    func testWaterAmountOfConfigEqaulsToRawSettingWhenCalculateCoffeeBeansWeightFromWaterIsTrue() {
        let rawSetting = RawSetting(
            calculateCoffeeBeansWeightFromWater: true,
            waterAmount: 400.2,
            waterToCoffeeBeansWeightRatio: 14.6,
            firstWaterPercent: 210.0,
            partitionsCountOf6: 40.0,
            totalTimeSec: 210.0,
            steamingTimeSec: 40.0,
            coffeeBeansWeight: 27.4,
            mills: ms
        )

        let sut = RawSettingConvertServiceImpl()

        let actual1 = sut.toConfig(rawSetting, initConfig)
        XCTAssertTrue(actual1.isSuccess())

        actual1.forEach { config in
            let actual2 = sut.fromConfig(config, rawSetting)
            XCTAssertEqual(actual2.waterAmount, rawSetting.waterAmount)
        }
    }
}
