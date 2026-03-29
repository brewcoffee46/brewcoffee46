import Factory
import Foundation

/// # Get current date and epoch time.
public protocol DateService: Sendable {
    func now() -> Date

    func nowEpochTimeMillis() -> UInt64
}

public final class DateServiceImpl: DateService {
    public func now() -> Date {
        Date.now
    }

    public func nowEpochTimeMillis() -> UInt64 {
        UInt64(now().timeIntervalSince1970 * 1000)
    }
}

extension Container {
    public var dateService: Factory<DateService> {
        Factory(self) { DateServiceImpl() }.cached
    }
}
