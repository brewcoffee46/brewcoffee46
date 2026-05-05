import FactoryKit
import FirebaseCore
import Foundation
import NotificationCenter
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Injected(\.notificationService) private var notificationService

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        Task {
            await notificationService.request()
        }

        UNUserNotificationCenter.current().delegate = self

        FirebaseApp.configure()

        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let _ = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
        else {
            return false
        }

        return true
    }
}
