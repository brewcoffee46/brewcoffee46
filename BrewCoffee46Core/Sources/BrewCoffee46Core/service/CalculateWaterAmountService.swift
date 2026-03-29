import Factory

/// ### This interface is a representation of the calculation of water amount.
public protocol CalculateWaterAmountService: Sendable {
    func calculate(_ appConfig: AppConfig) -> WaterAmount
}

public final class CalculateWaterAmountServiceImpl: CalculateWaterAmountService {
    public func calculate(_ appConfig: AppConfig) -> WaterAmount {
        let totalWaterAmountG = appConfig.totalWaterAmountG()
        let fortyPercentWaterAmountG = totalWaterAmountG * 0.4
        let fortyPercent = (
            fortyPercentWaterAmountG * appConfig.coffeeConfig.firstWaterPercent,
            fortyPercentWaterAmountG * (1 - appConfig.coffeeConfig.firstWaterPercent)
        )
        let sixtyAmount = totalWaterAmountG * 0.6
        var sixtyPercent = NonEmptyArray(
            sixtyAmount / Double(appConfig.coffeeConfig.partitionsCountOf6),
            []
        )
        for _ in 0..<(appConfig.coffeeConfig.partitionsCountOf6 - 1) {
            sixtyPercent.append(sixtyAmount / Double(appConfig.coffeeConfig.partitionsCountOf6))
        }

        return WaterAmount(fortyPercent: fortyPercent, sixtyPercent: sixtyPercent)
    }
}

extension Container {
    public var calculateWaterAmountService: Factory<CalculateWaterAmountService> {
        Factory(self) { CalculateWaterAmountServiceImpl() }.cached
    }
}
