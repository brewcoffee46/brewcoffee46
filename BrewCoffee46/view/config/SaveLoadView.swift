import BrewCoffee46Core
import FactoryKit
import Foundation
import SwiftUI

struct SaveLoadView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Injected(\.saveLoadConfigAndLegacyConfigService) private var saveLoadConfigService: SaveLoadConfigAndLegacyConfigService

    @Environment(\.scenePhase) private var scenePhase

    @State private var configs: [CoffeeConfig] = []
    @State private var legacySavedConfigs: [CoffeeConfig] = []

    @State private var isLoadAlertPresented: Bool = false
    @State private var isLegacyLoadAlertPresented: Bool = false
    @State private var selectedConfig: CoffeeConfig? = .none

    @State private var isEditing: Bool = false
    @State private var mode: EditMode = .inactive

    var body: some View {
        Form {
            Section(header: Text("config save load current config")) {
                VStack {
                    ShowConfigView(
                        Binding(
                            get: { viewModel.currentConfig },
                            set: { newValue in
                                viewModel.editCoffeeConfig {
                                    $0.note = newValue.coffeeConfig.note
                                }
                            }
                        ),
                        (mode.isEditing || self.appEnvironment.isTimerStarted).getOnlyBinding
                    )
                    HStack {
                        Spacer()
                        Button(action: {
                            configs.insert(viewModel.currentConfig.coffeeConfig, at: 0)
                            saveLoadConfigService
                                .saveAll(configs: configs)
                                .recoverWithErrorLog(&viewModel.errors)
                        }) {
                            HStack {
                                Text("config save button")
                                Image(systemName: "plus.square.on.square")
                            }
                        }
                        .disabled(mode.isEditing || configs.contains(viewModel.currentConfig.coffeeConfig))
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    if configs.contains(viewModel.currentConfig.coffeeConfig) {
                        HStack {
                            Spacer()
                            InfoTextView("config current config have already been saved")
                        }
                    }
                }
            }

            if !legacySavedConfigs.isEmpty {
                loadLegacySavedConfigs
            }

            Section(
                header: HStack {
                    Text("config saved data")
                    Spacer()
                    EditButton().disabled(appEnvironment.isTimerStarted)
                }
            ) {
                if configs.isEmpty {
                    Text("config empty")
                } else {
                    ForEach(configs, id: \.self) { config in
                        Button(action: {
                            selectedConfig = .some(config)
                            if configs.contains(viewModel.currentConfig.coffeeConfig) {
                                viewModel.currentConfig.coffeeConfig = config
                                selectedConfig = .none
                            } else {
                                isLoadAlertPresented.toggle()
                            }
                        }) {
                            HStack {
                                Text(config.note ??? NSLocalizedString("config note empty string", comment: ""))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text(
                                    config.editedAtMilliSec?.toDate().formattedWithSec()
                                        ?? NSLocalizedString("config none last edited at", comment: ""))
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(appEnvironment.isTimerStarted || mode.isEditing)
                        .deleteDisabled(appEnvironment.isTimerStarted)
                        .moveDisabled(appEnvironment.isTimerStarted)
                    }
                    .onDelete(perform: { indexSet in
                        configs.remove(atOffsets: indexSet)
                        saveLoadConfigService
                            .saveAll(configs: configs)
                            .recoverWithErrorLog(&viewModel.errors)
                    })
                    .onMove(perform: { src, dest in
                        configs.move(fromOffsets: src, toOffset: dest)
                        saveLoadConfigService
                            .saveAll(configs: configs)
                            .recoverWithErrorLog(&viewModel.errors)
                    })
                }
            }

        }
        .navigation(
            path: $appEnvironment.configPath,
            title: "navigation title save load"
        )
        .environment(\.editMode, $mode)
        .onAppear {
            saveLoadConfigService
                .loadAll()
                .map { $0.map { configs = $0 } }
                .recoverWithErrorLog(&viewModel.errors)

            saveLoadConfigService
                .loadAllLegacyConfigs()
                .map { legacySavedConfigs = $0 }
                .recoverWithErrorLog(&viewModel.errors)
        }
        .configLoadAlert(
            isPresented: $isLoadAlertPresented,
            selectedConfig: $selectedConfig
        ) { config in
            viewModel.currentConfig.coffeeConfig = config
        }
        .currentConfigSaveLoadModifier(
            $viewModel.currentConfig,
            $viewModel.errors
        )
    }

    private var loadLegacySavedConfigs: some View {
        Section(header: Text("config legacy saved setting header")) {
            Button(action: { isLegacyLoadAlertPresented.toggle() }) {
                HStack {
                    Spacer()
                    Text("config legacy saved setting convert")
                    Spacer()
                }
            }
            .alert("config load setting alert title", isPresented: $isLegacyLoadAlertPresented) {
                Button(role: .cancel, action: { isLegacyLoadAlertPresented.toggle() }) {
                    Text("config load setting alert cancel")
                }
                Button(
                    role: .destructive,
                    action: {
                        isLegacyLoadAlertPresented.toggle()
                        configs.append(contentsOf: legacySavedConfigs)
                        saveLoadConfigService
                            .saveAll(configs: configs)
                            .map { _ in
                                saveLoadConfigService.deleteAllLegacyConfigs()
                                legacySavedConfigs = []
                            }
                            .recoverWithErrorLog(&viewModel.errors)
                    }
                ) {
                    Text("config legacy saved setting convert button")
                }
            } message: {
                Text("config load legacy setting alert message")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

#if DEBUG
    struct SaveLoadView_Previews: PreviewProvider {
        static var previews: some View {
            SaveLoadView()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
        }
    }
#endif
