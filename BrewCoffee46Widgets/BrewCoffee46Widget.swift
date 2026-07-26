import BrewCoffee46Core
import SwiftUI
import WidgetKit

struct DripEntry: TimelineEntry {
    let date: Date
    let recipeName: String
    let coffeeBeansWeight: MilliGram
    let dripInfo: DripInfo
}

struct BrewCoffee46TimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DripEntry {
        DripEntry.sample
    }

    func getSnapshot(in context: Context, completion: @escaping (DripEntry) -> Void) {
        completion(.sample)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DripEntry>) -> Void) {
        completion(Timeline(entries: [.sample], policy: .never))
    }
}

struct BrewCoffee46Widget: Widget {
    private let kind = "BrewTimingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BrewCoffee46TimelineProvider()) { entry in
            BrewCoffee46WidgetWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Brew Timer")
        .description("Shows the current BrewCoffee46 recipe.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension DripEntry {
    var totalWaterAmountMg: MilliGram {
        MilliGram.fromGram(dripInfo.waterAmount.totalAmount())
    }

    var totalTimeMilliSec: MilliSecond {
        MilliSecond.fromSecond(dripInfo.totalTimeSec)
    }

    static var sample: DripEntry {
        DripEntry(
            date: .now,
            recipeName: "4:6 Method",
            coffeeBeansWeight: GlobalConfig.initCoffeeBeansWeightMg,
            dripInfo: .defaultValue()
        )
    }
}

#Preview(as: .systemSmall) {
    BrewCoffee46Widget()
} timeline: {
    DripEntry.sample
}

#Preview(as: .systemMedium) {
    BrewCoffee46Widget()
} timeline: {
    DripEntry.sample
}
