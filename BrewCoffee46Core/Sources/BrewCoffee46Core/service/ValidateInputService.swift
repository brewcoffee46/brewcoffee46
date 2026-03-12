import Factory

/// # Validation for the config.
public protocol ValidateInputService: Sendable {
    func validate(_ appConfig: AppConfig) -> ResultNea<Void, CoffeeError>
}

public final class ValidateInputServiceImpl: ValidateInputService {
    public func validate(_ appConfig: AppConfig) -> ResultNea<Void, CoffeeError> {
        let validatedTuple =
            validateCoffeeBeansWeight(appConfig.globalConfig.coffeeBeansWeightG) |+| validationNumberOf6(appConfig.coffeeConfig.partitionsCountOf6)
            |+| validationTotalTime(steamingTime: appConfig.coffeeConfig.steamingTimeSec, totalTime: appConfig.coffeeConfig.totalTimeSec)
            |+| validationFirstWaterPercent(appConfig.coffeeConfig.firstWaterPercent)

        return validatedTuple.map { _ in
            ()
        }
    }

    // Coffee beans weight must be greater than 0g.
    private func validateCoffeeBeansWeight(
        _ coffeeBeansWeight: Double
    ) -> ResultNea<Double, CoffeeError> {
        coffeeBeansWeight > 0 ? ResultNea.success(coffeeBeansWeight) : CoffeeError.coffeeBeansWeightUnderZeroError.toFailureNel()
    }

    private func validationNumberOf6(
        _ numberOf6: Int
    ) -> ResultNea<Int, CoffeeError> {
        numberOf6 > 0 ? ResultNea.success(numberOf6) : CoffeeError.partitionsCountOf6IsNeededAtLeastOne.toFailureNel()
    }

    private func validationTotalTime(
        steamingTime: Double,
        totalTime: Double
    ) -> ResultNea<Void, CoffeeError> {
        steamingTime < totalTime ? ResultNea.success(()) : CoffeeError.steamingTimeIsTooMuchThanTotal.toFailureNel()
    }

    private func validationFirstWaterPercent(
        _ firstWaterPercent: Double
    ) -> ResultNea<Void, CoffeeError> {
        firstWaterPercent > 0 ? ResultNea.success(()) : CoffeeError.firstWaterPercentIsZeroError.toFailureNel()
    }
}

extension Container {
    public var validateInputService: Factory<ValidateInputService> {
        Factory(self) { ValidateInputServiceImpl() }
    }
}
