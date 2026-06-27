/// `NotificationID` is a identifier of `UNNotificationRequest`.
public typealias NotificationID = String

public struct DripTimingNotification: Sendable {
    public let id: NotificationID

    public let notifiedIn: MilliSecond
}
