import SwiftUI
import TipKit

public struct ShowConfigView: View {
    @Binding public var config: Config
    @Binding public var isLock: Bool

    public init(config: Binding<Config>, isLock: Binding<Bool>) {
        _config = config
        _isLock = isLock
    }

    public var body: some View {
        if !isLock {
            TipView(NoteTip(), arrowEdge: .bottom)
        }
        LazyVGrid(
            columns: Array(
                repeating: .init(.flexible(), spacing: 0),
                count: 2
            ),
            alignment: .leading
        ) {
            Group {
                HStack {
                    Text("config note placeholder")
                    if isLock {
                        Image(systemName: "lock.fill")
                    } else {
                        Image(systemName: "pencil.and.list.clipboard")
                    }
                }
                if isLock {
                    Text(config.note ?? NSLocalizedString("config note empty string", comment: ""))
                } else {
                    TextField(
                        "config note placeholder",
                        text: $config.note ?? NSLocalizedString("config note empty string", comment: "")
                    )
                    // It's not necessary?
                    .disabled(isLock)
                }
            }
            Divider()
            Divider()
            Text("config coffee beans weight")
            Text("\(String(format: "%.1f", config.coffeeBeansWeight))\(weightUnit)")
            Divider()
            Divider()
            Text("config water ratio short")
            Text("\(String(format: "%.1f%", config.waterToCoffeeBeansWeightRatio))")
            Divider()
            Divider()
            Text("config 1st water percent")
            Text("\(String(format: "%.0f%", config.firstWaterPercent * 100))%")
            Divider()
            Divider()
            Text("config number of partitions of later 6")
            Text(String(format: "%1.0f", config.partitionsCountOf6))
            Divider()
            Divider()
            Text("config total time")
            HStack {
                Text((String(format: "%.0f", config.totalTimeSec)))
                Text("config sec unit")
            }
            Divider()
            Divider()
            Text("config steaming time short")
            HStack {
                Text(String(format: "%.0f", config.steamingTimeSec))
                Text("config sec unit")
            }
            Divider()
            Divider()
            Text("config last edited at")
            Text(
                config.editedAtMilliSec?.toDate().formattedWithSec()
                    ?? NSLocalizedString("config none last edited at", comment: "")
            )
        }
    }
}

#if DEBUG
    struct ShowConfigView_Previews: PreviewProvider {
        @State static var config = Config.defaultValue()
        @State static var isLock = false

        static var previews: some View {
            ShowConfigView(
                config: $config,
                isLock: $isLock
            )
        }
    }
#endif
