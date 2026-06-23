import BrewCoffee46Core
import FactoryKit

protocol ConvertDegreeService {
    /// - Parameters:
    ///     - progressTime: seconds
    func fromProgressTime(
        _ config: CoffeeConfig,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ progressTime: Double
    ) -> Double

    /// - Returns: progress time (seconds).
    func toProgressTime(
        _ config: CoffeeConfig,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ degree: Double
    ) -> Double
}

final class ConvertDegreeServiceImpl: ConvertDegreeService, Sendable {
    // The degree of 40% so `360 * 0.4`.
    private let fortyPercentDegree = 360 * 0.4

    func fromProgressTime(
        _ config: CoffeeConfig,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ progressTime: Double
    ) -> Double {
        if progressTime < 0 {
            return 0
        } else if progressTime > config.totalTimeSec {
            return 360
        } else if progressTime <= config.steamingTimeSec {
            // In this case, at 1st shot.
            return convert(
                progressTime,
                from: 0,
                to: config.steamingTimeSec,
                mappedFrom: 0,
                mappedTo: pointerInfo.pointerDegrees[1]
            )
        } else if config.firstWaterPercent < 1 && progressTime <= dripInfo.dripTimings[2].dripAt.second {
            // At 2nd shot where there are 2 shots on first 40% drip.
            return convert(
                progressTime,
                from: config.steamingTimeSec,
                to: dripInfo.dripTimings[2].dripAt.second,
                mappedFrom: pointerInfo.pointerDegrees[1],
                mappedTo: pointerInfo.pointerDegrees[2]
            )
        } else if config.firstWaterPercent < 1 {
            // After 2nd shot where there are 2 shots on first 40% drip.
            return convert(
                progressTime,
                from: dripInfo.dripTimings[2].dripAt.second,
                to: config.totalTimeSec,
                mappedFrom: pointerInfo.pointerDegrees[2],
                mappedTo: 360
            )
        } else {
            // After 2nd shot where there is 1 shot on first 40% drip.
            return convert(
                progressTime,
                from: config.steamingTimeSec,
                to: config.totalTimeSec,
                mappedFrom: pointerInfo.pointerDegrees[1],
                mappedTo: 360
            )
        }
    }

    func toProgressTime(
        _ config: CoffeeConfig,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ degree: Double
    ) -> Double {
        if degree > 360 {
            return config.totalTimeSec
        } else if degree <= pointerInfo.pointerDegrees[1] {
            // At 1st shot.
            return convert(
                degree,
                from: 0,
                to: pointerInfo.pointerDegrees[1],
                mappedFrom: 0,
                mappedTo: config.steamingTimeSec
            )
        } else if config.firstWaterPercent < 1 && degree <= fortyPercentDegree {
            // At 2nd shot where there are 2 shots on first 40% drip.
            return convert(
                degree,
                from: pointerInfo.pointerDegrees[1],
                to: fortyPercentDegree,
                mappedFrom: config.steamingTimeSec,
                mappedTo: dripInfo.dripTimings[2].dripAt.second
            )
        } else if config.firstWaterPercent < 1 {
            // After 2nd shot where there are 2 shots on first 40% drip.
            return convert(
                degree,
                from: fortyPercentDegree,
                to: 360,
                mappedFrom: dripInfo.dripTimings[2].dripAt.second,
                mappedTo: config.totalTimeSec
            )
        } else {
            // After 2nd shot where there is 1 shot on first 40% drip.
            return convert(
                degree,
                from: fortyPercentDegree,
                to: 360,
                mappedFrom: dripInfo.dripTimings[1].dripAt.second,
                mappedTo: config.totalTimeSec
            )
        }
    }

    private func convert(
        _ value: Double,
        from sourceStart: Double,
        to sourceEnd: Double,
        mappedFrom targetStart: Double,
        mappedTo targetEnd: Double
    ) -> Double {
        guard sourceStart != sourceEnd else { return targetStart }

        let progressValue = (value - sourceStart) / (sourceEnd - sourceStart)
        return progressValue * (targetEnd - targetStart) + targetStart
    }
}

extension Container {
    var convertDegreeService: Factory<ConvertDegreeService> {
        Factory(self) { ConvertDegreeServiceImpl() }.cached
    }
}
