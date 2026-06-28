import FactoryKit

/// `NormalizeSwitchesService` normalizes HARIO Switch states to the count required by a coffee recipe.
public protocol NormalizeSwitchesService: Sendable {
    /// Returns switches with the expected count, preserving existing values as much as possible.
    /// Missing switches are appended as `.open`, and extra switches are truncated.
    /// NOTE: `.open` represents the behavior of a regular dripper, where coffee keeps flowing through.
    func normalize(_ coffeeConfig: CoffeeConfig) -> [Switch]

    /// Returns the number of switches required by the first 40% split and 60% partitions.
    func expectedSwitchCount(_ coffeeConfig: CoffeeConfig) -> Int
}

public final class NormalizeSwitchesServiceImpl: NormalizeSwitchesService {
    public func normalize(_ coffeeConfig: CoffeeConfig) -> [Switch] {
        let expectedCount = expectedSwitchCount(coffeeConfig)

        if coffeeConfig.switches.count >= expectedCount {
            return Array(coffeeConfig.switches.prefix(expectedCount))
        }

        let additionalSwitches = Array(repeating: Switch.open, count: expectedCount - coffeeConfig.switches.count)
        return coffeeConfig.switches + additionalSwitches
    }

    public func expectedSwitchCount(_ coffeeConfig: CoffeeConfig) -> Int {
        // `firstWaterPercent` can become values like 1.0000000000000002 after Double calculations.
        let isEdgePercent =
            approximatelyEquals(coffeeConfig.firstWaterPercent, 0) || approximatelyEquals(coffeeConfig.firstWaterPercent, 1)

        let firstFortyPercentSwitchCount = isEdgePercent ? 1 : 2

        return firstFortyPercentSwitchCount + coffeeConfig.partitionsCountOf6
    }

    private func approximatelyEquals(_ lhs: Double, _ rhs: Double, tolerance: Double = 1e-9) -> Bool {
        abs(lhs - rhs) <= tolerance
    }
}

extension Container {
    public var normalizeSwitchesService: Factory<NormalizeSwitchesService> {
        Factory(self) { NormalizeSwitchesServiceImpl() }.cached
    }
}
