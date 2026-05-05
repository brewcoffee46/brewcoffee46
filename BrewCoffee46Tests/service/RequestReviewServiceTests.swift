import BrewCoffee46Core
import BrewCoffee46TestsShared
import FactoryKit
import XCTest

@testable import BrewCoffee46

final class MockUserDefaultsService: UserDefaultsService {
    let dummyRequestReviewInfo: RequestReviewInfo?
    let dummyRequestReviewGuard: RequestReviewGuard?

    init(_ dummyRequestReviewInfo: RequestReviewInfo?, _ dummyRequestReviewGuard: RequestReviewGuard?) {
        self.dummyRequestReviewInfo = dummyRequestReviewInfo
        self.dummyRequestReviewGuard = dummyRequestReviewGuard
    }

    func setEncodable<A: Encodable>(_ value: A, forKey: String) -> ResultNea<Void, CoffeeError> {
        .success(())
    }

    func getDecodable<A: Decodable>(forKey: String) -> ResultNea<A?, CoffeeError> {
        if forKey == RequestReviewServiceImpl.requestReviewInfoKey {
            .success(dummyRequestReviewInfo as! A?)
        } else if forKey == RequestReviewServiceImpl.requestReviewGuardKey {
            .success(dummyRequestReviewGuard as! A?)
        } else {
            .success(.none)
        }
    }

    func delete(forKey: String) {}
}

let now = DateUtils.dateFromString("2024/01/28 12:34:56 +09:00", format: "yyyy/MM/dd HH:mm:ss Z")

class RequestReviewServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    func test_to_return_true_if_the_guard_tryCount_equals_with_minimum_and_request_review_info_is_none() throws {
        Container.shared.userDefaultsService.register {
            MockUserDefaultsService(
                .none,
                .some(RequestReviewGuard(tryCount: RequestReviewServiceImpl.minimumTryCount))
            )
        }

        let sut = RequestReviewServiceImpl()
        let actual = sut.check()

        XCTAssertEqual(actual, .success(true))
    }

    func test_to_return_true_if_the_guard_tryCount_equals_with_minimum_and_request_latest_review_info_date_is_100_days_before() throws {
        Container.shared.dateService.register { MockDateService(now) }
        Container.shared.userDefaultsService.register {
            MockUserDefaultsService(
                .some(
                    RequestReviewInfo(
                        requestHistory: [
                            RequestReviewItem(
                                appVersion: "1.1.1", requestedDate: now.advanced(by: -RequestReviewServiceImpl.reviewRequestInterval)
                            )
                        ])
                ),
                .some(RequestReviewGuard(tryCount: RequestReviewServiceImpl.minimumTryCount))
            )
        }

        let sut = RequestReviewServiceImpl()
        let actual = sut.check()

        XCTAssertEqual(actual, .success(true))
    }

    func test_to_return_false_if_the_guard_is_none() throws {
        Container.shared.userDefaultsService.register { MockUserDefaultsService(.none, .none) }

        let sut = RequestReviewServiceImpl()
        let actual = sut.check()

        XCTAssertEqual(actual, .success(false))
    }

    func test_to_return_false_if_the_guard_tryCount_is_less_than_minimum() throws {
        Container.shared.userDefaultsService.register {
            MockUserDefaultsService(
                .none,
                .some(RequestReviewGuard(tryCount: RequestReviewServiceImpl.minimumTryCount - 1))
            )
        }

        let sut = RequestReviewServiceImpl()
        let actual = sut.check()

        XCTAssertEqual(actual, .success(false))
    }

    func test_to_return_false_if_the_guard_tryCount_equals_with_minimum_and_request_latest_review_info_date_is_not_100_days_before() throws {
        Container.shared.dateService.register { MockDateService(now) }
        Container.shared.userDefaultsService.register {
            MockUserDefaultsService(
                .some(
                    RequestReviewInfo(
                        requestHistory: [
                            RequestReviewItem(
                                appVersion: "1.1.1", requestedDate: now.advanced(by: -(RequestReviewServiceImpl.reviewRequestInterval - 1.0))
                            )
                        ])
                ),
                .some(RequestReviewGuard(tryCount: RequestReviewServiceImpl.minimumTryCount))
            )
        }

        let sut = RequestReviewServiceImpl()
        let actual = sut.check()

        XCTAssertEqual(actual, .success(false))
    }
}
