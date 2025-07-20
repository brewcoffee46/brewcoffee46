import SwiftUI

@main
struct WatchApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(CurrentConfigViewModel())
                .environmentObject(WatchKitAppEnvironment())
        }
    }
}
