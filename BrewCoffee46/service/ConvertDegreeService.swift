import BrewCoffee46Core
import Factory

protocol ConvertDegreeService {
    /// - Parameters:
    ///     - progressTime: seconds
    func fromProgressTime(
        _ config: Config,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ progressTime: Double
    ) -> Double

    /// - Returns: progress time (seconds).
    func toProgressTime(
        _ config: Config,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ degree: Double
    ) -> Double
}

final class ConvertDegreeServiceImpl: ConvertDegreeService, Sendable {
    func fromProgressTime(
        _ config: Config,
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
            return progressTime / config.steamingTimeSec * pointerInfo.pointerDegrees[1]
        } else {
            if config.firstWaterPercent < 1 && progressTime <= dripInfo.dripTimings[2].dripAt {
                // At 2nd shot where there are 2 shots on first 40% drip.
                return (progressTime - config.steamingTimeSec)
                    * (pointerInfo.pointerDegrees[2] - pointerInfo.pointerDegrees[1])
                    / (dripInfo.dripTimings[2].dripAt - config.steamingTimeSec) + pointerInfo.pointerDegrees[1]
            } else if config.firstWaterPercent < 1 {
                // After 2nd shot where there are 2 shots on first 40% drip.
                return
                    ((progressTime - dripInfo.dripTimings[2].dripAt)
                    / (config.totalTimeSec - dripInfo.dripTimings[2].dripAt))
                    * (360.0 - pointerInfo.pointerDegrees[2]) + pointerInfo.pointerDegrees[2]
            } else {
                // After 2nd shot where there are 1 shot on first 40% drip.
                return ((progressTime - config.steamingTimeSec) / (config.totalTimeSec - config.steamingTimeSec))
                    * (360.0 - pointerInfo.pointerDegrees[1]) + pointerInfo.pointerDegrees[1]
            }
        }
    }

    // The degree of 40% so `360 * 0.4`.
    private let fortyPercentDegree = 360 * 0.4

    func toProgressTime(
        _ config: Config,
        _ pointerInfo: PointerInfo,
        _ dripInfo: DripInfo,
        _ degree: Double
    ) -> Double {
        if degree > 360 {
            return config.totalTimeSec
        } else if degree <= pointerInfo.pointerDegrees[1] {
            // At 1st shot.
            return config.steamingTimeSec * degree / pointerInfo.pointerDegrees[1]
        } else {
            if config.firstWaterPercent < 1 && degree <= fortyPercentDegree {
                // At 2nd shot where there are 2 shots on first 40% drip.
                return (dripInfo.dripTimings[2].dripAt - config.steamingTimeSec)
                    * (degree - pointerInfo.pointerDegrees[1]) / (fortyPercentDegree - pointerInfo.pointerDegrees[1])
                    + config.steamingTimeSec
            } else if config.firstWaterPercent < 1 {
                // After 2nd shot where there are 2 shots on first 40% drip.
                return (config.totalTimeSec - dripInfo.dripTimings[2].dripAt) * (degree - fortyPercentDegree)
                    / (360 - pointerInfo.pointerDegrees[2]) + dripInfo.dripTimings[2].dripAt
            } else {
                // After 2nd shot where there are 2 shots on first 40% drip.
                return (config.totalTimeSec - dripInfo.dripTimings[1].dripAt) * (degree - fortyPercentDegree)
                    / (360 - pointerInfo.pointerDegrees[1]) + dripInfo.dripTimings[1].dripAt
            }
        }
    }
}

extension Container {
    var convertDegreeService: Factory<ConvertDegreeService> {
        Factory(self) { ConvertDegreeServiceImpl() }
    }
}
