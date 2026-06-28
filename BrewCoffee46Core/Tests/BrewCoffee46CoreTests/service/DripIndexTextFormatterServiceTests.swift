import XCTest

@testable import BrewCoffee46Core

final class DripIndexTextFormatterServiceTests: XCTestCase {
    let sut = DripIndexTextFormatterServiceImpl()

    func testDripTextReturnsFirstDripText() {
        XCTAssertEqual(
            sut.dripText(0),
            NSLocalizedString("drip ordinal 1", comment: "")
        )
    }

    func testDripTextReturnsSecondDripText() {
        XCTAssertEqual(
            sut.dripText(1),
            NSLocalizedString("drip ordinal 2", comment: "")
        )
    }

    func testDripTextReturnsThirdDripText() {
        XCTAssertEqual(
            sut.dripText(2),
            NSLocalizedString("drip ordinal 3", comment: "")
        )
    }

    func testDripTextReturnsNthDripTextAfterFourthDrip() {
        XCTAssertEqual(
            sut.dripText(3),
            String(
                format: NSLocalizedString("drip ordinal n", comment: ""),
                4
            )
        )
    }
}
