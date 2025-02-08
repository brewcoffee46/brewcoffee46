public struct DripTiming: Equatable, Sendable {
    public let waterAmount: Double  // gram
    public let dripAt: Double  // sec

    public init(waterAmount: Double, dripAt: Double) {
        self.waterAmount = waterAmount
        self.dripAt = dripAt
    }
}

public struct DripInfo: Equatable {
    public let dripTimings: [DripTiming]
    public let waterAmount: WaterAmount
    public let totalTimeSec: Double

    public init(dripTimings: [DripTiming], waterAmount: WaterAmount, totalTimeSec: Double) {
        self.dripTimings = dripTimings
        self.waterAmount = waterAmount
        self.totalTimeSec = totalTimeSec
    }
}

extension DripInfo {
    static public func defaultValue() -> DripInfo {
        DripInfo(
            dripTimings: [
                DripTiming(waterAmount: 90.0, dripAt: 0.0),
                DripTiming(waterAmount: 180.0, dripAt: 45.0),
                DripTiming(waterAmount: 270.0, dripAt: 86.25),
                DripTiming(waterAmount: 360.0, dripAt: 127.5),
                DripTiming(waterAmount: 450.0, dripAt: 168.75),
            ],
            waterAmount: WaterAmount.defaultValue(),
            totalTimeSec: Config.defaultValue().totalTimeSec
        )
    }
}
