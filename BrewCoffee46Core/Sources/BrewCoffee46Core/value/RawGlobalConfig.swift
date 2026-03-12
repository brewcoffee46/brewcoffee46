public struct RawGlobalConfig: Equatable, Hashable {
    public var coffeeBeansWeightG: Double

    public init(coffeeBeansWeightMg: UInt64) {
        self.coffeeBeansWeightG = roundCentesimal(Double(coffeeBeansWeightMg) / 1000)
    }
}
