import ActivityKit
import BrewCoffee46Core
import FactoryKit
import Foundation

/// #　A test-friendly wrapper around a Live Activity ID
/// This used to avoid exposing `Activity` that cannot instantiate type, for mocks and unit tests.
struct LiveActivityHandle<Attr: ActivityAttributes & Sendable>: Hashable, Sendable {
    let id: String
}

/// # Generic client that wraps `ActivityKit` for DI.
protocol LiveActivityService<Attr>: Sendable where Attr: ActivityAttributes & Sendable {
    associatedtype Attr

    func areActivitiesEnabled() -> Bool

    func request(
        attributes: Attr,
        initialState: Attr.ContentState,
        staleDate: Date?
    ) throws -> LiveActivityHandle<Attr>

    func endAll(finalState: Attr.ContentState) async

    func end(
        _ handle: LiveActivityHandle<Attr>,
        finalState: Attr.ContentState,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async
}

final class ActivityKitLiveActivityService<Attr: ActivityAttributes & Sendable>: LiveActivityService {
    func areActivitiesEnabled() -> Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func request(
        attributes: Attr,
        initialState: Attr.ContentState,
        staleDate: Date?
    ) throws -> LiveActivityHandle<Attr> {
        let activity = try Activity.request(
            attributes: attributes,
            content: ActivityContent(
                state: initialState,
                staleDate: staleDate
            ),
            pushType: nil
        )
        return LiveActivityHandle(id: activity.id)
    }

    func endAll(finalState: Attr.ContentState) async {
        for activity in Activity<Attr>.activities {
            await activity.end(
                ActivityContent(
                    state: finalState,
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
        }
    }

    func end(
        _ handle: LiveActivityHandle<Attr>,
        finalState: Attr.ContentState,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async {
        guard let activity = Activity<Attr>.activities.first(where: { $0.id == handle.id }) else {
            return
        }

        await activity.end(
            ActivityContent(
                state: finalState,
                staleDate: nil
            ),
            dismissalPolicy: dismissalPolicy
        )
    }
}

extension Container {
    var liveActivityService: Factory<any LiveActivityService<DripTimingAttributes>> {
        Factory(self) { ActivityKitLiveActivityService<DripTimingAttributes>() }.cached
    }
}
