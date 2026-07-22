import BrewCoffee46Core
import FactoryKit
import SwiftUI
import WidgetKit

struct DripTimingLiveActivityView: View {
    let startedAt: Date
    let recipeName: String
    let coffeeBeansWeight: MilliGram
    let totalWaterAmount: MilliGram
    let dripTimings: [DripTiming]
    let totalTime: MilliSecond

    init(context: ActivityViewContext<DripTimingAttributes>) {
        self.startedAt = context.attributes.startedAt
        self.recipeName = context.attributes.recipeName
        self.coffeeBeansWeight = context.attributes.coffeeBeansWeight
        self.totalWaterAmount = context.attributes.totalWaterAmount
        self.dripTimings = context.attributes.dripTimings
        self.totalTime = context.attributes.totalTime
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DripTimingView(
                coffeeBeansWeight: coffeeBeansWeight,
                totalWaterAmount: totalWaterAmount,
                dripTimings: dripTimings,
                totalTime: totalTime
            )
            DripProgressView(
                startedAt: startedAt,
                dripTimings: dripTimings,
                totalTime: totalTime
            )
        }
        .padding(10)
    }
}

#Preview("Live Activity in Lock Screen", as: .content, using: DripTimingAttributes.preview) {
    DripTimingLiveActivity()
} contentStates: {
    DripTimingAttributes.ContentState.defaultValue
}
