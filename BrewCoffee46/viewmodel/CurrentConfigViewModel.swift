import BrewCoffee46Core
import FactoryKit
import SwiftUI

@MainActor
final class CurrentConfigViewModel: ObservableObject {
    @Injected(\.calculateDripInfoService) private var calculateDripInfoService
    @Injected(\.dateService) private var dateService
    @Injected(\.saveLoadConfigService) private var saveLoadConfigService

    @Published var currentConfig: AppConfig = AppConfig.defaultValue() {
        didSet {
            dripInfo = calculateDripInfoService.calculate(currentConfig)
        }
    }
    @Published var dripInfo: DripInfo = DripInfo.defaultValue()
    @Published var errors: String = ""

    init() {
        saveLoadConfigService
            .loadCurrentConfig()
            .map { $0.map { currentConfig = $0 } }
            .recoverWithErrorLog(&errors)
    }

    init(_ config: AppConfig) {
        currentConfig = config
    }

    /// Edits `CoffeeConfig` and updates its timestamp when changed.
    func editCoffeeConfig(_ edit: (inout CoffeeConfig) -> Void) {
        var config = currentConfig
        edit(&config.coffeeConfig)
        applyUserEditedConfig(config)
    }

    /// Applies user input and updates the timestamp only when `CoffeeConfig` changed.
    /// The candidate timestamp is ignored; `GlobalConfig`-only changes preserve it.
    func applyUserEditedConfig(_ candidate: AppConfig) {
        var candidate = candidate
        let oldCoffeeConfig = currentConfig.coffeeConfig

        candidate.coffeeConfig.editedAtMilliSec = oldCoffeeConfig.editedAtMilliSec
        if candidate.coffeeConfig != oldCoffeeConfig {
            candidate.coffeeConfig.editedAtMilliSec = dateService.nowEpochTimeMillis()
        }

        guard candidate != currentConfig else { return }
        currentConfig = candidate
    }
}
