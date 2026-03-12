import SwiftUI
import TipKit

public struct ShowConfigView: View {
    @Binding public var appConfig: AppConfig
    @Binding public var isLock: Bool

    public init(
        _ appConfig: Binding<AppConfig>,
        _ isLock: Binding<Bool>
    ) {
        _appConfig = appConfig
        _isLock = isLock
    }

    @State private var notePlaceholder = NSLocalizedString("config note empty string", comment: "")

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
                    VStack {
                        TextField(
                            notePlaceholder,
                            text: $appConfig.coffeeConfig.note,
                            onEditingChanged: { (hasChanged) in
                                if hasChanged && appConfig.coffeeConfig.note.isEmpty {
                                    notePlaceholder = ""
                                } else if !hasChanged && appConfig.coffeeConfig.note.isEmpty {
                                    notePlaceholder = NSLocalizedString("config note empty string", comment: "")
                                }
                            }
                        )
                        .multilineTextAlignment(.trailing)
                        .background()
                        .disabled(isLock)
                        if isLock {
                            HStack {
                                Spacer()
                                InfoTextView("config note cannot edit")
                            }
                        }
                    }
                }
                .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config coffee beans weight")
                Text("\(appConfig.globalConfig.coffeeBeansWeightG, specifier: "%.1f")\(weightUnit)")
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config water ratio short")
                Text("\(appConfig.coffeeConfig.waterToCoffeeBeansWeightRatio, specifier: "%.1f")")
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config 1st water percent")
                Text("\(appConfig.coffeeConfig.firstWaterPercent * 100, specifier: "%.0f")%")
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config number of partitions of later 6")
                Text(String(format: "%d", appConfig.coffeeConfig.partitionsCountOf6))
                    .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config total time")
                HStack {
                    Text((String(format: "%.0f", appConfig.coffeeConfig.totalTimeSec)))
                    Text("config sec unit")
                }
                .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config steaming time short")
                HStack {
                    Text(String(format: "%.0f", appConfig.coffeeConfig.steamingTimeSec))
                    Text("config sec unit")
                }
                .gridColumnAlignment(.trailing)
            }
            Divider()

            GridRow {
                Text("config mill settings").gridCellColumns(2)
            }
            GridRow {
                MillListView(items: appConfig.coffeeConfig.mills).gridCellColumns(2)
            }
            Divider()

            GridRow {
                Text("config last edited at")
                Text(
                    appConfig.coffeeConfig.editedAtMilliSec?.toDate().formattedWithSec()
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
        @State static var appConfig = AppConfig.defaultValue()
        @State static var isLock = false

        static var previews: some View {
            ShowConfigView(
                $appConfig,
                $isLock
            )
        }
    }
#endif
