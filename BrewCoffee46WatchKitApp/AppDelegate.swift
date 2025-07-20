import FirebaseCore
import WatchKit

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        FirebaseApp.configure()
    }
}
