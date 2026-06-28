import FactoryKit
import Foundation

/// `DripIndexTextFormatterService` formats a zero-based drip index into localized text such as "1st drip" or "1投目".
public protocol DripIndexTextFormatterService: Sendable {
    func dripText(_ index: Int) -> String
}

public final class DripIndexTextFormatterServiceImpl: DripIndexTextFormatterService {
    public func dripText(_ index: Int) -> String {
        let dripNumber = index + 1

        switch dripNumber {
        case 1:
            return NSLocalizedString("drip ordinal 1", comment: "")
        case 2:
            return NSLocalizedString("drip ordinal 2", comment: "")
        case 3:
            return NSLocalizedString("drip ordinal 3", comment: "")
        default:
            return String(
                format: NSLocalizedString("drip ordinal n", comment: ""),
                dripNumber
            )
        }
    }
}

extension Container {
    public var dripIndexTextFormatterService: Factory<DripIndexTextFormatterService> {
        Factory(self) { DripIndexTextFormatterServiceImpl() }.cached
    }
}
