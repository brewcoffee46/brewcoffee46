import SwiftUI

struct InfoView: View {
    #if DEBUG
        private let debug: String = " (Debug)"
    #else
        private let debug: String = ""
    #endif

    var body: some View {
        Form {
            Section(header: Text("info version")) {
                Text("\((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)\(debug)")
            }

            Section(header: Text("info license header")) {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }) {
                    Text("info oss licenses")
                }
            }

            Section(header: Text("info source code")) {
                Link(
                    "https://github.com/brewcoffee46/brewcoffee46",
                    destination: URL(string: "https://github.com/brewcoffee46/brewcoffee46")!)
            }

            Section(header: Text("info author")) {
                HStack {
                    Text("Email:")
                    Text("yyu@mental.poker")
                        .textSelection(.enabled)
                }
                HStack {
                    Text("X:")
                    Link(
                        destination: URL(string: "https://x.com/_yyu_")!,
                        label: { Text(verbatim: "@_yyu_") }
                    )
                }
            }

            Section(header: Text("info references")) {
                VStack {
                    Link(
                        destination: URL(string: "https://www.amazon.co.jp/dp/4297134039")!,
                        label: { Text(verbatim: "誰でも簡単！世界一の4：6メソッドでハマる 美味しいコーヒー") }
                    )
                    HStack {
                        Spacer()
                        Text("info by kasuya tetsu")
                    }
                }
            }
        }
        .navigationTitle("navigation title information")
    }
}

#if DEBUG
    struct InfoView_Previews: PreviewProvider {
        static var previews: some View {
            InfoView()
        }
    }
#endif
