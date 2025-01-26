import Factory
import SwiftUI

/// # A scale.
///
/// These implementation refer from: https://talk.objc.io/episodes/S01E192-analog-clock
struct ClockView: View {
    @Injected(\.convertDegreeService) private var convertDegreeService
    @Injected(\.getDripPhaseService) private var getDripPhaseService

    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    private let density: Int = 40
    private let markInterval: Int = 10

    @Binding var progressTime: Double
    private let pointerInfo: PointerInfo

    @State var endDegree: Double

    var steamingTime: Double
    var totalTime: Double

    init(progressTime: Binding<Double>, pointerInfo: PointerInfo, steamingTime: Double, totalTime: Double) {
        self._progressTime = progressTime
        self.pointerInfo = pointerInfo
        self.endDegree = (ceil(progressTime.wrappedValue) - progressTime.wrappedValue) * 365
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
        ZStack {
            ForEach(0..<(self.density * 4), id: \.self) { t in
                self.tick(tick: t)
            }
            ZStack {
                GeometryReader { (geometry: GeometryProxy) in
                    ForEach(
                        Array(zip(pointerInfo.pointerDegrees, viewModel.dripInfo.dripTimings).enumerated()),
                        id: \.0
                    ) { i, item in
                        let (degree, dripTiming) = item
                        let isCurrentPhaseAfterOrEqualIndex =
                            getDripPhaseService
                            .get(
                                dripInfo: viewModel.dripInfo,
                                progressTime: progressTime
                            )
                            .toInt() >= i

                        ZStack {
                            PointerView(
                                waterAmount: dripTiming.waterAmount,
                                degree: degree,
                                isOnGoing: isCurrentPhaseAfterOrEqualIndex && appEnvironment.isTimerStarted && progressTime > 0
                            )
                        }
                    }
                    ArcView(
                        progressTime: $progressTime,
                        endDegrees: $endDegree,
                        size: geometry.size
                    )
                    .onChange(of: progressTime) { _, newValue in
                        if newValue < 0 {
                            endDegree = (ceil(newValue) - newValue) * 365
                        } else {
                            endDegree = convertDegreeService.fromProgressTime(
                                viewModel.currentConfig,
                                pointerInfo,
                                viewModel.dripInfo,
                                newValue
                            )
                        }
                    }
                }
            }
        }
    }

    // Print oblique squares as divisions of a scale.
    private func tick(tick: Int) -> some View {
        let angle: Double = Double(tick) / Double(self.density * 4) * 360
        let degree = convertDegreeService.fromProgressTime(viewModel.currentConfig, pointerInfo, viewModel.dripInfo, progressTime)
        let isMark: Bool = tick % markInterval == 0
        let caption = convertDegreeService.toProgressTime(viewModel.currentConfig, pointerInfo, viewModel.dripInfo, angle)

        return VStack {
            Text(isMark ? String(format: "%.0f", round(caption)) : " ")
                .font(.system(size: 10).weight(.light))
                .fixedSize()
                .frame(width: 20)
                .foregroundColor(
                    progressTime < 0 || !appEnvironment.isTimerStarted || angle > degree ? .primary.opacity(0.4) : .accentColor)
            Rectangle()
                .fill(Color.primary)
                .opacity(isMark ? 0.5 : 0.3)
                .frame(width: 1, height: isMark ? 40 : 40)
            Spacer()
        }
        .rotationEffect(
            Angle.degrees(angle)
        )
    }

}

#if DEBUG
    struct ScaleView_Previews: PreviewProvider {
        @ObservedObject static var appEnvironment: AppEnvironment = .init()
        @ObservedObject static var viewModel: CurrentConfigViewModel = CurrentConfigViewModel()
        @State static var progressTime: Double = 55

        static var previews: some View {
            appEnvironment.isTimerStarted = true

            return ClockView(
                progressTime: $progressTime,
                pointerInfo: PointerInfo.defaultValue(),
                steamingTime: 50,
                totalTime: 180
            )
            .environmentObject(appEnvironment)
            .environmentObject(viewModel)
        }
    }
#endif
