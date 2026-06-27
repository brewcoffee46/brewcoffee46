import BrewCoffee46TestsShared
import FactoryKit
import XCTest

@testable import BrewCoffee46Core

final class ValidateInputServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    let mockDefaultNormalizeSwitchesService = MockNormalizeSwitchesService(
        switches: CoffeeConfig.defaultValue().switches,
        count: CoffeeConfig.defaultValue().switches.count
    )

    func test_the_input_coffeebeans_weight_is_less_than_or_equal_0() throws {
        Container.shared.normalizeSwitchesService.register {
            self.mockDefaultNormalizeSwitchesService
        }
        let sut = ValidateInputServiceImpl()

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
        // Even though `normalizeSwitchesService` returns OK.
        Container.shared.normalizeSwitchesService.register {
            self.mockDefaultNormalizeSwitchesService
        }
        let sut = ValidateInputServiceImpl()

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.partitionsCountOf6IsNeededAtLeastOne))
        }
    }

    func test_total_time_must_be_longer_than_steaming_time() {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.totalTimeMilliSec = 10_000

        Container.shared.normalizeSwitchesService.register {
            self.mockDefaultNormalizeSwitchesService
        }
        let sut = ValidateInputServiceImpl()

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.steamingTimeIsTooMuchThanTotal))
        }
    }

    func test_the_first_water_percent_is_more_than_0() {
        var config = AppConfig.defaultValue()
        config.coffeeConfig.firstWaterPercent = 0

        Container.shared.normalizeSwitchesService.register {
            self.mockDefaultNormalizeSwitchesService
        }
        let sut = ValidateInputServiceImpl()

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error, NonEmptyArray(CoffeeError.firstWaterPercentIsZeroError))
        }
    }

    func test_the_number_of_switches_must_match_expected_count() {
        let config = AppConfig.defaultValue()
        Container.shared.normalizeSwitchesService.register {
            MockNormalizeSwitchesService(
                switches: config.coffeeConfig.switches,
                count: config.coffeeConfig.switches.count + 1
            )
        }
        let sut = ValidateInputServiceImpl()

        let actual = sut.validate(config)
        XCTAssert(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error.head, CoffeeError.numberOfSwitchesIsInvalid)
        }
    }
}
