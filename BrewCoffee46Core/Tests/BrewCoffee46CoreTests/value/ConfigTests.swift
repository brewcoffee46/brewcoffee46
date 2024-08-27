import BrewCoffee46TestsShared
import XCTest

@testable import BrewCoffee46Core

final class ConfigTests: XCTestCase {
    func testDecodeFromJsonWithoutBeforeChecklistSuccessfully() throws {
        let expected = Config(
            coffeeBeansWeight: 24,
            partitionsCountOf6: 3,
            waterToCoffeeBeansWeightRatio: 16,
            firstWaterPercent: 0.5,
            totalTimeSec: 210,
            steamingTimeSec: 45,
            note: "note",
            beforeChecklist: Config.initBeforeCheckList,
            editedAtMilliSec: .none,
            version: 1
        )
        let json = """
            {
                "waterToCoffeeBeansWeightRatio" : 16,
                "partitionsCountOf6" : 3,
                "coffeeBeansWeight" : 24,
                "version" : 1,
                "steamingTimeSec" : 45,
                "note" : "note",
                "firstWaterPercent" : 0.5,
                "totalTimeSec" : 210
            }
            """

        XCTAssertEqual(Config.fromJSON(json), .success(expected))
    }

    func testDecodeFromJsonSuccessfully() throws {
        let expected = Config(
            coffeeBeansWeight: 24,
            partitionsCountOf6: 3,
            waterToCoffeeBeansWeightRatio: 16,
            firstWaterPercent: 0.5,
            totalTimeSec: 210,
            steamingTimeSec: 45,
            note: "note",
            beforeChecklist: [
                "first",
                "second",
            ],
            editedAtMilliSec: .none,
            version: 1
        )
        let json = """
            {
                "waterToCoffeeBeansWeightRatio" : 16,
                "partitionsCountOf6" : 3,
                "coffeeBeansWeight" : 24,
                "version" : 1,
                "steamingTimeSec" : 45,
                "note" : "note",
                "firstWaterPercent" : 0.5,
                "beforeChecklist": [ "first", "second" ],
                "totalTimeSec" : 210
            }
            """

        XCTAssertEqual(Config.fromJSON(json), .success(expected))
    }

    func testDecodeFromJsonWithEditedAtMilliSecSuccessfully() throws {
        let expected = Config(
            coffeeBeansWeight: 24,
            partitionsCountOf6: 3,
            waterToCoffeeBeansWeightRatio: 16,
            firstWaterPercent: 0.5,
            totalTimeSec: 210,
            steamingTimeSec: 45,
            note: "note",
            beforeChecklist: [
                "first",
                "second",
            ],
            editedAtMilliSec: .some(epochTimeMillis),
            version: 1
        )
        let json = """
            {
                "waterToCoffeeBeansWeightRatio" : 16,
                "partitionsCountOf6" : 3,
                "coffeeBeansWeight" : 24,
                "version" : 1,
                "steamingTimeSec" : 45,
                "note" : "note",
                "firstWaterPercent" : 0.5,
                "beforeChecklist": [ "first", "second" ],
                "editedAtMilliSec": \(epochTimeMillis),
                "totalTimeSec" : 210
            }
            """

        XCTAssertEqual(Config.fromJSON(json), .success(expected))
    }
}
