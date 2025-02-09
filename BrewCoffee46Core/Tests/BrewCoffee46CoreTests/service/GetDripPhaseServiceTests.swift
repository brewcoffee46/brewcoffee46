import XCTest

@testable import BrewCoffee46Core

final class GetDripPhaseServiceTests: XCTestCase {
    let sut = GetDripPhaseServiceImpl()

    func test_return_beforeDrip_if_the_progress_time_less_than_0() throws {
        let actual = sut.get(
            dripInfo: DripInfo.defaultValue(),
            progressTime: -0.1
        )
        XCTAssertEqual(actual, DripPhase.defaultValue())
    }

    func test_return_dripping_if_the_progress_time_between_1st_and_2nd_drip_at() throws {
        let actual = sut.get(
            dripInfo: DripInfo.defaultValue(),
            progressTime: 10
        )
        XCTAssertEqual(actual.dripPhaseType, .dripping(1))
    }

    func test_return_dripping_last_inedx_if_the_progress_time_is_close_total_time() throws {
        let actual = sut.get(
            dripInfo: DripInfo.defaultValue(),
            progressTime: DripInfo.defaultValue().totalTimeSec
        )
        XCTAssertEqual(actual.dripPhaseType, .dripping(DripInfo.defaultValue().dripTimings.count))
    }

    func test_return_after_drip_if_the_progress_time_is_expired_at_total_time() throws {
        let actual = sut.get(
            dripInfo: DripInfo.defaultValue(),
            progressTime: DripInfo.defaultValue().totalTimeSec + 0.1
        )
        XCTAssertEqual(actual.dripPhaseType, .afterDrip)
    }

    func test_return_scheduled_if_the_progressTime_is_less_than_zero() throws {
        let dripPhase = sut.get(
            dripInfo: DripInfo.defaultValue(),
            progressTime: -1
        )

        for i in 0..<dripPhase.totalNumberOfDrip {
            let actual = sut.doneOnGoingNextScheduled(
                i,
                dripPhase: dripPhase,
                done: "done",
                onGoing: "onGoing",
                next: "next",
                scheduled: "scheduled"
            )
            XCTAssertEqual(actual, "scheduled")
        }
    }

    func test_return_properly_value_when_progressTime_is_zero() throws {
        let dripPhase = sut.get(
            dripInfo: DripInfo.defaultValue(),
            progressTime: 0
        )

        let actual1 = sut.doneOnGoingNextScheduled(
            0,
            dripPhase: dripPhase,
            done: "done",
            onGoing: "onGoing",
            next: "next",
            scheduled: "scheduled"
        )
        XCTAssertEqual(actual1, "onGoing")

        let actual2 = sut.doneOnGoingNextScheduled(
            1,
            dripPhase: dripPhase,
            done: "done",
            onGoing: "onGoing",
            next: "next",
            scheduled: "scheduled"
        )
        XCTAssertEqual(actual2, "next")

        for i in 2..<dripPhase.totalNumberOfDrip {
            let actual3 = sut.doneOnGoingNextScheduled(
                i,
                dripPhase: dripPhase,
                done: "done",
                onGoing: "onGoing",
                next: "next",
                scheduled: "scheduled"
            )
            XCTAssertEqual(actual3, "scheduled")
        }
    }
}
