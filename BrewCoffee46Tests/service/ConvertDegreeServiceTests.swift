import BrewCoffee46Core
import BrewCoffee46TestsShared
import XCTest

@testable import BrewCoffee46

@MainActor
final class ConvertDegreeServiceTests: XCTestCase {
    let epsilon = 0.0001
    @MainActor
    let dripInfo = dripInfoDefaultValue
    let pointerInfo = PointerInfo(dripInfoDefaultValue)

    let sut = ConvertDegreeServiceImpl()

    func test_toProgressTime_and_fromProgressTime() throws {
        for d in 0..<360 {
            for f in 0..<9 {
                let degree = Double(d) + (Double(f) / 10)

                let progressTime = sut.toProgressTime(Config.defaultValue(), pointerInfo, dripInfo, degree)
                let actual = sut.fromProgressTime(Config.defaultValue(), pointerInfo, dripInfo, progressTime)

                XCTAssertEqual(actual, degree, accuracy: epsilon)
            }
        }
    }

    func test_fromProgressTime_and_toProgressTime() throws {
        for d in 0..<Int(Config.defaultValue().totalTimeSec) {
            for f in 0..<9 {
                let progressTime = Double(d) + (Double(f) / 10)

                let degree = sut.fromProgressTime(Config.defaultValue(), pointerInfo, dripInfo, progressTime)
                let actual = sut.toProgressTime(Config.defaultValue(), pointerInfo, dripInfo, degree)

                XCTAssertEqual(actual, progressTime, accuracy: epsilon)
            }
        }
    }

    func test_dripAt_degree_toProgressTime_toDegree_when_the_first_water_percent_is_99() throws {
        var config = Config.defaultValue()
        config.coffeeBeansWeight = 24
        config.waterToCoffeeBeansWeightRatio = 7
        config.firstWaterPercent = 0.99
        let dripInfo = DripInfo(
            dripTimings: [
                DripTiming(waterAmount: 66.528, dripAt: 0.0),
                DripTiming(waterAmount: 67.2, dripAt: 45.0),
                DripTiming(waterAmount: 100.8, dripAt: 86.25),
                DripTiming(waterAmount: 134.4, dripAt: 127.5),
                DripTiming(waterAmount: 168.0, dripAt: 168.75),
            ],
            waterAmount: waterAmountDefaultValue,
            totalTimeSec: Config.defaultValue().totalTimeSec
        )
        let pointerInfo = PointerInfo([0.0, 142.56, 144.0, 216.0, 288.0])

        for (degree, dripTiming) in zip(pointerInfo.pointerDegrees, dripInfo.dripTimings) {
            XCTAssertEqual(sut.toProgressTime(config, pointerInfo, dripInfo, degree), dripTiming.dripAt, accuracy: epsilon)
            XCTAssertEqual(sut.fromProgressTime(config, pointerInfo, dripInfo, dripTiming.dripAt), degree, accuracy: epsilon)
        }
    }

    func test_dripAt_degree_toProgressTime_toDegree_when_40_percent_at_1_shot() throws {
        var config = Config.defaultValue()
        config.coffeeBeansWeight = 24
        config.waterToCoffeeBeansWeightRatio = 7
        config.firstWaterPercent = 1
        let dripInfo = DripInfo(
            dripTimings: [
                DripTiming(waterAmount: 67.2, dripAt: 0.0),
                DripTiming(waterAmount: 100.8, dripAt: 45.0),
                DripTiming(waterAmount: 134.4, dripAt: 100.0),
                DripTiming(waterAmount: 168.0, dripAt: 155.0),
            ],
            waterAmount: waterAmountDefaultValue,
            totalTimeSec: Config.defaultValue().totalTimeSec
        )
        let pointerInfo = PointerInfo([0.0, 144.0, 216.0, 288.0])

        for (degree, dripTiming) in zip(pointerInfo.pointerDegrees, dripInfo.dripTimings) {
            XCTAssertEqual(sut.toProgressTime(config, pointerInfo, dripInfo, degree), dripTiming.dripAt, accuracy: epsilon)
            XCTAssertEqual(sut.fromProgressTime(config, pointerInfo, dripInfo, dripTiming.dripAt), degree, accuracy: epsilon)
        }
    }
}
