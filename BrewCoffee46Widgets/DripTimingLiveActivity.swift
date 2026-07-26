import ActivityKit
import BrewCoffee46Core
import FactoryKit
import SwiftUI
import WidgetKit

struct DripTimingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DripTimingAttributes.self) { context in
            DripTimingLiveActivityView(context: context)
                .activityBackgroundTint(.brown.opacity(0.18))
                .activitySystemActionForegroundColor(.brown)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        DripTimingView(
                            coffeeBeansWeight: context.attributes.coffeeBeansWeight,
                            totalWaterAmount: context.attributes.totalWaterAmount,
                            dripTimings: context.attributes.dripTimings,
                            totalTime: context.attributes.totalTime
                        )
                        HStack {
                            DripProgressView(
                                startedAt: context.attributes.startedAt,
                                dripTimings: context.attributes.dripTimings,
                                totalTime: context.attributes.totalTime
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(.brown)
            } compactTrailing: {
                Text(
                    timerInterval: context.attributes
                        .startedAt...context.attributes.startedAt.addingTimeInterval(context.attributes.totalTime.second),
                    countsDown: false
                )
                .font(.caption2.monospacedDigit())
                .frame(width: 42)
            } minimal: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(.brown)
            }
        }
    }
}

#Preview("Dynamic Island(expanded)", as: .dynamicIsland(.expanded), using: DripTimingAttributes.preview) {
    DripTimingLiveActivity()
} contentStates: {
    DripTimingAttributes.ContentState.defaultValue
}

#Preview("Dynamic Island(compact)", as: .dynamicIsland(.compact), using: DripTimingAttributes.preview) {
    DripTimingLiveActivity()
} contentStates: {
    DripTimingAttributes.ContentState.defaultValue
}

#Preview("Dynamic Island(minimal)", as: .dynamicIsland(.minimal), using: DripTimingAttributes.preview) {
    DripTimingLiveActivity()
} contentStates: {
    DripTimingAttributes.ContentState.defaultValue
}

extension DripTimingAttributes {
    static let preview = DripTimingAttributes(
        startedAt: .now,
        recipeName: "4:6 Method",
        coffeeBeansWeight: GlobalConfig.defaultValue().coffeeBeansWeightMg,
        totalWaterAmount: MilliGram.fromGram(DripInfo.defaultValue().waterAmount.totalAmount()),
        dripTimings: DripInfo.defaultValue().dripTimings,
        totalTime: MilliSecond.fromSecond(30)
    )
}
