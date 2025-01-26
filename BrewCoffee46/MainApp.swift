import BrewCoffee46Core
import Factory
import SwiftUI

@main
struct MainApp: App {
    @Injected(\.configurationLinkService) private var configurationLinkService

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var appEnvironment: AppEnvironment = .init()
    @ObservedObject var viewModel: CurrentConfigViewModel = CurrentConfigViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(appEnvironment)
                    .environmentObject(viewModel)
            }
            .onOpenURL { url in
                configurationLinkService.get(url: url).forEach { configClaims in
                    appEnvironment.importedConfigClaims = configClaims
                    appEnvironment.selectedTab = .setting
                    appEnvironment.configPath = [.setting, .universalLinksImport]
                }
            }
        }
    }
}
