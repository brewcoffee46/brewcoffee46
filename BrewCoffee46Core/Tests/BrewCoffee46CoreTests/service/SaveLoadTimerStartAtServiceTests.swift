import BrewCoffee46TestsShared
import Factory
import Foundation
import XCTest

@testable import BrewCoffee46Core

struct DummyError: Error {}

final class SaveLoadTimerStartAtServiceTests: XCTestCase {
    let successResult: ResultNea<Any?, CoffeeError> = .success(.some(epochTimeMillis))
    let now = epochTimeMillis.toDate()

    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    func testSaveStartAtSuccessfully() {
        let mockUserDefaultsService = MockUserDefaultsService<UInt64>(successResult)
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.saveStartAt(now)
        XCTAssertTrue(actual.isSuccess())
        XCTAssertEqual(mockUserDefaultsService.inputValues, [epochTimeMillis])
    }

    func testLoadStartAtSuccessfully() {
        let mockUserDefaultsService = MockUserDefaultsService<UInt64>(successResult)
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.loadStartAt()
        XCTAssertEqual(actual, .success(.some(now)))
    }

    func testLoadStartAtReturnNoneIfUserDefaultServiceReturnNone() {
        let mockUserDefaultsService = MockUserDefaultsService<UInt64>(.success(.none))
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.loadStartAt()
        XCTAssertEqual(actual, .success(.none))
    }

    func testLoadStartAtReturnErrorIfUserDefaultServiceReturnUnexpectedTypeValue() {
        let failure: ResultNea<Date?, CoffeeError> = .failure(NonEmptyArray(CoffeeError.jsonError(DummyError())))
        let mockUserDefaultsService = MockUserDefaultsService<UInt64>(failure.map({ a in a as Any }))
        Container.shared.userDefaultsService.register {
            mockUserDefaultsService
        }
        let sut = SaveLoadTimerStartAtServiceImpl()

        let actual = sut.loadStartAt()
        XCTAssertEqual(actual, failure)
    }
}
