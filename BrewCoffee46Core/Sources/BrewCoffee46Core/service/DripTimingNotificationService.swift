import Factory
import Foundation

/// # Notify drip notifications to user.
public protocol DripTimingNotificationService: Sendable {
    func registerNotifications(
        dripTimings: [DripTiming],
        firstDripAtSec: Double,
        totalTimeSec: Double
    ) async -> ResultNea<Void, CoffeeError>

    func removePendingAll() -> Void
}

public final class DripTimingNotificationServiceImpl: DripTimingNotificationService {
    private let notificationService = Container.shared.notificationService()

    public func registerNotifications(
        dripTimings: [DripTiming],
        firstDripAtSec: Double,
        totalTimeSec: Double
    ) async -> ResultNea<Void, CoffeeError> {
        return await withTaskGroup(of: ResultNea<Void, CoffeeError>.self) { group in
            var errors: [CoffeeError] = []

            let numberOfAllDrips = dripTimings.count
            for (i, info) in dripTimings.enumerated() {
                let notifiedAt = Int(floor(info.dripAt) + firstDripAtSec)

                group.addTask {
                    let title =
                        if i == 0 {
                            String(format: NSLocalizedString("notification 1st drip", comment: ""), numberOfAllDrips)
                        } else if i == 1 {
                            String(format: NSLocalizedString("notification 2nd drip", comment: ""), numberOfAllDrips)
                        } else if i == 2 {
                            String(format: NSLocalizedString("notification 3rd drip", comment: ""), numberOfAllDrips)
                        } else {
                            String(format: NSLocalizedString("notification after 4th drip suffix", comment: ""), (i + 1), numberOfAllDrips)
                        }

                    return await self.notificationService.addNotificationUsingTimer(
                        title: title,
                        body: "🫖 \(roundCentesimal(info.waterAmount))g 💧",
                        notifiedInSeconds: notifiedAt
                    )
                }

                for await result in group {
                    switch result {
                    case .failure(let error):
                        errors += error.toArray()
                    case .success():
                        ()
                    }
                }
            }

            switch await notificationService.addNotificationUsingTimer(
                title: "☕️ " + NSLocalizedString("notification drip end", comment: ""),
                body: "",
                notifiedInSeconds: Int(ceil(totalTimeSec) + firstDripAtSec)
            ) {
            case .failure(let error):
                errors += error.toArray()
            case .success():
                ()
            }

            if errors.isEmpty {
                return .success(())
            } else {
                return .failure(NonEmptyArray(errors.first!, Array(errors.dropFirst())))
            }
        }
    }

    public func removePendingAll() -> Void {
        notificationService.removePendingAll()
    }
}

extension Container {
    public var dripTimingNotificationService: Factory<DripTimingNotificationService> {
        Factory(self) { DripTimingNotificationServiceImpl() }
    }
}
