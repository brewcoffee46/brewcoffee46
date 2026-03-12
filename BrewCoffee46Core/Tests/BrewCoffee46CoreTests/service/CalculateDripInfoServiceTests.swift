import BrewCoffee46TestsShared
import Factory
import XCTest

@testable import BrewCoffee46Core

final class CalculateDripInfoServiceTests: XCTestCase {
    let sut = CalculateDripInfoServiceImpl()

    final class MockCalculateWaterAmountService: CalculateWaterAmountService, @unchecked Sendable {
        let expectedWaterAmount: WaterAmount

        init(_ waterAmount: WaterAmount) {
            expectedWaterAmount = waterAmount
        }

        func calculate(_ config: AppConfig) -> WaterAmount {
            return expectedWaterAmount
        }
    }

    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    @MainActor
    func test_calculate_if_water_amount_splits_into_5_successfully() throws {
        let mockCalculateWaterAmountService = MockCalculateWaterAmountService(waterAmountDefaultValue)
        Container.shared.calculateWaterAmountService.register {
            mockCalculateWaterAmountService
        }

        let expected = DripInfo.defaultValue()

        let actual = sut.calculate(AppConfig.defaultValue())

        XCTAssertEqual(actual, expected)
    }

    @MainActor
    func test_calculate_when_the_first_water_amount_is_100_percent_successfully() throws {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.firstWaterPercent = 1.0
        let mockCalculateWaterAmountService = MockCalculateWaterAmountService(waterAmountFirstIs100Percent)

        Container.shared.calculateWaterAmountService.register {
            mockCalculateWaterAmountService
        }

        let actual = sut.calculate(config)

        XCTAssertEqual(actual, dripInfoFirstIs100Percent)
    }

    @MainActor
    func test_calculate_when_the_number_of_sixty_percent_is_1() throws {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.firstWaterPercent = 1.0
        config.coffeeConfig.partitionsCountOf6 = 1
        let mockCalculateWaterAmountService = MockCalculateWaterAmountService(waterAmountFirstIs100PercentSixtyIs1)

        Container.shared.calculateWaterAmountService.register {
            mockCalculateWaterAmountService
        }

        let actual = sut.calculate(config)

        XCTAssertEqual(actual, dripInfoFirstIs100PercentSixtyIs1)
    }
}
