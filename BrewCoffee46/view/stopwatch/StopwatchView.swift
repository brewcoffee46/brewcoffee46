import AudioToolbox
import BrewCoffee46Core
import Combine
import Factory
import StoreKit
import SwiftUI

@MainActor
struct StopwatchView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview

    @State private var startAt: Date? {
        didSet {
            if let time = startAt {
                saveLoadTimerStartAtService
                    .saveStartAt(time)
                    .recoverWithErrorLog(&viewModel.errors)
            } else {
                saveLoadTimerStartAtService.deleteStartAt()
            }
        }
    }

    @State private var pointerInfo: PointerInfo = PointerInfo.defaultValue()

    private static let progressTimeInit: Double = -3

    @State private var progressTime: Double = progressTimeInit
    @State private var timer: AnyCancellable?
    @State private var hasRingingIndex: Int = 0
    @State private var isStop︎AlertPresented: Bool = false

    @Injected(\.requestReviewService) private var requestReviewService
    @Injected(\.dripTimingNotificationService) private var dripTimingNotificationService
    @Injected(\.getDripPhaseService) private var getDripPhaseService
    @Injected(\.saveLoadTimerStartAtService) private var saveLoadTimerStartAtService

    private let soundIdRing = SystemSoundID(1013)

    private let buttonBackground: some View =
        RoundedRectangle(cornerRadius: 10, style: .continuous)
        .stroke(lineWidth: 1)
        .padding(6)

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                GeometryReader { (geometry: GeometryProxy) in
                    ZStack(alignment: .center) {
                        ClockView(
                            progressTime: $progressTime,
                            pointerInfo: pointerInfo,
                            steamingTime: viewModel.currentConfig.steamingTimeSec,
                            totalTime: viewModel.currentConfig.totalTimeSec
                        )
                        .frame(height: geometry.size.width * 0.95)
                        stopWatchCountShow
                    }
                }
                GeometryReader { (geometry: GeometryProxy) in
                    VStack {
                        PhaseListView(progressTime: $progressTime)
                            .frame(height: geometry.size.height * 0.7)
                        Divider()
                        timerController
                    }
                }
            }
            .frame(minWidth: appEnvironment.minWidth)

            GeometryReader { (geometry: GeometryProxy) in
                VStack {
                    Group {
                        ZStack(alignment: .center) {
                            ClockView(
                                progressTime: $progressTime,
                                pointerInfo: pointerInfo,
                                steamingTime: viewModel.currentConfig.steamingTimeSec,
                                totalTime: viewModel.currentConfig.totalTimeSec
                            )
                            .frame(height: geometry.size.width * 0.95)
                            stopWatchCountShow
                        }
                    }
                    Divider()
                    PhaseListView(progressTime: $progressTime)
                    Divider()
                    timerController
                }
            }
        }
        .navigationTitle("navigation title stopwatch")
        .navigation(path: $appEnvironment.stopwatchPath)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                saveLoadTimerStartAtService.loadStartAt().forEach { (startAtOpt: Date?) in
                    if let time = startAtOpt {
                        startAt = time
                        startTimer()
                    }
                }
            }
        }
        .onChange(of: viewModel.dripInfo, initial: true) { _, newValue in
            pointerInfo = PointerInfo(newValue)
        }
    }

    private var stopWatchCountShow: some View {
        let progressInt = if progressTime < 0 { ceil(progressTime) } else { floor(progressTime) }

        return VStack(alignment: .center) {
            HStack(alignment: .center) {
                Text(
                    String(
                        format: "%03d.%02d ",  // The suffix space is required to alignment.
                        Int(progressInt),
                        Int((progressTime < 0 ? progressInt - progressTime : progressTime - progressInt) * 100))
                )
                .font(Font(UIFont.monospacedSystemFont(ofSize: 38, weight: .light)))
                .fixedSize()
                .foregroundColor(
                    progressTime < viewModel.currentConfig.totalTimeSec ? .primary : .red
                )
            }
            Text(String(format: "/ %3.0f sec", viewModel.currentConfig.totalTimeSec))
                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .light)))
                .frame(alignment: .bottom)
        }
    }

    private var timerController: some View {
        let stopButtonText = Text("Stop")
            .font(.system(size: 20))
            .frame(maxWidth: .infinity)
            .padding()
            .background(buttonBackground)

        return VStack {
            if self.timer == nil {
                Button(action: { startTimer() }) {
                    Text("Start")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonBackground)
                        .onAppear {
                            requestReviewService.check().forEach { result in
                                if result {
                                    requestReview()
                                }
                            }
                        }
                }
                .foregroundColor(.green)
            } else if progressTime <= viewModel.currentConfig.totalTimeSec {
                Button(action: { isStop︎AlertPresented.toggle() }) {
                    stopButtonText
                }
                .foregroundColor(.red)
                .alert("stop alert title", isPresented: $isStop︎AlertPresented) {
                    Button(role: .cancel, action: { isStop︎AlertPresented.toggle() }) {
                        Text("stop alert cancel")
                    }
                    Button(
                        role: .destructive,
                        action: {
                            isStop︎AlertPresented.toggle()
                            stopTimer()
                        }
                    ) {
                        Text("stop alert stop")
                    }
                } message: {
                    Text("stop alert message")
                }
            } else {
                Button(action: { stopTimer() }) {
                    stopButtonText
                }
                .foregroundColor(.red)
            }
        }
    }

    private func startTimer() {
        if self.timer == nil {
            UIApplication.shared.isIdleTimerDisabled = true
            self.appEnvironment.isTimerStarted = true
            self.startAt = Date()

            Task { @MainActor in
                await dripTimingNotificationService.registerNotifications(
                    dripTimings: viewModel.dripInfo.dripTimings,
                    firstDripAtSec: -StopwatchView.progressTimeInit,
                    totalTimeSec: viewModel.currentConfig.totalTimeSec
                )
            }

            self.timer =
                Timer
                .publish(every: interval, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    let now = Date()

                    if let time = self.startAt, progressTime < 0 {
                        progressTime = now.timeIntervalSince(time) + StopwatchView.progressTimeInit
                    } else {
                        if let time = startAt {
                            progressTime = now.timeIntervalSince(time) + StopwatchView.progressTimeInit
                            ringSound()

                            // For the battery life stop `isIdleTimerDisable` after 10 seconds from `totalTimeSec`.
                            if progressTime > (viewModel.currentConfig.totalTimeSec + 10.0) && UIApplication.shared.isIdleTimerDisabled {
                                UIApplication.shared.isIdleTimerDisabled = false
                            }
                        }
                    }
                }
        }
    }

    private func stopTimer() {
        if let t = self.timer {
            dripTimingNotificationService.removePendingAll()

            t.cancel()
            self.appEnvironment.isTimerStarted = false
            UIApplication.shared.isIdleTimerDisabled = false
            progressTime = StopwatchView.progressTimeInit
            self.timer = .none
            self.startAt = .none
            hasRingingIndex = 0
        }
    }

    private func ringSound() {
        let nth = getDripPhaseService.get(
            dripInfo: viewModel.dripInfo,
            progressTime: progressTime
        ).toInt()

        if nth > hasRingingIndex && progressTime <= viewModel.currentConfig.totalTimeSec {
            AudioServicesPlaySystemSound(soundIdRing)
            hasRingingIndex = nth
        }
    }
}

#if DEBUG
    struct StopwatchView_Previews: PreviewProvider {
        static var previews: some View {
            StopwatchView()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
        }
    }
#endif
