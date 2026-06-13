import FactoryKit
import SwiftUI

/// # A scale.
///
/// These implementation refer from: https://talk.objc.io/episodes/S01E192-analog-clock
struct ClockView: View {
    @Injected(\.convertDegreeService) private var convertDegreeService
    @Injected(\.getDripPhaseService) private var getDripPhaseService

    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    private let density: Int = 40 * 4
    private let markInterval: Int = 10

    @Binding var progressTime: Double
    private let pointerInfo: PointerInfo

    @State var endDegree: Double = 0.0
    @State var endDegreeEveryStep: Double = 0.0
    @State var nth: Int = -1
    @State var nextDripAt: Double = 0.0

    var steamingTime: Double
    var totalTime: Double

    init(progressTime: Binding<Double>, pointerInfo: PointerInfo, steamingTime: Double, totalTime: Double) {
        self._progressTime = progressTime
        self.pointerInfo = pointerInfo
        self.steamingTime = steamingTime
        self.totalTime = totalTime
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                GeometryReader { (geometry: GeometryProxy) in
                    VStack {
                        Spacer()
                        Spacer()
                        mainClockView.frame(minWidth: appEnvironment.minWidth)
                        Spacer()
                        Spacer()
                    }
                }
            }
            .frame(minWidth: appEnvironment.minWidth)
            GeometryReader { (geometry: GeometryProxy) in
                mainClockView.frame(maxHeight: geometry.size.width * 0.9)
            }
        }
    }

    private var mainClockView: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                tick(
                    density: density,
                    markInterval: markInterval,
                    marking: { (angle: Double) in
                        convertDegreeService.toProgressTime(viewModel.currentConfig.coffeeConfig, pointerInfo, viewModel.dripInfo, angle)
                    }
                )
                ForEach(
                    Array(zip(pointerInfo.pointerDegrees, viewModel.dripInfo.dripTimings).enumerated()),
                    id: \.0
                ) { i, item in
                    let (degree, dripTiming) = item

                    PointerView(
                        waterAmount: dripTiming.waterAmount.gram,
                        degree: degree,
                        isOnGoing: nth >= i && appEnvironment.isTimerStarted && progressTime > 0
                    )
                }
                ArcView(
                    progressTime: $progressTime,
                    endDegrees: $endDegree,
                    size: geometry.size,
                    scale: 0.8
                )
                .onChange(of: progressTime, initial: true) { _, newValue in
                    let phase =
                        getDripPhaseService
                        .get(
                            dripInfo: viewModel.dripInfo,
                            progressTime: newValue
                        )
                    nth = phase.toInt()

                    switch phase.dripPhaseType {
                    case .afterDrip:
                        // To presentation we need to fix `nth`.
                        nth = phase.totalNumberOfDrip - 1
                        endDegree = 360
                        endDegreeEveryStep = 360
                    case .dripping(_):
                        endDegree = convertDegreeService.fromProgressTime(
                            viewModel.currentConfig.coffeeConfig,
                            pointerInfo,
                            viewModel.dripInfo,
                            newValue
                        )

                        let currentDripAt = viewModel.dripInfo.dripTimings[nth].dripAt.second
                        nextDripAt =
                            nth + 1 < phase.totalNumberOfDrip
                            ? viewModel.dripInfo.dripTimings[nth + 1].dripAt.second : viewModel.currentConfig.coffeeConfig.totalTimeSec
                        let currentDripDuration = nextDripAt - currentDripAt

                        endDegreeEveryStep = 360.0 * (newValue - currentDripAt) / currentDripDuration
                    case .beforeDrip:
                        nth = -1
                        endDegree = (ceil(newValue) - newValue) * 360
                        endDegreeEveryStep = 0.0
                        nextDripAt = viewModel.dripInfo.dripTimings[1].dripAt.second
                    }
                }
                VStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    GeometryReader { (geometry: GeometryProxy) in
                        ZStack {
                            tick(
                                density: 40,
                                markInterval: 10,
                                scale: 0.2,
                                marking: { (angle: Double) in
                                    if angle == 360 {
                                        nextDripAt
                                    } else {
                                        .none
                                    }
                                }
                            )
                            ArcView(
                                progressTime: $progressTime,
                                endDegrees: $endDegreeEveryStep,
                                size: geometry.size,
                                scale: 0.55
                            )
                            stopWatchNthText
                        }
                    }
                    .frame(maxHeight: geometry.size.width * 0.25)
                    Spacer()
                }
                VStack {
                    Spacer()
                    Spacer()
                    stopWatchCountShow
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
        }
    }

    // Print oblique squares as divisions of a scale.
    private func tick(
        density: Int,
        markInterval: Int,
        scale: Double = 1,
        marking: @escaping (Double) -> Double?
    ) -> some View {
        ZStack {
            ForEach(1...(density), id: \.self) { t in
                let angle: Double = Double(t) / Double(density) * 360
                let degree = convertDegreeService.fromProgressTime(
                    viewModel.currentConfig.coffeeConfig, pointerInfo, viewModel.dripInfo, progressTime)
                let isMark: Bool = t % markInterval == 0

                VStack {
                    Group {
                        if isMark {
                            if let mark = marking(angle) {
                                Text(String(format: "%.0f", round(mark)))
                            } else {
                                Text(" ")
                            }
                        } else {
                            Text(" ")
                        }
                    }
                    .font(.system(size: 10).weight(.light))
                    .fixedSize()
                    .frame(width: 20)
                    .foregroundColor(
                        progressTime < 0 || !appEnvironment.isTimerStarted || angle > degree ? .primary.opacity(0.4) : .accentColor)
                    Rectangle()
                        .fill(Color.primary)
                        .opacity(isMark ? 0.5 : 0.3)
                        .frame(width: 1, height: 40 * scale)
                    Spacer()
                }
                .rotationEffect(
                    Angle.degrees(angle)
                )
            }
        }
    }

    private var stopWatchNthText: some View {
        Text("#\(nth + 1)")
            .font(Font(UIFont.monospacedSystemFont(ofSize: 17, weight: .thin)))
    }

    private var stopWatchCountShow: some View {
        let progressInt = if progressTime < 0 { ceil(progressTime) } else { floor(progressTime) }

        return VStack(alignment: .center) {
            HStack(alignment: .center) {
                Text(
                    String(
                        format: "%03d.%01d ",  // The suffix space is required to alignment.
                        Int(progressInt),
                        Int((progressTime < 0 ? progressInt - progressTime : progressTime - progressInt) * 10))
                )
                .font(Font(UIFont.monospacedSystemFont(ofSize: 38, weight: .light)))
                .fixedSize()
                .foregroundColor(
                    progressTime < viewModel.currentConfig.coffeeConfig.totalTimeSec ? .primary : .red
                )
            }
            Text(String(format: "/ %3.0f sec", viewModel.currentConfig.coffeeConfig.totalTimeSec))
                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .light)))
                .frame(alignment: .bottom)
        }
    }

}

#if DEBUG
    struct ScaleView_Previews: PreviewProvider {
        @ObservedObject static var appEnvironment: AppEnvironment = .init()
        @ObservedObject static var viewModel: CurrentConfigViewModel = CurrentConfigViewModel()
        @State static var progressTime: Double = 55.123

        static var previews: some View {
            appEnvironment.isTimerStarted = true

            return VStack {
                Spacer()
                GeometryReader { (geometry: GeometryProxy) in
                    ClockView(
                        progressTime: $progressTime,
                        pointerInfo: PointerInfo.defaultValue(),
                        steamingTime: 50,
                        totalTime: 180
                    )
                    .frame(height: geometry.size.width * 0.8)
                }
                Spacer()
            }
            .environmentObject(appEnvironment)
            .environmentObject(viewModel)
        }
    }
#endif
