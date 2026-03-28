import SwiftUI

public struct InfoTextView: View {
    public let text: String

    public init(_ text: String) {
        self.text = NSLocalizedString(text, comment: "")
    }

    public var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 10))
        }
        .foregroundStyle(Color.primary.opacity(0.5))
    }
}
