import FactoryKit
import Foundation

/// # Notify drip notifications to user.
public protocol DripTimingNotificationService: Sendable {
    func registerNotifications(
        dripTimings: [DripTiming],
        firstDripAtSec: Double,
        totalTimeSec: Double
    ) async -> ResultNea<[DripTimingNotification], CoffeeError>

    func removePending(_ notifications: [DripTimingNotification]) -> Void

    func removePendingAll() -> Void
}

public final class DripTimingNotificationServiceImpl: DripTimingNotificationService {
    private let notificationService = Container.shared.notificationService()
    private let dripIndexTextFormatterService = Container.shared.dripIndexTextFormatterService()

    public func registerNotifications(
        dripTimings: [DripTiming],
        firstDripAtSec: Double,
        totalTimeSec: Double
    ) async -> ResultNea<[DripTimingNotification], CoffeeError> {
        return await withTaskGroup(of: ResultNea<DripTimingNotification, CoffeeError>.self) { group in
            var errors: [CoffeeError] = []
            var notifications: [DripTimingNotification] = []

            let numberOfAllDrips = dripTimings.count
            for (i, info) in dripTimings.enumerated() {
                let notifiedAt = floor(info.dripAt.second) + firstDripAtSec

                group.addTask {
                    let title = String(
                        format: NSLocalizedString("notification drip now", comment: ""),
                        self.dripIndexTextFormatterService.dripText(i),
                        numberOfAllDrips
                    )
                    let notificationID = await self.notificationService.addNotificationUsingTimer(
                        title: title,
                        body: "🫖 \(roundCentesimal(info.waterAmount.gram))g 💧",
                        notifiedInSeconds: Int(notifiedAt)
                    )

                    return notificationID.map { (notificationID: NotificationID) in
                        DripTimingNotification(
                            id: notificationID,
                            notifiedIn: MilliSecond.fromSecond(notifiedAt)
                        )
                    }
                }

                for await result in group {
                    switch result {
                    case .failure(let error):
                        errors += error.toArray()
                    case .success(let notification):
                        notifications.append(notification)
                    }
                }
            }

            let lastNotifiedInSeconds = ceil(totalTimeSec) + firstDripAtSec
            switch await notificationService.addNotificationUsingTimer(
                title: "☕️ " + NSLocalizedString("notification drip end", comment: ""),
                body: "",
                notifiedInSeconds: Int(lastNotifiedInSeconds)
            ) {
            case .failure(let error):
                errors += error.toArray()
            case .success(let notificationID):
                notifications.append(
                    DripTimingNotification(
                        id: notificationID,
                        notifiedIn: MilliSecond.fromSecond(lastNotifiedInSeconds)
                    )
                )
            }

            if errors.isEmpty {
                return .success(notifications)
            } else {
                return .failure(NonEmptyArray(errors.first!, Array(errors.dropFirst())))
            }
        }
    }

    public func removePending(_ notifications: [DripTimingNotification]) -> Void {
        notificationService.removePending(notifications.map(\.id))
    }

    public func removePendingAll() -> Void {
        notificationService.removePendingAll()
    }
}

extension Container {
    public var dripTimingNotificationService: Factory<DripTimingNotificationService> {
        Factory(self) { DripTimingNotificationServiceImpl() }.cached
    }
}
