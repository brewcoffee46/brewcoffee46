import BrewCoffee46Core
import SwiftUI

struct SelectConfigView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: ConfigViewModel

    var body: some View {
        Picker("watch kit app select config", selection: $viewModel.currentConfig) {
            ForEach(viewModel.allConfigs, id: \.self) { config in
                Text(config.note ??? NSLocalizedString("config note empty string", comment: ""))
            }
        }
        .disabled(appEnvironment.isTimerStarted)
    }
}

#if DEBUG
    struct SelectConfigView_Perviews: PreviewProvider {
        static func configView() -> ConfigViewModel {
            var config1 = Config.defaultValue()
            config1.note = "config 1"
            var config2 = Config.defaultValue()
            config2.note = "long long long long long long name config 2"
            var config3 = Config.defaultValue()
            config3.note = "config 3"

            let configViewModel = ConfigViewModel()
            configViewModel.allConfigs = [config1, config2, config3]

            return configViewModel
        }

        static var previews: some View {
            SelectConfigView()
                .environmentObject(configView())
                .environmentObject(WatchKitAppEnvironment())
        }
    }
#endif
