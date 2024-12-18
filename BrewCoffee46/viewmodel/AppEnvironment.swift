import BrewCoffee46Core
import Foundation
import SwiftUI

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var selectedTab: Route = .stopwatch
    @Published var isTimerStarted: Bool = false
    @Published var stopwatchPath: [Route] = []
    @Published var configPath: [Route] = []
    @Published var beforeChecklistPath: [Route] = []

    @Published var importedConfigClaims: ConfigClaims? = .none

    var minWidth: Double

    init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            self.minWidth = 1024
        default:
            self.minWidth = 500
        }
    }

    var tabSelection: Binding<Route> {
        Binding { [weak self] in
            self?.selectedTab ?? .stopwatch
        } set: { [weak self] newValue in
            self?.selectedTab = newValue
        }
    }
}
