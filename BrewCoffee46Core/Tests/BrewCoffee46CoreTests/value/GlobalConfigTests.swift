import XCTest

@testable import BrewCoffee46Core

final class GlobalConfigTests: XCTestCase {
    func testDecodeDefaultsUseSwitchToFalseWhenMissing() throws {
        let json = """
            {
                "coffeeBeansWeightMg": 30000,
                "version": 1
            }
            """.data(using: .utf8)!

        let actual = try JSONDecoder().decode(GlobalConfig.self, from: json)

        XCTAssertEqual(actual.coffeeBeansWeightMg, 30_000)
        XCTAssertFalse(actual.useSwitch)
        XCTAssertEqual(actual.version, 1)
    }

    func testDecodeUsesUseSwitchWhenPresent() throws {
        let json = """
            {
                "coffeeBeansWeightMg": 30000,
                "useSwitch": true,
                "version": 1
            }
            """.data(using: .utf8)!

        let actual = try JSONDecoder().decode(GlobalConfig.self, from: json)

        XCTAssertTrue(actual.useSwitch)
    }
}
