import FactoryKit
import SwiftUI

public struct SwitchIconListView: View {
    @Injected(\.dripIndexTextFormatterService) private var dripIndexTextFormatterService

    private let iconSize: CGFloat = 24
    private let contentHeight: CGFloat = 44

    let switches: [Switch]

    public var body: some View {
        // Keep short switch lists right-aligned while still allowing long lists to scroll horizontally.
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(switches.enumerated()), id: \.offset) { index, item in
                        VStack {
                            Text(dripIndexTextFormatterService.dripText(index))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)

                            Image(systemName: item.toBool() ? "lightswitch.on.fill" : "lightswitch.off.fill")
                                .scaledToFit()
                                .rotationEffect(.degrees(90))
                                .frame(width: iconSize, height: iconSize)
                                .foregroundColor(item.toBool() ? .blue : .gray)
                        }
                    }
                }
                .frame(minWidth: proxy.size.width, alignment: .trailing)
            }
        }
        .frame(height: contentHeight)
    }
}

#if DEBUG
    struct SwitchIconListView_Previews: PreviewProvider {
        @State static var appConfig = AppConfig.defaultValue()
        @State static var isLock = false

        static var previews: some View {
            SwitchIconListView(switches: appConfig.coffeeConfig.switches)
        }
    }
#endif
