import BrewCoffee46TestsShared
import Factory
import XCTest

@testable import BrewCoffee46Core

final class SaveLoadConfigServiceTests: XCTestCase {
    let successResult: ResultNea<Any?, CoffeeError> = .success(.some(epochTimeMillis))
    let now = epochTimeMillis.toDate()

    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    func testSaveCurrentConfigSuccessfully() {
        let config = Config(
            coffeeBeansWeight: Config.initCoffeeBeansWeight,
            partitionsCountOf6: 3,
            waterToCoffeeBeansWeightRatio: Config.initWaterToCoffeeBeansWeightRatio,
            firstWaterPercent: 0.5,
            totalTimeSec: 210,
            steamingTimeSec: 45,
            note: "",
            beforeChecklist: Config.initBeforeCheckList,
            editedAtMilliSec: .none,
            version: Config.currentVersion,
        )

        let mockUserDefaultsService = MockUserDefaultsService<Config>(successResult)
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadConfigServiceImpl()

        let actual = sut.saveCurrentConfig(config: config)
        XCTAssertTrue(actual.isSuccess())
        XCTAssertEqual(mockUserDefaultsService.inputValues, [config])
    }
}
