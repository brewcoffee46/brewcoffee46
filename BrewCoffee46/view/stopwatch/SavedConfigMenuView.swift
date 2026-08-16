import BrewCoffee46Core
import FactoryKit
import SwiftUI

struct SavedConfigMenuView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Injected(\.saveLoadConfigService) private var saveLoadConfigService

    @State private var configs: [CoffeeConfig] = []
    @State private var selectedConfig: CoffeeConfig?
    @State private var isLoadAlertPresented = false

    var body: some View {
        Menu {
            if configs.isEmpty {
                Button("config empty", action: {})
                    .disabled(true)
            } else {
                ForEach(configs, id: \.self) { config in
                    Button(action: {
                        selectedConfig = config
                        if configs.contains(viewModel.currentConfig.coffeeConfig) {
                            viewModel.currentConfig.coffeeConfig = config
                            selectedConfig = nil
                        } else {
                            isLoadAlertPresented = true
                        }
                    }) {
                        if config == viewModel.currentConfig.coffeeConfig {
                            Label(configName(config), systemImage: "checkmark")
                        } else {
                            Text(configName(config))
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(configName(viewModel.currentConfig.coffeeConfig))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .menuOrder(.fixed)
        .disabled(appEnvironment.isTimerStarted)
        .onAppear(perform: loadConfigs)
        .configLoadAlert(
            isPresented: $isLoadAlertPresented,
            selectedConfig: $selectedConfig
        ) { config in
            viewModel.currentConfig.coffeeConfig = config
        }
    }

    private func configName(_ config: CoffeeConfig) -> String {
        config.note ??? NSLocalizedString("config note empty string", comment: "")
    }

    private func loadConfigs() {
        saveLoadConfigService
            .loadAll()
            .map { configs = $0 ?? [] }
            .recoverWithErrorLog(&viewModel.errors)
    }
}

#if DEBUG
    final class MockSaveLoadConfigServiceImpl: SaveLoadConfigService {
        func saveCurrentConfig(_ config: AppConfig) -> ResultNea<Void, CoffeeError> {
            fatalError()
        }

        func loadCurrentConfig() -> ResultNea<AppConfig?, CoffeeError> {
            .success(nil)
        }

        func saveAll(configs: [CoffeeConfig]) -> ResultNea<Void, CoffeeError> {
            fatalError()
        }

        func loadAll() -> ResultNea<[CoffeeConfig]?, CoffeeError> {
            var config = CoffeeConfig.defaultValue()
            let config0 = config
            config.note = "config 111111"
            let config1 = config
            config.note = "config 22"
            let config2 = config
            config.note = "config 333333333333"
            let config3 = config

            return .success([config0, config1, config2, config3])
        }

        func saveConfig(config: CoffeeConfig) -> ResultNea<Void, CoffeeError> {
            fatalError()
        }

        func delete(key: String) -> Void {
            fatalError()
        }
    }

    struct SavedConfigMenuView_Previews: PreviewProvider {
        @State static var currentConfig = CoffeeConfig.defaultValue()
        @State static var errors = ""

        static var previews: some View {
            Container.shared.saveLoadConfigService.preview {
                MockSaveLoadConfigServiceImpl()
            }

            SavedConfigMenuView()
                .padding()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
                .previewDisplayName("Some configurations")
        }
    }
#endif
