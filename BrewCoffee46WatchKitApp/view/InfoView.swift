import SwiftUI

struct InfoView: View {
    var body: some View {
        Form {
            Section(header: Text("info version")) {
                Text((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)
            }
        }
    }
}
