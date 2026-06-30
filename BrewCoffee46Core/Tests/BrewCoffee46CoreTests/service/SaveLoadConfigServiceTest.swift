import BrewCoffee46TestsShared
import FactoryKit
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
            switches: [],
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

    func testLoadCurrentConfigNormalizesSwitches() {
        var appConfig = AppConfig.defaultValue()
        appConfig.coffeeConfig.switches = []
        let normalizedSwitches: [Switch] = [.close, .open, .open, .open, .open]

        Container.shared.userDefaultsService.register {
            MockUserDefaultsService<AppConfig>(.success(.some(appConfig)))
        }
        Container.shared.normalizeSwitchesService.register {
            MockNormalizeSwitchesService(switches: normalizedSwitches, count: normalizedSwitches.count)
        }

        let sut = SaveLoadConfigServiceImpl()
        let actual = sut.loadCurrentConfig()

        XCTAssertTrue(actual.isSuccess())
        actual.forEach { loadedConfig in
            XCTAssertEqual(loadedConfig?.coffeeConfig.switches, normalizedSwitches)
        }
    }

    func testLoadAllNormalizesSwitches() {
        var config = CoffeeConfig.defaultValue()
        config.switches = []
        let normalizedSwitches: [Switch] = [.close, .open, .open, .open, .open]

        Container.shared.userDefaultsService.register {
            MockUserDefaultsService<[CoffeeConfig]>(.success(.some([config])))
        }
        Container.shared.normalizeSwitchesService.register {
            MockNormalizeSwitchesService(switches: normalizedSwitches, count: normalizedSwitches.count)
        }

        let sut = SaveLoadConfigServiceImpl()
        let actual = sut.loadAll()

        XCTAssertTrue(actual.isSuccess())
        actual.forEach { loadedConfigs in
            XCTAssertEqual(loadedConfigs?.first?.switches, normalizedSwitches)
        }
    }
}
