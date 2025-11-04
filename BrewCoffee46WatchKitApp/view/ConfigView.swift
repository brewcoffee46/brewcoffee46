import BrewCoffee46Core
import SwiftUI

struct ConfigView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: ConfigViewModel
    @State private var alwaysLocked: Bool = true

    var body: some View {
        List {
            Section(header: Text("config save load current config")) {
                ScrollView {
                    ShowConfigView(
                        config: $viewModel.currentConfig,
                        // In WatchKitApp, editing configuration is always disabled so `isLock` is always `true`.
                        isLock: $alwaysLocked
                    )
                }
            }
        }
    }
}

#if DEBUG
    struct ConfigView_Perviews: PreviewProvider {
        static var previews: some View {
            ConfigView()
                .environmentObject(ConfigViewModel())
        }
    }
#endif
