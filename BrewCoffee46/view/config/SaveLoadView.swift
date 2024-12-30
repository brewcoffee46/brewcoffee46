import BrewCoffee46Core
import Factory
import Foundation
import SwiftUI

struct SaveLoadView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Injected(\.saveLoadConfigAndLegacyConfigService) private var saveLoadConfigService: SaveLoadConfigAndLegacyConfigService

    @Environment(\.scenePhase) private var scenePhase

    @State private var configs: [Config] = []
    @State private var legacySavedConfigs: [Config] = []

    @State private var isLoadAlertPresented: Bool = false
    @State private var isLegacyLoadAlertPresented: Bool = false
    @State private var selectedConfig: Config? = .none

    @State private var isEditing: Bool = false
    @State private var mode: EditMode = .inactive

    var body: some View {
        Form {
            Section(header: Text("config save load current config")) {
                VStack {
                    ShowConfigView(
                        config: Binding(
                            get: {
                                var config = viewModel.currentConfig

                                if let lastUpdatedAt = viewModel.currentConfigLastUpdatedAt {
                                    config.editedAtMilliSec = lastUpdatedAt
                                }
                                return config
                            },
                            set: { viewModel.currentConfig = $0 }
                        ),
                        isLock: (mode.isEditing || self.appEnvironment.isTimerStarted).getOnlyBinding
                    )
                    HStack {
                        Spacer()
                        Button(action: {
                            var config = viewModel.currentConfig

                            if let lastUpdatedAt = viewModel.currentConfigLastUpdatedAt {
                                config.editedAtMilliSec = lastUpdatedAt
                            }

                            configs.insert(config, at: 0)
                            saveLoadConfigService
                                .saveAll(configs: configs)
                                .recoverWithErrorLog(&viewModel.errors)
                        }) {
                            HStack {
                                Text("config save button")
                                Image(systemName: "plus.square.on.square")
                            }
                        }
                        .disabled(mode.isEditing || configs.contains(viewModel.currentConfig))
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    if configs.contains(viewModel.currentConfig) {
                        HStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 8, height: 8)
                            Text("config current config have already been saved")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(Color.primary.opacity(0.5))
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
                            isLoadAlertPresented.toggle()
                        }) {
                            HStack {
                                Text(config.note ??? NSLocalizedString("config note empty string", comment: ""))
                                Spacer()
                                Text(
                                    config.editedAtMilliSec?.toDate().formattedWithSec()
                                        ?? NSLocalizedString("config none last edited at", comment: ""))
                            }
                        }
                        .alert("config load setting alert title", isPresented: $isLoadAlertPresented) {
                            Button(role: .cancel, action: { isLoadAlertPresented.toggle() }) {
                                Text("config load setting alert cancel")
                            }
                            Button(
                                role: .destructive,
                                action: {
                                    isLoadAlertPresented.toggle()
                                    if let config = selectedConfig {
                                        viewModel.currentConfig = config
                                        viewModel.currentConfigLastUpdatedAt = .none
                                        selectedConfig = .none
                                    }
                                }
                            ) {
                                Text("config load setting alert load")
                            }
                        } message: {
                            Text(
                                String(
                                    format: NSLocalizedString("config load setting alert message", comment: ""),
                                    selectedConfig?.note ??? NSLocalizedString("config note empty string", comment: ""),
                                    selectedConfig?.editedAtMilliSec?.toDate().formattedWithSec()
                                        ?? NSLocalizedString("config none last edited at", comment: "")
                                )
                            )
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
        .navigationTitle("navigation title save load")
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
        .currentConfigSaveLoadModifier(
            $viewModel.currentConfig,
            $viewModel.currentConfigLastUpdatedAt,
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
