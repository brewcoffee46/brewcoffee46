import XCTest

@testable import BrewCoffee46Core

final class NormalizeSwitchesServiceTests: XCTestCase {
    let sut = NormalizeSwitchesServiceImpl()

    func testExpectedSwitchCount() {
        var coffeeConfig = CoffeeConfig.defaultValue()
        coffeeConfig.firstWaterPercent = 0.5
        coffeeConfig.partitionsCountOf6 = 3

        XCTAssertEqual(sut.expectedSwitchCount(coffeeConfig), 5)
    }

    func testExpectedSwitchCountWhenFirstWaterPercentIsOne() {
        var coffeeConfig = CoffeeConfig.defaultValue()
        coffeeConfig.firstWaterPercent = 1
        coffeeConfig.partitionsCountOf6 = 3

        XCTAssertEqual(sut.expectedSwitchCount(coffeeConfig), 4)
    }

    func testExpectedSwitchCountWhenFirstWaterPercentIsApproximatelyOne() {
        var coffeeConfig = CoffeeConfig.defaultValue()
        coffeeConfig.firstWaterPercent = 1.0000000000000002
        coffeeConfig.partitionsCountOf6 = 3

        XCTAssertEqual(sut.expectedSwitchCount(coffeeConfig), 4)
    }

    func testExpectedSwitchCountWhenFirstWaterPercentIsNotApproximatelyOne() {
        var coffeeConfig = CoffeeConfig.defaultValue()
        coffeeConfig.firstWaterPercent = 0.9900000000000003
        coffeeConfig.partitionsCountOf6 = 3

        XCTAssertEqual(sut.expectedSwitchCount(coffeeConfig), 5)
    }

    func testNormalizeAppendsOpenSwitchesWhenSwitchesAreShort() {
        var coffeeConfig = CoffeeConfig.defaultValue()
        coffeeConfig.firstWaterPercent = 0.5
        coffeeConfig.partitionsCountOf6 = 3
        coffeeConfig.switches = [.close, .open]

        XCTAssertEqual(sut.normalize(coffeeConfig), [.close, .open, .open, .open, .open])
    }

    func testNormalizeTruncatesExtraSwitches() {
        var coffeeConfig = CoffeeConfig.defaultValue()
        coffeeConfig.firstWaterPercent = 1
        coffeeConfig.partitionsCountOf6 = 3
        coffeeConfig.switches = [.close, .open, .close, .open, .close]

        XCTAssertEqual(sut.normalize(coffeeConfig), [.close, .open, .close, .open])
    }
}
