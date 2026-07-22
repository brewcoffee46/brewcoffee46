#if canImport(ActivityKit)
    import ActivityKit
    import Foundation

    @available(iOS 17.0, watchOS 11.0, *)
    public struct DripTimingAttributes: ActivityAttributes, Sendable, Equatable {
        public struct ContentState: Codable, Hashable, Sendable {}

        public var startedAt: Date
        public var recipeName: String
        public var coffeeBeansWeight: MilliGram
        public var totalWaterAmount: MilliGram
        public var dripTimings: [DripTiming]
        public var totalTime: MilliSecond

        public init(
            startedAt: Date,
            recipeName: String,
            coffeeBeansWeight: MilliGram,
            totalWaterAmount: MilliGram,
            dripTimings: [DripTiming],
            totalTime: MilliSecond
        ) {
            self.startedAt = startedAt
            self.recipeName = recipeName
            self.coffeeBeansWeight = coffeeBeansWeight
            self.totalWaterAmount = totalWaterAmount
            self.dripTimings = dripTimings
            self.totalTime = totalTime
        }
    }

    extension DripTimingAttributes.ContentState {
        public static let defaultValue: Self = .init()
    }
#endif  // canImport(ActivityKit)
