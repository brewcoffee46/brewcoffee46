import SwiftUI

struct BrewWidgetHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "cup.and.saucer.fill")
                .foregroundStyle(.brown)
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
    }
}

struct BrewProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.2))
                Capsule()
                    .fill(.brown)
                    .frame(width: max(0, min(1, value)) * proxy.size.width)
            }
        }
        .frame(height: 6)
    }
}

func brewTimeText(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}
