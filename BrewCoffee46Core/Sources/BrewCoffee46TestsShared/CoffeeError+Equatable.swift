import BrewCoffee46Core

extension CoffeeError: Equatable {
    public static func == (lhs: CoffeeError, rhs: CoffeeError) -> Bool {
        return switch (lhs, rhs) {
        case (.coffeeBeansWeightUnderZeroError, .coffeeBeansWeightUnderZeroError): true
        case (.coffeeBeansWeightIsNotNumberError, .coffeeBeansWeightIsNotNumberError): true
        case (.waterAmountIsTooLessError, .waterAmountIsTooLessError): true
        case (.first40PercentWaterAmountExceededWholeWaterAmountError, .first40PercentWaterAmountExceededWholeWaterAmountError): true
        case (.partitionsCountOf6IsNeededAtLeastOne, .partitionsCountOf6IsNeededAtLeastOne): true
        case (.steamingTimeIsTooMuchThanTotal, .steamingTimeIsTooMuchThanTotal): true
        case (.firstWaterPercentIsZeroError, .firstWaterPercentIsZeroError): true
        case (.loadedConfigIsNotCompatible, .loadedConfigIsNotCompatible): true
        case (.jsonError(_), .jsonError(_)):
            // This case is too much ad-hoc since ignore the difference of `underlying` between `lhs` and `rhs`.
            // That's the why this `Equatable` implementation is put test code rather than main.
            true
        case (.arrayNumberConversionError(_), .arrayNumberConversionError(_)): true
        case (.configQueryParameterNotFound, .configQueryParameterNotFound): true
        case (.numberOfSwitchesIsInvalid, .numberOfSwitchesIsInvalid): true
        case (.activitiesNotEnabled, .activitiesNotEnabled): true
        case (.liveActivityRequestFailed(_), .liveActivityRequestFailed(_)): true
        default:
            false
        }
    }
}
