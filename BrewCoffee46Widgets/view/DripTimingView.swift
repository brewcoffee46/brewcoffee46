import BrewCoffee46Core
import SwiftUI

struct DripTimingView: View {
    let coffeeBeansWeight: MilliGram
    let totalWaterAmount: MilliGram
    let dripTimings: [DripTiming]
    let totalTime: MilliSecond

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                summary("Beans", "\(Int(coffeeBeansWeight.gram))g")
                Spacer()
                Spacer()
                Spacer()
                summary("Water", "\(Int(totalWaterAmount.gram))g")
                Spacer()
                Spacer()
                Spacer()
                summary("Time", brewTimeText(Int(totalTime.second)))
                Spacer()
            }
            HStack {
                ForEach(Array(dripTimings.enumerated()), id: \.offset) { index, dripTiming in
                    VStack {
                        Text("#\(index + 1)")
                            .font(.caption2.weight(.semibold))
                        Text("\(Int(dripTiming.waterAmount.gram))g")
                            .font(.caption2.monospacedDigit())
                        Text(brewTimeText(Int(dripTiming.dripAt.second)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func summary(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.bold))
                .monospacedDigit()
        }
    }
}
