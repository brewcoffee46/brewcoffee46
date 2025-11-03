import SwiftUI

struct InfoView: View {
    @EnvironmentObject var viewModel: ConfigViewModel

    var body: some View {
        Form {
            Section(header: Text("info version")) {
                Text((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)
            }

            if !viewModel.log.isEmpty {
                Section(header: Text("watch kit app info log header")) {
                    Text(viewModel.log)
                }
            }
        }
    }
}
