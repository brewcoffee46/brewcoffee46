import ActivityKit
import BrewCoffee46Core
import Foundation

@testable import BrewCoffee46

final class MockLiveActivityService: LiveActivityService<DripTimingAttributes>, @unchecked Sendable {
    var enabled: Bool = true
    var requestError: Error?
    var id: Int = 0

    private(set) var requestedAttributes: [DripTimingAttributes] = []
    private(set) var requestedStates: [DripTimingAttributes.ContentState] = []
    private(set) var requestedStaleDates: [Date?] = []

    private(set) var didCallEndAll: Bool = false
    private(set) var endAllFinalState: DripTimingAttributes.ContentState?

    private(set) var endedActivities:
        [(handle: LiveActivityHandle<DripTimingAttributes>, finalState: DripTimingAttributes.ContentState, policy: ActivityUIDismissalPolicy)] = []

    func areActivitiesEnabled() -> Bool {
        enabled
    }

    func request(
        attributes: DripTimingAttributes,
        initialState: DripTimingAttributes.ContentState,
        staleDate: Date?
    ) throws -> LiveActivityHandle<DripTimingAttributes> {
        requestedAttributes.append(attributes)
        requestedStates.append(initialState)
        requestedStaleDates.append(staleDate)

        if let error = requestError {
            throw error
        }
        id = id + 1
        return LiveActivityHandle(id: "\(id)")
    }

    func endAll(finalState: DripTimingAttributes.ContentState) async {
        didCallEndAll = true
        endAllFinalState = finalState
    }

    func end(
        _ handle: LiveActivityHandle<DripTimingAttributes>,
        finalState: DripTimingAttributes.ContentState,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async {
        endedActivities.append((handle: handle, finalState: finalState, policy: dismissalPolicy))
    }

    // MARK: - Helpers
    func reset() {
        id = 0
        requestError = nil
        requestedAttributes.removeAll()
        requestedStates.removeAll()
        requestedStaleDates.removeAll()
        didCallEndAll = false
        endAllFinalState = nil
        endedActivities.removeAll()
    }
}
