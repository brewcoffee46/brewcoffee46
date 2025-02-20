import BrewCoffee46Core
import Factory
import SwiftUI

struct Phase: Identifiable {
    var id = UUID()
    var index: Int
    var waterAmount: Double
    var dripAt: Double
}

struct PhaseListView: View {
    @Injected(\.getDripPhaseService) private var getDripPhaseService

    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel
    @Binding var progressTime: Double

    @State private var phaseList: [Phase] = []
    @State private var currentDripPhase: DripPhase = DripPhase.defaultValue()

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: .init(),
                    count: 3
                ),
                alignment: .center
            ) {
                Group {
                    Text("#")
                    Text("Water")
                    Text("Timing")
                }
                .font(Font.headline.weight(.bold))
            }
            ForEach(phaseList, id: \.id) { phase in
                let waterAmount = "\(String(format: "%.1f", phase.waterAmount))\(weightUnit)"
                LazyVGrid(
                    columns: Array(
                        repeating: .init(),
                        count: 3
                    ),
                    alignment: .center
                ) {
                    Group {
                        fontConfig(Text("\(phase.index + 1)"), phase: phase)
                        getDripPhaseService.doneOnGoingScheduled(
                            phase.index,
                            dripPhase: currentDripPhase,
                            done: AnyView(
                                HStack {
                                    Image(systemName: "hourglass.tophalf.filled")
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.primary)
                                    fontConfig(Text("\(waterAmount)"), phase: phase)
                                }),
                            onGoing: AnyView(
                                HStack {
                                    Image(systemName: "hourglass")
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                    fontConfig(Text("\(waterAmount)"), phase: phase)
                                }),
                            scheduled: AnyView(
                                HStack {
                                    Image(systemName: "hourglass.bottomhalf.filled")
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.primary)
                                    fontConfig(Text("\(waterAmount)"), phase: phase)
                                })
                        )
                        timingView(phase: phase)
                    }
                    .foregroundColor(appEnvironment.isTimerStarted ? .primary : .primary.opacity(0.5))
                }
            }
            .scrollTargetLayout()
        }
        .onChange(of: viewModel.currentConfig, initial: true) {
            updatePhaseList()
            currentDripPhase = getDripPhaseService.get(
                dripInfo: viewModel.dripInfo,
                progressTime: progressTime
            )
        }
        .onChange(of: progressTime) {
            currentDripPhase = getDripPhaseService.get(
                dripInfo: viewModel.dripInfo,
                progressTime: progressTime
            )
        }
        .scrollPosition(
            id: Binding<UUID?>(
                get: {
                    if phaseList.isEmpty {
                        return .none
                    } else {
                        let index =
                            switch currentDripPhase.dripPhaseType {
                            case .beforeDrip: 0
                            case .afterDrip: currentDripPhase.totalNumberOfDrip - 1
                            case .dripping(let i): i - 1
                            }

                        return .some(phaseList[index].id)
                    }
                },
                set: { _ in () }
            )
        )
    }

    private func updatePhaseList() {
        var newPhaseList: [Phase] = []
        for (i, info) in viewModel.dripInfo.dripTimings.enumerated() {
            newPhaseList.append(
                Phase(
                    index: i,
                    waterAmount: info.waterAmount,
                    dripAt: info.dripAt
                )
            )
        }
        phaseList = newPhaseList
    }

    private func fontConfig(_ t: Text, phase: Phase) -> some View {
        t.font(
            getDripPhaseService.doneOnGoingScheduled(
                phase.index,
                dripPhase: currentDripPhase,
                done: Font.headline.weight(.light),
                onGoing: Font.headline.weight(.bold),
                scheduled: Font.headline.weight(.light)
            )
        )
        .foregroundColor(
            getDripPhaseService.doneOnGoingScheduled(
                phase.index,
                dripPhase: currentDripPhase,
                done: .primary,
                onGoing: .accentColor,
                scheduled: .primary
            )
        )
    }

    private func timingView(phase: Phase) -> AnyView {
        let dripPhase = getDripPhaseService.get(
            dripInfo: viewModel.dripInfo,
            progressTime: progressTime
        )

        return getDripPhaseService.doneOnGoingNextScheduled(
            phase.index,
            dripPhase: dripPhase,
            done: AnyView(
                Image(systemName: "checkmark.circle.fill")
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.green)
            ),
            onGoing: AnyView(
                Image(systemName: "drop.fill")
                    .symbolEffect(.pulse, value: floor(progressTime / 4.0))
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            ),
            next: AnyView(
                Text(String(format: "%.1f", progressTime - phase.dripAt))
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .light)))
                    .frame(height: 24)
            ),
            scheduled: AnyView(
                Image(systemName: "checkmark")
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
            )
        )
    }
}

#if DEBUG
    struct PhaseListView_Preview: PreviewProvider {
        @ObservedObject static var viewModel: CurrentConfigViewModel = CurrentConfigViewModel()
        @State static var progressTime: Double = 90

        static var previews: some View {
            PhaseListView(progressTime: $progressTime)
                .environmentObject(AppEnvironment.init())
                .environmentObject(viewModel)
        }
    }
#endif
