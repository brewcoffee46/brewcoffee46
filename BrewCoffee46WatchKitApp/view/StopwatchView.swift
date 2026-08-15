import BrewCoffee46Core
import FactoryKit
import Foundation
import SwiftUI

@MainActor
struct StopwatchView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: ConfigViewModel
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var extendedRuntimeSession = ExtendedRuntimeSession()

    @Injected(\.dateService) private var dateService
    @Injected(\.getDripPhaseService) private var getDripPhaseService
    @Injected(\.dripTimingNotificationService) private var dripTimingNotificationService
    @Injected(\.saveLoadTimerStartAtService) private var saveLoadTimerStartAtService
    @Injected(\.dripIndexTextFormatterService) private var dripIndexTextFormatterService

    @State var startAt: Date? = .none
    @State var isStop︎AlertPresented: Bool = false

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
                                    progressTime < viewModel.currentConfig.coffeeConfig.totalTimeSec ? .primary : .red
                                )
                            Spacer()
                            Text(String(format: "/ %3.0f sec", viewModel.currentConfig.coffeeConfig.totalTimeSec))
                                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)))
                                .fixedSize()
                                .frame(alignment: .bottom)
                        }
                        Spacer()
                        Button(action: {
                            if progressTime < viewModel.currentConfig.coffeeConfig.totalTimeSec {
                                isStop︎AlertPresented.toggle()
                            } else {
                                stopTimer()
                            }
                        }) {
                            Text("Stop")
                        }
                        .stopWatchStopAlertModifier($isStop︎AlertPresented, stopTimer)
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
                        appEnvironment.isTimerStarted = true

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
                                totalTimeSec: viewModel.currentConfig.coffeeConfig.totalTimeSec
                            )
                            result.forEach { registeredNotifications in
                                removeElapsedPendingNotifications(registeredNotifications, now: dateService.now())
                            }
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
            $viewModel.log
        )
    }

    private func showDripInfo(index: Int, totalDripCount: Int) -> some View {
        HStack {
            Text(
                String(
                    format: NSLocalizedString("watch kit app drip", comment: ""),
                    dripIndexTextFormatterService.dripText(index),
                    totalDripCount
                )
            )
            Spacer()
            Text(
                "\(roundCentesimal(Double(viewModel.dripInfo.dripTimings[index].waterAmount.gram)), specifier: "%.1f")\(weightUnit)"
            )
        }
    }

    private func progressValue(index: Int, totalDripCount: Int, progressTime: Double) -> Double {
        let currentDripAt = viewModel.dripInfo.dripTimings[index].dripAt
        let elapsedTime = progressTime - currentDripAt.second
        let duration: Double

        if index == totalDripCount - 1 {
            duration = (viewModel.currentConfig.coffeeConfig.totalTimeMilliSec - currentDripAt).second
        } else {
            let nextDripAt = viewModel.dripInfo.dripTimings[index + 1].dripAt
            duration = (nextDripAt - currentDripAt).second
        }

        guard duration > 0 else { return 0 }
        return elapsedTime / duration
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
                            ProgressView(
                                value: progressValue(
                                    index: index,
                                    totalDripCount: totalDripCount,
                                    progressTime: progressTime
                                )
                            )
                            .tint(.blue)
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

    private func removeElapsedPendingNotifications(_ registeredNotifications: [DripTimingNotification], now: Date) {
        guard let startAt else { return }

        let elapsedTime = now.timeIntervalSince(startAt)
        let elapsedNotifications = registeredNotifications.filter { elapsedTime >= $0.notifiedIn.second }
        dripTimingNotificationService.removePending(elapsedNotifications)
    }

    private func stopTimer() {
        appEnvironment.isTimerStarted = false

        dripTimingNotificationService.removePendingAll()

        WKInterfaceDevice.current().play(.success)
        self.startAt = .none
        saveLoadTimerStartAtService.deleteStartAt()

        extendedRuntimeSession.endSession()
    }
}
