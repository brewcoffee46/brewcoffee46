import BrewCoffee46Core
import Factory
import SwiftUI

@MainActor
final class CurrentConfigViewModel: ObservableObject {
    @Injected(\.calculateDripInfoService) private var calculateDripInfoService

    @Published var currentConfig: Config = Config.defaultValue() {
        didSet {
            dripInfo = calculateDripInfoService.calculate(currentConfig)
        }
    }
    @Published var currentConfigLastUpdatedAt: UInt64? = .none
    @Published var dripInfo: DripInfo = DripInfo.defaultValue()
    @Published var errors: String = ""

    init() {}

    init(_ config: Config) {
        currentConfig = config
    }
}
