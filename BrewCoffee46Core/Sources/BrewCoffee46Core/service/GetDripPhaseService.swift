import Factory

/// # Get the Nth phase in the `progressTime`.
public protocol GetDripPhaseService: Sendable {
    func get(
        dripInfo: DripInfo,
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
    public func get(dripInfo: DripInfo, progressTime: Double) -> DripPhase {
        let totalNumberOfDrip = dripInfo.dripTimings.count

        if progressTime < 0 {
            return DripPhase(
                dripPhaseType: .beforeDrip,
                totalNumberOfDrip: totalNumberOfDrip
            )
        }

        if let nth = dripInfo.dripTimings.firstIndex(where: { e in
            e.dripAt > progressTime
        }) {
            return DripPhase(
                dripPhaseType: .dripping(nth),
                totalNumberOfDrip: totalNumberOfDrip
            )
        } else {
            if progressTime > dripInfo.totalTimeSec {
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
