import SwiftUI

struct InfoView: View {
    @EnvironmentObject var viewModel: ConfigViewModel

    static private let marketingVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "Unknown"
    static private let projectVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "Unknown"

    #if DEBUG
        private let debug: String = "-\(projectVersion) (Debug)"
    #else
        private let debug: String = ""
    #endif

    var body: some View {
        Form {
            Section(header: Text("info version")) {
                Text("\(InfoView.marketingVersion)\(debug)")
            }

            if !viewModel.log.isEmpty {
                Section(header: Text("watch kit app info log header")) {
                    Text(viewModel.log)
                }
            }
        }
    }
}
