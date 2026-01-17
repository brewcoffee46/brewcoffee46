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
        Grid(alignment: .leading) {
            GridRow {
                HStack {
                    Text("config note placeholder")
                    if isLock {
                        Image(systemName: "lock.fill")
                    } else {
                        Image(systemName: "pencil.and.list.clipboard")
                    }
                }
                Group {
                    if isLock {
                        Text(config.note ?? NSLocalizedString("config note empty string", comment: ""))
                    } else {
                        TextField(
                            "config note placeholder",
                            text: $config.note ?? NSLocalizedString("config note empty string", comment: "")
                        )
                        .multilineTextAlignment(.trailing)
                        .background()
                        // It's not necessary?
                        .disabled(isLock)
                    }
                }
                .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config coffee beans weight")
                Text("\(config.coffeeBeansWeight, specifier: "%.1f")\(weightUnit)")
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config water ratio short")
                Text("\(config.waterToCoffeeBeansWeightRatio, specifier: "%.1f")")
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config 1st water percent")
                Text("\(config.firstWaterPercent * 100, specifier: "%.0f")%")
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config number of partitions of later 6")
                Text(String(format: "%1.0f", config.partitionsCountOf6))
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config total time")
                HStack {
                    Text((String(format: "%.0f", config.totalTimeSec)))
                    Text("config sec unit")
                }
                .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config steaming time short")
                HStack {
                    Text(String(format: "%.0f", config.steamingTimeSec))
                    Text("config sec unit")
                }
                .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config mill settings").gridCellColumns(2)
            }
            GridRow {
                MillListView(items: $config.mills).gridCellColumns(2)
            }
            Divider()

            GridRow {
                Text("config last edited at")
                Text(
                    config.editedAtMilliSec?.toDate().formattedWithSec()
                        ?? NSLocalizedString("config none last edited at", comment: "")
                )
                .gridColumnAlignment(.trailing)
            }
            Divider()
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
