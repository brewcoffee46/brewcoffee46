import BrewCoffee46Core
import SwiftUI

struct JsonImportExportView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @State var json: String = ""
    @State var isPrettyPrint: Bool = true

    var body: some View {
        Form {
            Toggle("config import export JSON pretty printing", isOn: $isPrettyPrint)
            Section {
                HStack {
                    Spacer()
                    Button(action: {
                        updateConfig()
                    }) {
                        HStack {
                            Spacer()
                            Text("Import")
                            Spacer()
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(appEnvironment.isTimerStarted)
                    .id(!appEnvironment.isTimerStarted)

                    Divider()

                    Button(action: {
                        exportJSON()
                    }) {
                        HStack {
                            Spacer()
                            Text("Export")
                            Spacer()
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Spacer()
                }
            }
            Section(header: Text("JSON")) {
                TextEditor(text: $json)
                    .frame(maxHeight: .infinity)
            }
            if let importedConfig = appEnvironment.importedConfigClaimsWithURL?.configClaims {
                ShowConfigView(
                    config: Binding(
                        get: { importedConfig.config },
                        set: { _ in () }
                    ), isLock: true.getOnlyBinding)
            }
            Section(
                header: HStack {
                    Text("Log")
                    Spacer()
                    Button(
                        role: .destructive,
                        action: {
                            viewModel.errors = ""
                        }
                    ) {
                        Text("config import export clear log")
                    }
                    .disabled(viewModel.errors == "")
                }
            ) {
                Text(viewModel.errors)
                    .foregroundColor(.red)
                    .hidden(viewModel.errors == "")
            }
        }
        .navigationTitle("config import export")
    }

    private func updateConfig() {
        viewModel.errors = ""
        switch Config.fromJSON(json) {
        case .success(let config):
            viewModel.currentConfig = config
        case .failure(let errors):
            viewModel.errors = "\(errors)"
        }
    }

    private func exportJSON() {
        viewModel.errors = ""
        switch viewModel.currentConfig.toJSON(isPrettyPrint: isPrettyPrint) {
        case .success(let j):
            json = j
        case .failure(let errors):
            viewModel.errors = "\(errors)"
        }
    }
}

#if DEBUG
    struct JsonExportView_Previews: PreviewProvider {
        static var previews: some View {
            JsonImportExportView()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
                .previewDisplayName("importedConfig is `.none`")

            JsonImportExportView()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(
                    { () in
                        let env = AppEnvironment.init()
                        env.importedConfigClaimsWithURL = ConfigClaimsWithURL(
                            url: URL(string: "https://example.com")!,
                            configClaims: ConfigClaims(iss: "dummy", iat: Date.now, version: 1, config: Config.defaultValue())
                        )
                        return env
                    }()
                )
                .previewDisplayName("importedConfig is `some`")
        }
    }
#endif
