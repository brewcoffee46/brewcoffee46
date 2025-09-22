import BrewCoffee46Core
import Factory
import SwiftUI
import TipKit

struct UniversalLinksImportView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Injected(\.saveLoadConfigService) private var saveLoadConfigService: SaveLoadConfigService

    @State var json: String = ""
    @State var isShowJson: Bool = false
    @State var hasDoneImport: Bool = false

    var body: some View {
        Form {
            if let importedConfigClaimsWithURL = appEnvironment.importedConfigClaimsWithURL {
                var config = importedConfigClaimsWithURL.configClaims.config
                let url = importedConfigClaimsWithURL.url

                Section(header: Text("config universal links import imported config")) {
                    ShowConfigView(
                        config: Binding(
                            get: { config },
                            set: { c in config = c }
                        ),
                        isLock: false.getOnlyBinding
                    )

                    HStack {
                        Spacer()
                        TipView(UniversalLinksSaveTip(), arrowEdge: .trailing)
                        Button(action: {
                            saveLoadConfigService
                                .saveConfig(config: config)
                                .map { x in
                                    hasDoneImport = true
                                    return x
                                }
                                .recoverWithErrorLog(&viewModel.errors)
                        }) {
                            HStack {
                                Text("config universal links import save button")
                                Image(systemName: "plus.square.on.square")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(lineWidth: 1)
                                    .padding(6)
                            )
                        }
                    }
                }

                Section(header: Text("config universal links imported url")) {
                    Text(url.absoluteString)
                        .textSelection(.enabled)
                        .font(.system(size: 10))
                        .frame(maxHeight: 60)
                }

                Toggle("config universal links import is JSON show", isOn: $isShowJson)
                    .onChange(of: isShowJson) {
                        exportJSON(config)
                    }

                if isShowJson {
                    Section(header: Text("JSON")) {
                        TextEditor(text: $json)
                            .frame(maxHeight: .infinity)
                    }
                }
            } else {
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
                            Text("config universal links import export clear log")
                        }
                        .disabled(viewModel.errors == "")
                    }
                ) {
                    Text(viewModel.errors)
                        .foregroundColor(.red)
                        .hidden(viewModel.errors == "")
                }
            }
        }
        .sheet(isPresented: $hasDoneImport) {
            Button(action: {
                hasDoneImport = false
                appEnvironment.importedConfigClaimsWithURL = .none
                appEnvironment.configPath = [.saveLoad]
            }) {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.green)
                        Text("config universal links import is done")
                            .font(.system(size: 30))
                    }
                    Text("config universal links import move to save & load")
                }
            }
            .presentationDetents([
                .medium,
                .fraction(0.3),
            ])
        }
        .navigationTitle("config universal links import title")
    }

    private func exportJSON(_ config: Config) {
        viewModel.errors = ""
        switch config.toJSON(isPrettyPrint: true) {
        case .success(let j):
            json = j
        case .failure(let errors):
            viewModel.errors = "\(errors)"
        }
    }
}

#if DEBUG
    struct UniversalLinksImportView_Previews: PreviewProvider {
        static var previews: some View {
            UniversalLinksImportView()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(
                    { () in
                        let env = AppEnvironment.init()
                        env.importedConfigClaimsWithURL = ConfigClaimsWithURL(
                            url: URL(
                                string:
                                    "https://brewcoffee46.github.io/app/v1.html?config=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJpYXQiOjE3NTg1MjQ3MjQuNzExNTk3LCJpc3MiOiJCcmV3Q29mZmVlNDYiLCJ2ZXJzaW9uIjoxLCJjb25maWciOnsidG90YWxUaW1lU2VjIjoyMTAsImNvZmZlZUJlYW5zV2VpZ2h0IjoxNiwiZmlyc3RXYXRlclBlcmNlbnQiOjAuNSwibm90ZSI6IuOCqOODs-OCuOODi-OCouODm-ODg-ODiOOCs-ODvOODkuODvCIsInBhcnRpdGlvbnNDb3VudE9mNiI6MywiYmVmb3JlQ2hlY2tsaXN0IjpbIuOBiua5r-OCkuayuOOBi-OBmSIsIuODleOCo-ODq-OCv-ODvOOCkuODieODquODg-ODkeODvOOBq-OCu-ODg-ODiCIsIuODleOCo-ODq-OCv-ODvOOCkuODquODs-OCuSIsIuOCs-ODvOODkuODvOeyieOCkuOCu-ODg-ODiCIsIuOCueOCseODvOODq-OCkuODquOCu-ODg-ODiCJdLCJlZGl0ZWRBdE1pbGxpU2VjIjoxNzU4NTI0NjY2ODc4LCJ2ZXJzaW9uIjoxLCJzdGVhbWluZ1RpbWVTZWMiOjQ1LCJ3YXRlclRvQ29mZmVlQmVhbnNXZWlnaHRSYXRpbyI6MTZ9fQ"
                            )!,
                            configClaims: ConfigClaims(iss: "dummy", iat: Date.now, version: 1, config: Config.defaultValue())
                        )
                        return env
                    }()
                )
                .previewDisplayName("importedConfig is `some`")
        }
    }
#endif
