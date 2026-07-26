import ActivityKit
import BrewCoffee46Core
import FactoryKit
import Foundation

/// # A service that starts and stops the drip timer Live Activity.
protocol DripTimingLiveActivityService: Sendable {
    /// Starts a drip timer Live Activity.
    /// - Returns: On success, a handle for the created Live Activity. On failure,
    ///   returns `CoffeeError.activitiesNotEnabled` or `CoffeeError.liveActivityRequestFailed(_:)`.
    /// - Note: If an existing activity of the same type is running, it will be ended before starting a new one.
    func startLiveActivity(
        appConfig: AppConfig,
        dripInfo: DripInfo,
        startedAt: Date
    ) async -> ResultNea<LiveActivityHandle<DripTimingAttributes>, CoffeeError>

    /// Ends the given Live Activity immediately.
    func stopLiveActivity(
        handle: LiveActivityHandle<DripTimingAttributes>
    ) async -> ResultNea<Void, CoffeeError>
}

final class DripTimingLiveActivityServiceImpl: DripTimingLiveActivityService {
    private let liveActivityService = Container.shared.liveActivityService()

    func startLiveActivity(
        appConfig: AppConfig,
        dripInfo: DripInfo,
        startedAt: Date
    ) async -> ResultNea<LiveActivityHandle<DripTimingAttributes>, CoffeeError> {
        guard liveActivityService.areActivitiesEnabled() else {
            return CoffeeError.activitiesNotEnabled.toFailureNel()
        }

        await liveActivityService.endAll(finalState: DripTimingAttributes.ContentState.defaultValue)

        let attributes = makeAttributes(appConfig: appConfig, dripInfo: dripInfo, startedAt: startedAt)
        let finishedAt = startedAt.addingTimeInterval(dripInfo.totalTimeSec)

        do {
            let activity = try liveActivityService.request(
                attributes: attributes,
                initialState: DripTimingAttributes.ContentState.defaultValue,
                staleDate: finishedAt
            )
            return .success(activity)
        } catch {
            return .failure(NonEmptyArray(.liveActivityRequestFailed(error)))
        }
    }

    func stopLiveActivity(
        handle: LiveActivityHandle<DripTimingAttributes>
    ) async -> ResultNea<Void, CoffeeError> {
        await liveActivityService.end(
            handle,
            finalState: DripTimingAttributes.ContentState.defaultValue,
            dismissalPolicy: .immediate
        )
        return .success(())
    }

    private func makeAttributes(appConfig: AppConfig, dripInfo: DripInfo, startedAt: Date) -> DripTimingAttributes {
        let recipeName =
            appConfig.coffeeConfig.note.isEmpty
            ? NSLocalizedString("config note empty string", comment: "")
            : appConfig.coffeeConfig.note

        return DripTimingAttributes(
            startedAt: startedAt,
            recipeName: recipeName,
            coffeeBeansWeight: appConfig.globalConfig.coffeeBeansWeightMg,
            totalWaterAmount: MilliGram.fromGram(dripInfo.waterAmount.totalAmount()),
            dripTimings: dripInfo.dripTimings,
            totalTime: MilliSecond.fromSecond(dripInfo.totalTimeSec)
        )
    }
}

extension Container {
    var dripTimingLiveActivityService: Factory<DripTimingLiveActivityService> {
        Factory(self) { DripTimingLiveActivityServiceImpl() }.cached
    }
}
