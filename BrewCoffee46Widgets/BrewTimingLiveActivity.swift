import ActivityKit
import BrewCoffee46Core
import FactoryKit
import SwiftUI
import WidgetKit

struct BrewTimingLiveActivity: Widget {
    @Injected(\.dateService) private var dateService

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BrewTimingAttributes.self) { context in
            BrewTimingLiveActivityView(context: context)
                .activityBackgroundTint(.brown.opacity(0.18))
                .activitySystemActionForegroundColor(.brown)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("#\(context.state.currentPourIndex)")
                                .font(.title2.weight(.semibold))
                            Text("of \(context.state.totalPourCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.leading, 8)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Text("\(Int(context.state.nextWaterAmount.gram))g")
                            .font(.title2.weight(.semibold))
                        Text("next")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 8)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Spacer()
                            BrewWidgetHeader(title: context.attributes.recipeName)
                            Spacer()
                        }
                        ProgressView(timerInterval: context.state.progressRange, countsDown: false)
                            .tint(.brown)
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(.brown)
            } compactTrailing: {
                Text(timerInterval: dateService.now()...context.state.finishedAt, countsDown: false)
                    .font(.caption2.monospacedDigit())
                    .frame(width: 42)
            } minimal: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(.brown)
            }
        }
    }
}

#Preview("Dynamic Island(compact)", as: .dynamicIsland(.compact), using: BrewTimingAttributes.preview) {
    BrewTimingLiveActivity()
} contentStates: {
    BrewTimingAttributes.ContentState.preview
}

#Preview("Dynamic Island(minimal)", as: .dynamicIsland(.minimal), using: BrewTimingAttributes.preview) {
    BrewTimingLiveActivity()
} contentStates: {
    BrewTimingAttributes.ContentState.preview
}

#Preview("Dynamic Island(expanded)", as: .dynamicIsland(.expanded), using: BrewTimingAttributes.preview) {
    BrewTimingLiveActivity()
} contentStates: {
    BrewTimingAttributes.ContentState.preview
}

extension BrewTimingAttributes {
    static let preview = BrewTimingAttributes(
        recipeName: "4:6 Method",
        totalTime: MilliSecond.fromSecond(210)
    )
}

extension BrewTimingAttributes.ContentState {
    static let preview = BrewTimingAttributes.ContentState(
        startedAt: .now.addingTimeInterval(0),
        finishedAt: .now.addingTimeInterval(150),
        currentPourIndex: 2,
        totalPourCount: 5,
        nextPourAt: .now.addingTimeInterval(26),
        nextWaterAmount: MilliGram.fromGram(270),
        totalWaterAmount: MilliGram.fromGram(450)
    )
}
