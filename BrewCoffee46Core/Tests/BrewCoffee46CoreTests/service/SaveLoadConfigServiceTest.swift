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
        let config = CoffeeConfig(
            partitionsCountOf6: 3,
            waterToCoffeeBeansWeightRatio: CoffeeConfig.initWaterToCoffeeBeansWeightRatio,
            firstWaterPercent: 0.5,
            totalTimeMilliSec: 210_000,
            steamingTimeMilliSec: 45_000,
            note: "",
            beforeChecklist: CoffeeConfig.initBeforeCheckList,
            editedAtMilliSec: .none,
            version: CoffeeConfig.currentVersion,
        )
        let globalConfig = GlobalConfig.defaultValue()
        let appConfig = AppConfig(config, globalConfig)

        let mockUserDefaultsService = MockUserDefaultsService<AppConfig>(successResult)
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadConfigServiceImpl()

        let actual = sut.saveCurrentConfig(appConfig)
        XCTAssertTrue(actual.isSuccess())
        XCTAssertEqual(mockUserDefaultsService.inputValues, [appConfig])
    }
}
