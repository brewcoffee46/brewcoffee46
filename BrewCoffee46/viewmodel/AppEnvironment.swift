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

    @Published var importedConfigClaimsWithURL: ConfigClaimsWithURL? = .none

    var tabSelection: Binding<Route> {
        Binding { [weak self] in
            self?.selectedTab ?? .stopwatch
        } set: { [weak self] newValue in
            self?.selectedTab = newValue
        }
    }
}
