import BrewCoffee46TestsShared
import Factory
import XCTest

@testable import BrewCoffee46Core

struct AddNotificationUsingTimerArgument {
    let title: String
    let body: String
    let notifiedInSeconds: Int
}

final class MockNotificationService: NotificationService, @unchecked Sendable {
    var addNotificationUsingTimerArguments: [AddNotificationUsingTimerArgument] = []

    func request() async -> ResultNea<Bool, CoffeeError> {
        return ResultNea.success(true)
    }

    func addNotificationUsingTimer(
        title: String,
        body: String,
        notifiedInSeconds: Int
    ) async -> ResultNea<Void, CoffeeError> {
        addNotificationUsingTimerArguments.append(
            AddNotificationUsingTimerArgument(
                title: title,
                body: body,
                notifiedInSeconds: notifiedInSeconds
            )
        )
        return ResultNea.success(())
    }

    func removePendingAll() {
        return
    }
}

final class DripTimingNotificationServiceTests: XCTestCase {
    let dripTimings = [
        DripTiming(waterAmount: 66.528, dripAt: 0.0),
        DripTiming(waterAmount: 67.2, dripAt: 45.0),
        DripTiming(waterAmount: 100.8, dripAt: 86.25),
        DripTiming(waterAmount: 134.4, dripAt: 127.5),
        DripTiming(waterAmount: 168.0, dripAt: 168.75),
    ]
    let firstDripAtSec = 3.0
    let totalTimeSec = 210.0

    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    func testArgumentsNotifiedAtOfAddNotificationUsingTimer() async {
        var expectedNotifiedInSeconds: [Int] = dripTimings.map({ dt in
            Int(floor(dt.dripAt) + firstDripAtSec)
        })
        expectedNotifiedInSeconds.append(Int(ceil(totalTimeSec) + firstDripAtSec))

        let mockNotificationService = MockNotificationService()
        Container.shared.notificationService.register {
            mockNotificationService
        }

        let sut = DripTimingNotificationServiceImpl()
        let actual = await sut.registerNotifications(
            dripTimings: dripTimings,
            firstDripAtSec: firstDripAtSec,
            totalTimeSec: totalTimeSec
        )
        XCTAssertTrue(actual.isSuccess())

        let actualNotifiedInSeconds = mockNotificationService.addNotificationUsingTimerArguments.map({ arg in
            arg.notifiedInSeconds
        })
        XCTAssertEqual(expectedNotifiedInSeconds, actualNotifiedInSeconds)
    }
}
