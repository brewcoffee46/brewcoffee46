import BrewCoffee46Core
import Factory
import Foundation
import SwiftUI

@MainActor
struct StopwatchView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var extendedRuntimeSession = ExtendedRuntimeSession()

    @Injected(\.dateService) private var dateService
    @Injected(\.getDripPhaseService) private var getDripPhaseService
    @Injected(\.dripTimingNotificationService) private var dripTimingNotificationService
    @Injected(\.saveLoadTimerStartAtService) private var saveLoadTimerStartAtService

    @State var startAt: Date? = .none

    private let countDownInit: Double = 3.0

    var body: some View {
        VStack {
            if let startAt {
                TimelineView(.periodic(from: startAt, by: interval)) { timeline in
                    let progressTime: Double = timeline.date.timeIntervalSince(startAt) - countDownInit
                    let currentPhase: Int = getDripPhaseService.get(
                        dripInfo: viewModel.dripInfo,
                        progressTime: progressTime
                    ).toInt()

                    VStack {
                        if progressTime >= 0 {
                            progressView(
                                currentPhase: currentPhase,
                                totalDripCount: viewModel.dripInfo.dripTimings.count,
                                progressTime: progressTime
                            )
                            .onChange(of: currentPhase) {
                                if currentPhase < viewModel.dripInfo.dripTimings.count {
                                    WKInterfaceDevice.current().play(.notification)
                                } else {
                                    WKInterfaceDevice.current().play(.stop)
                                }
                            }
                        } else {
                            VStack {
                                showDripInfo(index: 0, totalDripCount: viewModel.dripInfo.dripTimings.count)
                                ProgressView(value: abs(progressTime) / countDownInit)
                                    .tint(.green)
                            }
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Text(String(format: "%.1f ", progressTime))
                                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)))
                                .fixedSize()
                                .frame(alignment: .bottom)
                                .foregroundColor(
                                    progressTime < viewModel.currentConfig.totalTimeSec ? .primary : .red
                                )
                            Spacer()
                            Text(String(format: "/ %3.0f sec", viewModel.currentConfig.totalTimeSec))
                                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)))
                                .fixedSize()
                                .frame(alignment: .bottom)
                        }
                        Spacer()
                        Button(action: {
                            dripTimingNotificationService.removePendingAll()

                            WKInterfaceDevice.current().play(.success)
                            self.startAt = .none
                            saveLoadTimerStartAtService.deleteStartAt()

                            extendedRuntimeSession.endSession()
                        }) {
                            Text("Stop")
                        }
                        .frame(maxHeight: 20)
                        .foregroundColor(.red)
                    }
                }
            } else {
                VStack {
                    progressView(
                        currentPhase: -1,  // It means that the stopwatch has not started yet.
                        totalDripCount: viewModel.dripInfo.dripTimings.count,
                        progressTime: -countDownInit
                    )
                    Spacer()
                    Button(action: {
                        extendedRuntimeSession.startSession()
                        WKInterfaceDevice.current().play(.success)
                        let now = dateService.now()
                        self.startAt = .some(now)

                        saveLoadTimerStartAtService
                            .saveStartAt(now)
                            .recoverWithErrorLog(&viewModel.log)

                        Timer.scheduledTimer(
                            withTimeInterval: countDownInit,
                            repeats: false
                        ) { _ in
                            WKInterfaceDevice.current().play(.notification)
                            WKInterfaceDevice.current().play(.notification)
                        }

                        Task { @MainActor in
                            let result = await dripTimingNotificationService.registerNotifications(
                                dripTimings: viewModel.dripInfo.dripTimings,
                                firstDripAtSec: countDownInit,
                                totalTimeSec: viewModel.currentConfig.totalTimeSec
                            )
                            result.recoverWithErrorLog(&viewModel.log)
                        }
                    }) {
                        Text("Start")
                    }
                    .frame(maxHeight: 20)
                    .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("navigation title stopwatch")
        // I don't know the reason to set `initial: true` but if not set then
        // `saveLoadTimerStartAtService` will not be called.
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                saveLoadTimerStartAtService.loadStartAt().forEach { (startAtOpt: Date?) in
                    if let time = startAtOpt {
                        startAt = time
                    }
                }
            }
        }
        .currentConfigSaveLoadModifier(
            $viewModel.currentConfig,
            // For now, there is no load & save function on WatchKit App, so
            // it's OK that `lastUpdateAt` is always `.none`.
            Binding(
                get: { .none },
                set: { _ in () }
            ),
            $viewModel.log
        )
    }

    private func showDripInfo(index: Int, totalDripCount: Int) -> some View {
        HStack {
            switch index {
            case 0:
                Text(String(format: NSLocalizedString("watch kit app 1st drip", comment: ""), totalDripCount))
            case 1:
                Text(String(format: NSLocalizedString("watch kit app 2nd drip", comment: ""), totalDripCount))
            case 2:
                Text(String(format: NSLocalizedString("watch kit app 3rd drip", comment: ""), totalDripCount))
            default:
                Text(String(format: NSLocalizedString("watch kit app after 4th drip suffix", comment: ""), index + 1, totalDripCount))
            }
            Spacer()
            Text(
                "\(String(format: "%.1f", roundCentesimal(viewModel.dripInfo.dripTimings[index].waterAmount)))\(weightUnit)"
            )
        }
    }

    private func progressView(
        currentPhase: Int,
        totalDripCount: Int,
        progressTime: Double
    ) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(viewModel.dripInfo.dripTimings.enumerated()), id: \.offset) { index, dripTiming in
                    VStack {
                        showDripInfo(index: index, totalDripCount: totalDripCount)
                        if index == currentPhase {
                            if index == totalDripCount - 1 {
                                ProgressView(
                                    value: (progressTime - viewModel.dripInfo.dripTimings[index].dripAt)
                                        / (viewModel.currentConfig.totalTimeSec - viewModel.dripInfo.dripTimings[index].dripAt)
                                )
                                .tint(.blue)
                            } else {
                                ProgressView(
                                    value: (progressTime - viewModel.dripInfo.dripTimings[index].dripAt)
                                        / (viewModel.dripInfo.dripTimings[index + 1].dripAt - viewModel.dripInfo.dripTimings[index].dripAt)
                                )
                                .tint(.blue)
                            }
                        } else if index > currentPhase {
                            ProgressView(value: 0.0).tint(.blue)
                        } else {
                            ProgressView(value: 1.0).tint(.green)
                        }
                    }
                    .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(
            id: Binding(
                get: {
                    // The scroll position is next to the `currentPhase` because
                    // the user should know the next drip information.
                    currentPhase + 1
                },
                set: { _ in () }
            )
        )
    }
}
