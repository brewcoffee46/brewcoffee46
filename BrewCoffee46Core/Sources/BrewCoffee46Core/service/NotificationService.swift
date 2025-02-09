import Factory
@preconcurrency import UserNotifications

/// # Local notifications manager
public protocol NotificationService: Sendable {
    /// # Request notification to the user if the request has not been requested yet
    /// - Returns:
    ///     - `success(true)` means that the request was accepted
    ///     - `success(false)` means that the request was not accepted
    func request() async -> ResultNea<Bool, CoffeeError>

    /// # Add the notification notified in `notifiedInSeconds` to the listener
    /// - Returns:
    ///     - `success()` means that the notification was added to the listener successfully
    func addNotificationUsingTimer(
        title: String,
        body: String,
        notifiedInSeconds: Int
    ) async -> ResultNea<Void, CoffeeError>

    func removePendingAll() -> Void
}

public final class NotificationServiceImpl: NotificationService {
    public func request() async -> ResultNea<Bool, CoffeeError> {
        do {
            return .success(try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]))
        } catch {
            return .failure(NonEmptyArray(.notificationError(error)))
        }
    }

    public func addNotificationUsingTimer(title: String, body: String, notifiedInSeconds: Int) async
        -> ResultNea<Void, CoffeeError>
    {
        let result = await request()

        return await result.flatMap { (granted: Bool) in
            let content: UNMutableNotificationContent = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notifiedInSeconds), repeats: false)
            let identifier = NSUUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                return .success(try await UNUserNotificationCenter.current().add(request))
            } catch {
                return .failure(NonEmptyArray(.notificationError(error)))
            }
        }
    }

    public func removePendingAll() -> Void {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension NotificationServiceImpl {
    static internal let notificationInfoKey: String = "localNotification"
}

extension Container {
    public var notificationService: Factory<NotificationService> {
        Factory(self) { NotificationServiceImpl() }
    }
}
