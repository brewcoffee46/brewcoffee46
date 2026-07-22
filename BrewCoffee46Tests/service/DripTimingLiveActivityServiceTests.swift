import BrewCoffee46Core
import BrewCoffee46TestsShared
import FactoryKit
import XCTest

@testable import BrewCoffee46

final class DripTimingLiveActivityServiceTests: XCTestCase {
    private enum dummyError: Error, Equatable {
        case requestFailed
    }

    override func setUp() {
        Container.shared.reset()
        super.setUp()
    }

    let recipeName = "recipe name"
    let startedAt = getDate()
    let dripInfo = DripInfo.defaultValue()

    func test_start_setsStaleDate_andEndsExisting() async throws {
        var appConfig = AppConfig.defaultValue()
        appConfig.coffeeConfig.note = recipeName

        let mock = MockLiveActivityService()
        Container.shared.liveActivityService.register { mock }
        let sut = DripTimingLiveActivityServiceImpl()

        let actual = await sut.startLiveActivity(appConfig: appConfig, dripInfo: dripInfo, startedAt: startedAt)
        XCTAssertTrue(actual.isSuccess())
        XCTAssertTrue(mock.didCallEndAll)

        let expectedAttribute = DripTimingAttributes(
            startedAt: startedAt,
            recipeName: recipeName,
            coffeeBeansWeight: GlobalConfig.defaultValue().coffeeBeansWeightMg,
            totalWaterAmount: MilliGram.fromGram(DripInfo.defaultValue().waterAmount.totalAmount()),
            dripTimings: DripInfo.defaultValue().dripTimings,
            totalTime: appConfig.coffeeConfig.totalTimeMilliSec
        )

        XCTAssertEqual(mock.requestedAttributes.count, 1)
        XCTAssertEqual(mock.requestedAttributes.first, expectedAttribute)

        XCTAssertEqual(mock.requestedStaleDates.count, 1)
        let expectedStale = startedAt.addingTimeInterval(dripInfo.totalTimeSec)
        XCTAssertEqual(mock.requestedStaleDates.first, expectedStale)
    }

    func test_stop_endsActivityIdentifiedByHandle() async throws {
        let mock = MockLiveActivityService()
        Container.shared.liveActivityService.register { mock }
        let sut = DripTimingLiveActivityServiceImpl()
        let handle = LiveActivityHandle<DripTimingAttributes>(id: "activity-to-stop")

        let actual = await sut.stopLiveActivity(handle: handle)

        XCTAssertTrue(actual.isSuccess())
        XCTAssertEqual(mock.endedActivities.count, 1)
        XCTAssertEqual(mock.endedActivities.first?.handle, handle)
    }

    func test_start_returnsActivitiesNotEnabled_whenActivitiesAreDisabled() async {
        let mock = MockLiveActivityService()
        mock.enabled = false
        Container.shared.liveActivityService.register { mock }
        let sut = DripTimingLiveActivityServiceImpl()

        let actual = await sut.startLiveActivity(
            appConfig: AppConfig.defaultValue(),
            dripInfo: dripInfo,
            startedAt: startedAt
        )

        XCTAssertTrue(actual.isFailure())
        actual.forEachError { errors in
            XCTAssertEqual(errors, NonEmptyArray(CoffeeError.activitiesNotEnabled))
        }
        XCTAssertFalse(mock.didCallEndAll)
        XCTAssertTrue(mock.requestedAttributes.isEmpty)
    }

    func test_start_wrapsLiveActivityRequestError() async {
        let mock = MockLiveActivityService()
        mock.requestError = dummyError.requestFailed
        Container.shared.liveActivityService.register { mock }
        let sut = DripTimingLiveActivityServiceImpl()

        let actual = await sut.startLiveActivity(
            appConfig: AppConfig.defaultValue(),
            dripInfo: dripInfo,
            startedAt: startedAt
        )

        XCTAssertTrue(actual.isFailure())
        actual.forEachError { errors in
            XCTAssertEqual(errors.count(), 1)
            XCTAssertEqual(errors, NonEmptyArray(CoffeeError.liveActivityRequestFailed(dummyError.requestFailed)))
        }
        XCTAssertTrue(mock.didCallEndAll)
        XCTAssertEqual(mock.requestedAttributes.count, 1)
    }
}
