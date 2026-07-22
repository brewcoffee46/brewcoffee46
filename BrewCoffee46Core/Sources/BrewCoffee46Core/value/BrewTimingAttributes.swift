#if canImport(ActivityKit)
    import ActivityKit
    import Foundation

    @available(iOS 17.0, watchOS 11.0, *)
    public struct BrewTimingAttributes: ActivityAttributes, Sendable {
        public struct ContentState: Codable, Hashable, Sendable {
            public var startedAt: Date
            public var finishedAt: Date
            public var currentPourIndex: Int
            public var totalPourCount: Int
            public var nextPourAt: Date?
            public var nextWaterAmount: MilliGram
            public var totalWaterAmount: MilliGram

            public var progressRange: ClosedRange<Date> {
                startedAt...finishedAt
            }

            public init(
                startedAt: Date,
                finishedAt: Date,
                currentPourIndex: Int,
                totalPourCount: Int,
                nextPourAt: Date?,
                nextWaterAmount: MilliGram,
                totalWaterAmount: MilliGram
            ) {
                self.startedAt = startedAt
                self.finishedAt = finishedAt
                self.currentPourIndex = currentPourIndex
                self.totalPourCount = totalPourCount
                self.nextPourAt = nextPourAt
                self.nextWaterAmount = nextWaterAmount
                self.totalWaterAmount = totalWaterAmount
            }
        }

        public var recipeName: String
        public var totalTime: MilliSecond

        public init(recipeName: String, totalTime: MilliSecond) {
            self.recipeName = recipeName
            self.totalTime = totalTime
        }
    }
#endif  // canImport(ActivityKit)
