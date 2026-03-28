import BrewCoffee46Core
import SwiftUI

struct SelectConfigView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: ConfigViewModel

    var body: some View {
        Picker("watch kit app select config", selection: $viewModel.currentConfig.coffeeConfig) {
            ForEach(viewModel.allConfigs, id: \.self) { config in
                Text(config.note ??? NSLocalizedString("config note empty string", comment: ""))
            }
        }
        .disabled(appEnvironment.isTimerStarted)
    }
}

#if DEBUG
    struct SelectConfigView_Perviews: PreviewProvider {
        static func generateConfig(_ note: String) -> CoffeeConfig {
            CoffeeConfig(
                partitionsCountOf6: 3,
                waterToCoffeeBeansWeightRatio: CoffeeConfig.initWaterToCoffeeBeansWeightRatio,
                firstWaterPercent: 0.5,
                totalTimeMilliSec: 210_000,
                steamingTimeMilliSec: 45_000,
                note: note,
                beforeChecklist: CoffeeConfig.initBeforeCheckList,
                editedAtMilliSec: .none,
                version: CoffeeConfig.currentVersion
            )
        }

        static func configView() -> ConfigViewModel {
            let config1 = generateConfig("config 1")
            let config2 = generateConfig("long long long long long long name config 2")
            let config3 = generateConfig("config 3")

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
