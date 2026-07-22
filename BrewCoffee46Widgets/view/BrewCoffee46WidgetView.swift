import BrewCoffee46Core
import FactoryKit
import SwiftUI

struct BrewCoffee46WidgetWidgetView: View {
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
                Text("Beans")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(entry.coffeeBeansWeight.gram))g")
                    .font(.title2.weight(.bold))
            }
            HStack {
                Text("Water")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(entry.totalWaterAmountMg.gram))g")
                    .font(.title2.weight(.bold))
            }
            HStack {
                Text("Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(brewTimeText(Int(entry.totalTimeMilliSec.second)))
                    .font(.title2.weight(.bold))
            }
        }
    }

    private var mediumView: some View {
        VStack {
            BrewWidgetHeader(title: entry.recipeName)
            Spacer()
            DripTimingView(
                coffeeBeansWeight: entry.coffeeBeansWeight,
                totalWaterAmount: entry.totalWaterAmountMg,
                dripTimings: entry.dripInfo.dripTimings,
                totalTime: entry.totalTimeMilliSec
            )
        }
    }
}
