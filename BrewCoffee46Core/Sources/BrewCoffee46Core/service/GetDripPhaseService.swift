import FactoryKit

/// # Get the Nth phase in the `progressTime`.
public protocol GetDripPhaseService: Sendable {
    func get(
        dripInfo: DripInfo,
        progressTime: Double
    ) -> DripPhase

    func get(
        dripTimings: [DripTiming],
        totalTime: MilliSecond,
        progressTime: Double
    ) -> DripPhase

    func doneOnGoingNextScheduled<A>(
        _ i: Int,
        dripPhase: DripPhase,
        done: A,
        onGoing: A,
        next: A,
        scheduled: A
    ) -> A

    func doneOnGoingScheduled<A>(
        _ i: Int,
        dripPhase: DripPhase,
        done: A,
        onGoing: A,
        scheduled: A
    ) -> A
}

public final class GetDripPhaseServiceImpl: GetDripPhaseService {
    public func get(
        dripInfo: DripInfo,
        progressTime: Double
    ) -> DripPhase {
        get(
            dripTimings: dripInfo.dripTimings,
            totalTime: MilliSecond.fromSecond(dripInfo.totalTimeSec),
            progressTime: progressTime
        )
    }

    public func get(
        dripTimings: [DripTiming],
        totalTime: MilliSecond,
        progressTime: Double
    ) -> DripPhase {
        let totalNumberOfDrip = dripTimings.count

        if progressTime < 0 {
            return DripPhase(
                dripPhaseType: .beforeDrip,
                totalNumberOfDrip: totalNumberOfDrip
            )
        }

        if let nth = dripTimings.firstIndex(where: { e in
            e.dripAt.second > progressTime
        }) {
            return DripPhase(
                dripPhaseType: .dripping(nth),
                totalNumberOfDrip: totalNumberOfDrip
            )
        } else {
            if progressTime > totalTime.second {
                return DripPhase(
                    dripPhaseType: .afterDrip,
                    totalNumberOfDrip: totalNumberOfDrip
                )
            } else {
                return DripPhase(
                    dripPhaseType: .dripping(totalNumberOfDrip),
                    totalNumberOfDrip: totalNumberOfDrip
                )
            }
        }
    }

    public func doneOnGoingNextScheduled<A>(
        _ i: Int,
        dripPhase: DripPhase,
        done: A,
        onGoing: A,
        next: A,
        scheduled: A
    ) -> A {
        switch dripPhase.dripPhaseType {
        case .dripping(let n):
            if n - 1 == i {
                return onGoing
            } else if n == i {
                return next
            } else if n > i {
                return done
            } else {
                return scheduled
            }
        case .beforeDrip:
            return scheduled
        case .afterDrip:
            return done
        }
    }

    public func doneOnGoingScheduled<A>(
        _ i: Int,
        dripPhase: DripPhase,
        done: A,
        onGoing: A,
        scheduled: A
    ) -> A {
        doneOnGoingNextScheduled(
            i,
            dripPhase: dripPhase,
            done: done,
            onGoing: onGoing,
            next: scheduled,
            scheduled: scheduled
        )
    }
}

extension Container {
    public var getDripPhaseService: Factory<GetDripPhaseService> {
        Factory(self) { GetDripPhaseServiceImpl() }.cached
    }
}
