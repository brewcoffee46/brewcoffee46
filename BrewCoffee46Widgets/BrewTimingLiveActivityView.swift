import BrewCoffee46Core
import FactoryKit
import SwiftUI
import WidgetKit

struct BrewTimingLiveActivityView: View {
    let recipeName: String
    let state: BrewTimingAttributes.ContentState

    @Injected(\.dateService) private var dateService

    init(context: ActivityViewContext<BrewTimingAttributes>) {
        self.recipeName = context.attributes.recipeName
        self.state = context.state
    }

    init(recipeName: String, state: BrewTimingAttributes.ContentState) {
        self.recipeName = recipeName
        self.state = state
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                BrewWidgetHeader(title: recipeName)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Text("#\(state.currentPourIndex)")
                    .font(.title2.weight(.bold))
                Text("of \(state.totalPourCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(state.nextWaterAmount.gram))g")
                    .font(.title2.weight(.semibold))
                Text("next")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(timerInterval: state.progressRange, countsDown: false)
                .tint(.brown)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

#Preview("Live Activity in Lock Screen", as: .content, using: BrewTimingAttributes.preview) {
    BrewTimingLiveActivity()
} contentStates: {
    BrewTimingAttributes.ContentState.preview
}
