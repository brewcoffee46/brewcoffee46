import BrewCoffee46Core
import Factory
import SwiftUI

@MainActor
final class CurrentConfigViewModel: ObservableObject {
    @Injected(\.calculateDripInfoService) private var calculateDripInfoService
    @Injected(\.saveLoadConfigService) private var saveLoadConfigService

    @Published var currentConfig: Config = Config.defaultValue() {
        didSet {
            dripInfo = calculateDripInfoService.calculate(currentConfig)
        }
    }
    @Published var currentConfigLastUpdatedAt: UInt64? = .none
    @Published var dripInfo: DripInfo = DripInfo.defaultValue()
    @Published var errors: String = ""

    init() {
        saveLoadConfigService
            .loadCurrentConfig()
            .map { $0.map { currentConfig = $0 } }
            .recoverWithErrorLog(&errors)
    }

    init(_ config: Config) {
        currentConfig = config
    }
}
