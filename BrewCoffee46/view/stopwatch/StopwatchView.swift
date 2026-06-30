import AudioToolbox
import BrewCoffee46Core
import Combine
import FactoryKit
import StoreKit
import SwiftUI
import TipKit

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

    // Do not ring for drip timings that were missed while the app was suspended or backgrounded.
    private let ringSoundAllowedDelaySec = 0.2

    @State private var rawCoffeeBeansWeight: Double = RawSetting.defaultValue().coffeeBeansWeight
    @State private var isDiscloseCoffeeBeansSetting: Bool = true
    @State private var notifications: [DripTimingNotification] = []

    @Injected(\.dateService) private var dateService
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
            // Landscape
            HStack {
                GeometryReader { (geometry: GeometryProxy) in
                    ZStack(alignment: .center) {
                        ClockView(
                            progressTime: $progressTime,
                            pointerInfo: pointerInfo,
                            steamingTime: viewModel.currentConfig.coffeeConfig.steamingTimeSec,
                            totalTime: viewModel.currentConfig.coffeeConfig.totalTimeSec
                        )
                        .frame(height: geometry.size.width * 0.9)
                    }
                }
                GeometryReader { (geometry: GeometryProxy) in
                    VStack {
                        PhaseListView(progressTime: $progressTime)
                            .frame(height: isDiscloseCoffeeBeansSetting ? geometry.size.height * 0.3 : geometry.size.height * 0.6)
                        Divider()
                        coffeeBeansPicker
                        Divider()
                        timerController
                    }
                }
            }
            .frame(minWidth: appEnvironment.minWidth)

            // Portrait
            GeometryReader { (geometry: GeometryProxy) in
                VStack {
                    Group {
                        ZStack(alignment: .center) {
                            ClockView(
                                progressTime: $progressTime,
                                pointerInfo: pointerInfo,
                                steamingTime: viewModel.currentConfig.coffeeConfig.steamingTimeSec,
                                totalTime: viewModel.currentConfig.coffeeConfig.totalTimeSec
                            )
                            .frame(height: geometry.size.width * 0.85)
                        }
                    }
                    Divider()
                    coffeeBeansPicker
                    Divider()
                    PhaseListView(progressTime: $progressTime)
                    Divider()
                    timerController
                }
            }
        }
        .navigation(
            path: $appEnvironment.stopwatchPath,
            title: "navigation title stopwatch"
        )
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                saveLoadTimerStartAtService.loadStartAt().forEach { (startAtOpt: Date?) in
                    if let time = startAtOpt {
                        startAt = time
                        startTimer()
                    }
                }
                removeElapsedPendingNotifications(notifications, now: dateService.now())
            }
        }
        .onChange(of: viewModel.dripInfo, initial: true) { _, newValue in
            pointerInfo = PointerInfo(newValue)
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
                .popoverTip(StopwatchTip(), arrowEdge: .leading)
            } else {
                Button(action: {
                    if progressTime < viewModel.currentConfig.coffeeConfig.totalTimeSec {
                        isStop︎AlertPresented.toggle()
                    } else {
                        stopTimer()
                    }
                }) {
                    stopButtonText
                }
                .foregroundColor(.red)
                .stopWatchStopAlertModifier($isStop︎AlertPresented, stopTimer)
            }
        }
        .sensoryFeedback(.impact, trigger: self.appEnvironment.isTimerStarted)
    }

    private func startTimer() {
        if self.timer == nil {
            UIApplication.shared.isIdleTimerDisabled = true
            withAnimation {
                self.appEnvironment.isTimerStarted = true
            }
            self.startAt = dateService.now()

            Task { @MainActor in
                let result = await dripTimingNotificationService.registerNotifications(
                    dripTimings: viewModel.dripInfo.dripTimings,
                    firstDripAtSec: -StopwatchView.progressTimeInit,
                    totalTimeSec: viewModel.currentConfig.coffeeConfig.totalTimeSec
                )
                result.forEach { notifications = $0 }
                result.recoverWithErrorLog(&viewModel.errors)
            }

            self.timer =
                Timer
                .publish(every: interval, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    let now = dateService.now()

                    if let time = self.startAt, progressTime < 0 {
                        progressTime = now.timeIntervalSince(time) + StopwatchView.progressTimeInit
                    } else {
                        if let time = startAt {
                            let previousProgressTime = progressTime
                            progressTime = now.timeIntervalSince(time) + StopwatchView.progressTimeInit
                            ringSound(previousProgressTime: previousProgressTime)

                            // For the battery life stop `isIdleTimerDisable` after 10 seconds from `totalTimeSec`.
                            if progressTime > (viewModel.currentConfig.coffeeConfig.totalTimeSec + 10.0) && UIApplication.shared.isIdleTimerDisabled {
                                UIApplication.shared.isIdleTimerDisabled = false
                            }
                        }
                    }
                }
        }
    }

    private func removeElapsedPendingNotifications(_ registeredNotifications: [DripTimingNotification], now: Date) {
        guard let startAt else { return }

        let elapsedTime = now.timeIntervalSince(startAt)
        let futureNotifications = registeredNotifications.filter { elapsedTime < $0.notifiedIn.second }
        // Keep state in sync with pending notifications so already-removed IDs are not removed again after the next resume.
        notifications = futureNotifications

        let elapsedNotifications = registeredNotifications.filter { elapsedTime >= $0.notifiedIn.second }
        dripTimingNotificationService.removePending(elapsedNotifications)
    }

    private func stopTimer() {
        if let t = self.timer {
            dripTimingNotificationService.removePendingAll()

            t.cancel()
            withAnimation {
                self.appEnvironment.isTimerStarted = false
            }
            UIApplication.shared.isIdleTimerDisabled = false
            progressTime = StopwatchView.progressTimeInit
            self.timer = .none
            self.startAt = .none
            hasRingingIndex = 0
        }
    }

    private func ringSound(previousProgressTime: Double) {
        let nth = getDripPhaseService.get(
            dripInfo: viewModel.dripInfo,
            progressTime: progressTime
        ).toInt()

        guard nth > hasRingingIndex,
            nth < viewModel.dripInfo.dripTimings.count,
            progressTime <= viewModel.currentConfig.coffeeConfig.totalTimeSec
        else {
            return
        }

        let targetDripAt = viewModel.dripInfo.dripTimings[nth].dripAt.second
        let didJustPassTarget =
            previousProgressTime < targetDripAt
            && targetDripAt <= progressTime
            && progressTime - targetDripAt <= ringSoundAllowedDelaySec

        if didJustPassTarget {
            AudioServicesPlaySystemSound(soundIdRing)
        }
        hasRingingIndex = nth
    }

    private var coffeeBeansPicker: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "slider.horizontal.3")
                Text(viewModel.currentConfig.coffeeConfig.note ??? NSLocalizedString("config note empty string", comment: ""))
                Spacer()
                Spacer()
                Spacer()
                Button(action: {
                    withAnimation {
                        isDiscloseCoffeeBeansSetting.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(Color.accentColor)
                Spacer()
            }
            NumberPickerView(
                digit: numberPickerDigit,
                max: coffeeBeansWeightMaxGram,
                min: coffeeBeansWeightMinGram,
                target: $rawCoffeeBeansWeight,
                isDisable: $appEnvironment.isTimerStarted
            )
            .onChange(of: viewModel.currentConfig.globalConfig.coffeeBeansWeightMg, initial: true) { (_, newValue) in
                if viewModel.currentConfig.globalConfig.coffeeBeansWeightG != rawCoffeeBeansWeight {
                    rawCoffeeBeansWeight = viewModel.currentConfig.globalConfig.coffeeBeansWeightG
                }
            }
            .onChange(of: rawCoffeeBeansWeight) { (_, newValue) in
                if rawCoffeeBeansWeight != viewModel.currentConfig.globalConfig.coffeeBeansWeightG {
                    viewModel.currentConfig.globalConfig.coffeeBeansWeightMg = MilliGram.fromGram(newValue)
                }
            }
            .frame(
                height: isDiscloseCoffeeBeansSetting && !appEnvironment.isTimerStarted ? nil : 0,
                alignment: .top
            )
            .clipped()
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
