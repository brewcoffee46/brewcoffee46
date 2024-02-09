import Factory
import StoreKit
import UIKit

protocol RequestReviewService {
    func check() -> ResultNea<Bool, CoffeeError>
}

class RequestReviewServiceImpl: RequestReviewService {
    @Injected(\.userDefaultsService) private var userDefaultsService
    @Injected(\.dateService) private var dateService

    func check() -> ResultNea<Bool, CoffeeError> {
        beforeCheck().flatMap { result in
            if result {
                requestReview()
            } else {
                .success(false)
            }
        }
    }

    private func saveInitGuard() -> ResultNea<Void, CoffeeError> {
        userDefaultsService.setEncodable(RequestReviewGuard(tryCount: 1), forKey: RequestReviewServiceImpl.requestReviewGuardKey)
    }

    private func beforeCheck() -> ResultNea<Bool, CoffeeError> {
        userDefaultsService.getDecodable(forKey: RequestReviewServiceImpl.requestReviewGuardKey).flatMap {
            (requestReviewGuardOpt: RequestReviewGuard?) in
            if let requestReviewGuard = requestReviewGuardOpt {
                return
                    userDefaultsService
                    .setEncodable(
                        RequestReviewGuard(tryCount: requestReviewGuard.tryCount + 1),
                        forKey: RequestReviewServiceImpl.requestReviewGuardKey
                    )
                    .map {
                        requestReviewGuard.tryCount >= RequestReviewServiceImpl.minimumTryCount
                    }
                    .flatMapError { _ in
                        saveInitGuard().map { false }
                    }
            } else {
                return saveInitGuard().map { false }
            }
        }
    }

    private func saveInitRequestReviewInfo(_ requestReviewItem: RequestReviewItem) -> ResultNea<Void, CoffeeError> {
        userDefaultsService
            .setEncodable(
                RequestReviewInfo(requestHistory: [requestReviewItem]),
                forKey: RequestReviewServiceImpl.requestReviewInfoKey
            )
    }

    private func requestReview() -> ResultNea<Bool, CoffeeError> {
        let now = dateService.now()
        let appVersion: String = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)!
        let requestReviewItem = RequestReviewItem(appVersion: appVersion, requestedDate: now)

        return userDefaultsService.getDecodable(forKey: RequestReviewServiceImpl.requestReviewInfoKey).flatMap {
            (requestReviewInfoOpt: RequestReviewInfo?) in
            if let requestReviewInfo = requestReviewInfoOpt {
                if !requestReviewInfo.requestHistory.isEmpty {
                    let latest = requestReviewInfo.requestHistory.last!

                    if now.timeIntervalSince(latest.requestedDate) >= RequestReviewServiceImpl.reviewRequestInterval {
                        let updatedRequestReviewInfo = RequestReviewInfo(requestHistory: requestReviewInfo.requestHistory + [requestReviewItem])

                        return
                            userDefaultsService
                            .setEncodable(updatedRequestReviewInfo, forKey: RequestReviewServiceImpl.requestReviewInfoKey)
                            .map { true }
                    } else {
                        return .success(false)
                    }
                } else {
                    return saveInitRequestReviewInfo(requestReviewItem).map { false }
                }
            } else {
                return saveInitRequestReviewInfo(requestReviewItem).map { true }
            }
        }
    }
}

extension RequestReviewServiceImpl {
    static internal let requestReviewInfoKey: String = "requestReviewInfo"

    static internal let requestReviewGuardKey: String = "requestReviewGuard"

    static internal let reviewRequestInterval: Double = Double(100 * 24 * 60 * 60)  // 100 days

    static internal let minimumTryCount: Int = 3
}

extension Container {
    var requestReviewService: Factory<RequestReviewService> {
        Factory(self) { RequestReviewServiceImpl() }
    }
}
