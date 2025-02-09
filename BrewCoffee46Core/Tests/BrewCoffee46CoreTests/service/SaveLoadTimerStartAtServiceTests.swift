import BrewCoffee46TestsShared
import Factory
import Foundation
import XCTest

@testable import BrewCoffee46Core

struct DummyError: Error {}

final class MockUserDefaultsService: UserDefaultsService, @unchecked Sendable {
    var inputValues: [UInt64] = []
    var dummyResult: ResultNea<Any?, CoffeeError>

    init(_ dummyResult: ResultNea<Any?, CoffeeError>) {
        self.dummyResult = dummyResult
    }

    func setEncodable<A: Encodable>(_ value: A, forKey defaultName: String) -> ResultNea<Void, CoffeeError> {
        inputValues.append(value as! UInt64)
        return .success(())
    }

    func getDecodable<A: Decodable>(forKey: String) -> ResultNea<A?, CoffeeError> {
        return dummyResult.map({ a in a as? A })
    }

    func delete(forKey: String) {
        return ()
    }

}

final class SaveLoadTimerStartAtServiceTests: XCTestCase {
    let successResult: ResultNea<Any?, CoffeeError> = .success(.some(epochTimeMillis))
    let now = epochTimeMillis.toDate()

    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    func testSaveStartAtSuccessfully() {
        let mockUserDefaultsService = MockUserDefaultsService(successResult)
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.saveStartAt(now)
        XCTAssertTrue(actual.isSuccess())
        XCTAssertEqual(mockUserDefaultsService.inputValues, [epochTimeMillis])
    }

    func testLoadStartAtSuccessfully() {
        let mockUserDefaultsService = MockUserDefaultsService(successResult)
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.loadStartAt()
        XCTAssertEqual(actual, .success(.some(now)))
    }

    func testLoadStartAtReturnNoneIfUserDefaultServiceReturnNone() {
        let mockUserDefaultsService = MockUserDefaultsService(.success(.none))
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.loadStartAt()
        XCTAssertEqual(actual, .success(.none))
    }

    func testLoadStartAtReturnErrorIfUserDefaultServiceReturnUnexpectedTypeValue() {
        let failure: ResultNea<Date?, CoffeeError> = .failure(NonEmptyArray(CoffeeError.jsonError(DummyError())))
        let mockUserDefaultsService = MockUserDefaultsService(failure.map({ a in a as Any }))
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.loadStartAt()
        XCTAssertEqual(actual, failure)
    }
}
