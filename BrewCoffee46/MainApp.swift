import BrewCoffee46Core
import Factory
import SwiftUI
import TipKit

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
                    appEnvironment.importedConfigClaimsWithURL = ConfigClaimsWithURL(url: url, configClaims: configClaims)
                    appEnvironment.selectedTab = .setting
                    appEnvironment.configPath = [.setting, .universalLinksImport]
                }
            }
        }
    }

    init() {
        do {
            #if DEBUG
                try Tips.resetDatastore()
                print("Tips.resetDatastore success!")
            #endif

            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault),
            ])
        } catch {
            let errorString = "Error initializing TipKit: \(error.localizedDescription)"
            viewModel.errors = errorString
        }
    }
}
