import BrewCoffee46Core
import BrewCoffee46TestsShared
import FactoryKit
import XCTest

@testable import BrewCoffee46

final class CurrentConfigViewModelTests: XCTestCase {
    let now: MilliSecond = 1_777_999_999_999

    override func setUp() {
        super.setUp()
        Container.shared.reset()
        let mockDateService = MockDateService(now.toDate())
        Container.shared.dateService.register { mockDateService }
    }

    @MainActor
    func testEditCoffeeConfigUpdatesEditedAt() {
        let viewModel = CurrentConfigViewModel(AppConfig.defaultValue())

        viewModel.editCoffeeConfig {
            $0.note = "updated"
        }

        XCTAssertEqual(viewModel.currentConfig.coffeeConfig.note, "updated")
        XCTAssertEqual(viewModel.currentConfig.coffeeConfig.editedAtMilliSec, now)
    }

    @MainActor
    func testApplyUserEditedConfigDoesNotUpdateEditedAtForGlobalConfigChange() {
        var initialConfig = AppConfig.defaultValue()
        initialConfig.coffeeConfig.editedAtMilliSec = 100
        let viewModel = CurrentConfigViewModel(initialConfig)
        var candidate = initialConfig
        candidate.globalConfig.coffeeBeansWeightMg += 1_000
        candidate.globalConfig.useSwitch.toggle()

        viewModel.applyUserEditedConfig(candidate)

        XCTAssertEqual(viewModel.currentConfig.globalConfig, candidate.globalConfig)
        XCTAssertEqual(viewModel.currentConfig.coffeeConfig.editedAtMilliSec, 100)
    }

    @MainActor
    func testApplyUserEditedConfigUpdatesEditedAtForCoffeeConfigChange() {
        var initialConfig = AppConfig.defaultValue()
        initialConfig.coffeeConfig.editedAtMilliSec = 100
        let viewModel = CurrentConfigViewModel(initialConfig)
        var candidate = initialConfig
        candidate.coffeeConfig.beforeChecklist.append("updated")

        viewModel.applyUserEditedConfig(candidate)

        XCTAssertEqual(viewModel.currentConfig.coffeeConfig.beforeChecklist, candidate.coffeeConfig.beforeChecklist)
        XCTAssertEqual(viewModel.currentConfig.coffeeConfig.editedAtMilliSec, now)
    }

    @MainActor
    func testApplyUserEditedConfigIgnoresEditedAtOnlyChange() {
        var initialConfig = AppConfig.defaultValue()
        initialConfig.coffeeConfig.editedAtMilliSec = 100
        let viewModel = CurrentConfigViewModel(initialConfig)
        var candidate = initialConfig
        candidate.coffeeConfig.editedAtMilliSec = 200

        viewModel.applyUserEditedConfig(candidate)

        XCTAssertEqual(viewModel.currentConfig, initialConfig)
    }
}
