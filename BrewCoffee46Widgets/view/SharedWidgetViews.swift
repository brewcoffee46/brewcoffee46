import BrewCoffee46Core
import FactoryKit
import SwiftUI
import WidgetKit

struct BrewWidgetHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Spacer()
            Image(systemName: "cup.and.saucer.fill")
                .foregroundStyle(.brown)
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            Spacer()
        }
    }
}

struct DripIndexView: View {
    let startedAt: Date
    let dripTimings: [DripTiming]
    let totalTime: MilliSecond

    @Injected(\.dateService) private var dateService
    @Injected(\.getDripPhaseService) private var getDripPhaseService
    @Injected(\.dripIndexTextFormatterService) private var dripIndexTextFormatterService

    var body: some View {
        HStack {
            Text("\(dripIndexTextFormatterService.dripText(currentDripIndex))")
                .font(.title2.weight(.bold))
            Text("of \(dripTimings.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var currentDripIndex: Int {
        let progressTime = dateService.now().timeIntervalSince(startedAt)

        return getDripPhaseService.get(
            dripTimings: dripTimings,
            totalTime: totalTime,
            progressTime: progressTime
        )
        .toInt()
    }
}

struct DripNextAmountView: View {
    let startedAt: Date
    let dripTimings: [DripTiming]
    let totalTime: MilliSecond

    @Injected(\.dateService) private var dateService
    @Injected(\.getDripPhaseService) private var getDripPhaseService

    var body: some View {
        HStack {
            Text("\(Int(dripTimings[currentDripIndex].waterAmount.gram))g")
                .font(.title2.weight(.semibold))
            Text("next")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var currentDripIndex: Int {
        let progressTime = dateService.now().timeIntervalSince(startedAt)

        return getDripPhaseService.get(
            dripTimings: dripTimings,
            totalTime: totalTime,
            progressTime: progressTime
        )
        .toInt()
    }
}

struct DripProgressView: View {
    let startedAt: Date
    let dripTimings: [DripTiming]
    let totalTime: MilliSecond

    @Injected(\.dateService) private var dateService
    @Injected(\.getDripPhaseService) private var getDripPhaseService

    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            ProgressView(timerInterval: wholeProgressRange, countsDown: false)
                .progressViewStyle(.linear)
                .tint(.brown)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .layoutPriority(1)
            Text(timerInterval: wholeProgressRange, countsDown: false)
                .font(.caption.monospacedDigit())
                .frame(width: 30, alignment: .trailing)
                .lineLimit(1)
            Spacer()
        }
    }

    var wholeProgressRange: ClosedRange<Date> {
        startedAt...startedAt.addingTimeInterval(totalTime.second)
    }

    var nextProgressRange: ClosedRange<Date> {
        let progressTime = dateService.now().timeIntervalSince(startedAt)

        let phase = getDripPhaseService.get(
            dripTimings: dripTimings,
            totalTime: totalTime,
            progressTime: progressTime
        )

        let currentDripIndex = phase.toInt()
        let currentDripAt =
            if phase.didStart() {
                startedAt.addingTimeInterval(dripTimings[currentDripIndex].dripAt.second)
            } else {
                startedAt
            }
        let finishedAt = startedAt.addingTimeInterval(totalTime.second)
        let nextTiming = dripTimings.dropFirst(currentDripIndex + 1).first

        return currentDripAt...(nextTiming.map { startedAt.addingTimeInterval($0.dripAt.second) } ?? finishedAt)
    }
}

#Preview("Live Activity in Lock Screen", as: .content, using: DripTimingAttributes.preview) {
    DripTimingLiveActivity()
} contentStates: {
    DripTimingAttributes.ContentState.defaultValue
}

#Preview("Dynamic Island(expanded)", as: .dynamicIsland(.expanded), using: DripTimingAttributes.preview) {
    DripTimingLiveActivity()
} contentStates: {
    DripTimingAttributes.ContentState.defaultValue
}

func brewTimeText(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}
