/// # This app error interface.
public enum CoffeeError: Error, Sendable {
    case coffeeBeansWeightUnderZeroError

    case coffeeBeansWeightIsNotNumberError

    case waterAmountIsTooLessError

    case first40PercentWaterAmountExceededWholeWaterAmountError

    case partitionsCountOf6IsNeededAtLeastOne

    case steamingTimeIsTooMuchThanTotal

    case firstWaterPercentIsZeroError

    case loadedConfigIsNotCompatible

    case jsonError(_ underlying: Error)

    case arrayNumberConversionError(_ message: String)

    case notificationError(_ underlying: Error)

    case watchSessionIsNotActivated

    case sendMessageToWatchOSFailure(_ underlying: Error)

    case configClamesJwtError(_ underlying: Error)

    case configQueryParameterNotFound

    case numberOfSwitchesIsInvalid

    case activitiesNotEnabled

    case liveActivityRequestFailed(_ underlying: Error)

    public func getMessage() -> String {
        switch self {
        case .coffeeBeansWeightUnderZeroError:
            return "The coffee beans weight must be greater than 0."

        case .coffeeBeansWeightIsNotNumberError:
            return "The coffee beans weight must be number."

        case .waterAmountIsTooLessError:
            return "The boiled water need its amount greater than 0cc."

        case .first40PercentWaterAmountExceededWholeWaterAmountError:
            return "The first shot boiled water amount less than or equal whole water amount."

        case .partitionsCountOf6IsNeededAtLeastOne:
            return "The number of times of shots for 60% is needed at least one."

        case .steamingTimeIsTooMuchThanTotal:
            return "The streaming time must be less than total time."

        case .firstWaterPercentIsZeroError:
            return "The first water percent must be more than 0."

        case .loadedConfigIsNotCompatible:
            return "The loaded configuration is not compatible."

        case .jsonError(let error):
            return "Something error was occurred in JSON serialize/deserialize: \(error)"

        case .arrayNumberConversionError(let message):
            return "Something error was occurred in conversion `[Int]` to/from `Double`: \(message)"

        case .notificationError(let error):
            return "Something error was occurred in notification: \(error)"

        case .watchSessionIsNotActivated:
            return "watchOS session is not activated."

        case .sendMessageToWatchOSFailure(let error):
            return "Something error was occurred in sending a message to watchOS app: \(error)"

        case .configClamesJwtError(let error):
            return "Something error was occurred in decording JWT config: \(error)"

        case .configQueryParameterNotFound:
            return "Configuration query parameter not found."

        case .numberOfSwitchesIsInvalid:
            return "The number of switches is invalid."

        case .activitiesNotEnabled:
            return "Live activity is not enable."

        case .liveActivityRequestFailed(let error):
            return "Something error was occurred in live activity request: \(error)"
        }
    }
}

extension CoffeeError {
    public func toFailureNel<A>() -> ResultNea<A, Self> {
        .failure(NonEmptyArray(self))
    }
}
