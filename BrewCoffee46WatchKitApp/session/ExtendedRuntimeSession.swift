import Foundation
import WatchKit

final class ExtendedRuntimeSession: NSObject, ObservableObject {
    private var session: WKExtendedRuntimeSession!

    func startSession() {
        session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
    }

    func endSession() {
        session.invalidate()
    }
}

extension ExtendedRuntimeSession: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
    }
    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?
    ) {
    }
}
