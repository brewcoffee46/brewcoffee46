import XCTest

@testable import BrewCoffee46Core

final class ValidateInputServiceTests: XCTestCase {
    let sut = ValidateInputServiceImpl()

    func test_the_input_coffeebeans_weight_is_less_than_or_equal_0() throws {
        var config = AppConfig.defaultValue()
        config.globalConfig.coffeeBeansWeightMg = 0

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.coffeeBeansWeightUnderZeroError))
        }
    }

    func test_the_input_of_the_number_of_6_is_less_than_or_equal_0() throws {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.partitionsCountOf6 = 0

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.partitionsCountOf6IsNeededAtLeastOne))
        }
    }

    func test_total_time_must_be_longer_than_steaming_time() {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.totalTimeMilliSec = 10_000

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.steamingTimeIsTooMuchThanTotal))
        }
    }

    func test_the_first_water_percent_is_more_than_0() {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.firstWaterPercent = 0

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.firstWaterPercentIsZeroError))
        }
    }
}
