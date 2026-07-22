import BrewCoffee46Core
import SwiftUI
import WidgetKit

struct DripEntry: TimelineEntry {
    let date: Date
    let recipeName: String
    let coffeeBeansWeightMg: MilliGram
    let dripInfo: DripInfo
}

struct BrewTimingProvider: TimelineProvider {
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

struct BrewTimingWidget: Widget {
    private let kind = "BrewTimingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BrewTimingProvider()) { entry in
            BrewTimingWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Brew Timer")
        .description("Shows the current BrewCoffee46 recipe.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BrewTimingWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: DripEntry

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 10) {
            BrewWidgetHeader(title: entry.recipeName)
            Spacer(minLength: 0)
            HStack {
                Text("\(Int(entry.coffeeBeansWeightMg.gram))g")
                    .font(.title2.weight(.bold))
                Text("beans")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("\(Int(entry.totalWaterAmountMg.gram))g")
                    .font(.title2.weight(.bold))
                Text("water")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(brewTimeText(Int(entry.totalTimeMilliSec.second)))
                    .font(.title2.weight(.bold))
                Text("left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            BrewWidgetHeader(title: entry.recipeName)
            HStack(spacing: 12) {
                summary("Beans", "\(Int(entry.coffeeBeansWeightMg.gram))g")
                summary("Water", "\(Int(entry.totalWaterAmountMg.gram))g")
                summary("Time", brewTimeText(Int(entry.totalTimeMilliSec.second)))
            }
            Divider()
            HStack(spacing: 8) {
                ForEach(Array(entry.dripInfo.dripTimings.enumerated()), id: \.offset) { index, dripTiming in
                    VStack(spacing: 3) {
                        Text("#\(index + 1)")
                            .font(.caption2.weight(.semibold))
                        Text("\(Int(dripTiming.waterAmount.gram))g")
                            .font(.caption2.monospacedDigit())
                        Text(brewTimeText(Int(dripTiming.dripAt.second)))
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func summary(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            coffeeBeansWeightMg: GlobalConfig.initCoffeeBeansWeightMg,
            dripInfo: .defaultValue()
        )
    }
}

#Preview(as: .systemSmall) {
    BrewTimingWidget()
} timeline: {
    DripEntry.sample
}

#Preview(as: .systemMedium) {
    BrewTimingWidget()
} timeline: {
    DripEntry.sample
}
