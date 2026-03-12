import BrewCoffee46Core
import Factory
@preconcurrency import WatchConnectivity

protocol WatchConnectionService: Sendable {
    func isPaired() -> Bool

    func isReachable() -> Bool

    func sendConfigs(_ configs: [CoffeeConfig]) async -> ResultNea<Void, CoffeeError>
}

final class WatchConnectionServiceImpl: NSObject, WatchConnectionService {
    private let session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }

    func isPaired() -> Bool {
        session.isPaired
    }

    func isReachable() -> Bool {
        session.isReachable
    }

    private let encoder = JSONEncoder()

    func sendConfigs(_ configs: [CoffeeConfig]) async -> ResultNea<Void, CoffeeError> {
        do {
            let json = try encoder.encode(configs)

            return await withCheckedContinuation { continuation in
                if session.activationState != .activated {
                    continuation.resume(returning: .failure(NonEmptyArray(CoffeeError.watchSessionIsNotActivated)))
                    return
                }

                let configsJson = String(data: json, encoding: .utf8)!
                session.sendMessage(
                    [watchKitAppConfigsKey: configsJson],
                    replyHandler: { data in
                        continuation.resume(returning: .success(()))
                    },
                    errorHandler: { error in
                        continuation.resume(returning: .failure(NonEmptyArray(.sendMessageToWatchOSFailure(error))))
                    }
                )
            }
        } catch {
            return .failure(NonEmptyArray(CoffeeError.jsonError(error)))
        }
    }
}

extension Container {
    @MainActor
    var watchConnectionService: Factory<WatchConnectionService> {
        Factory(self) { WatchConnectionServiceImpl() }
    }
}

extension WatchConnectionServiceImpl: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {

    }
}
