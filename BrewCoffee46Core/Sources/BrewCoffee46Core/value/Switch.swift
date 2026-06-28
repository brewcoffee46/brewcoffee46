import SwiftUI

/// `Switch` represents open/close status of HARIO Switch.
///   * `open`: keep brewing
///   * `close`: stop brewing
public enum Switch: String, Codable, Equatable, Hashable, Sendable {
    case open
    case close

    public mutating func toggle() {
        switch self {
        case .open:
            self = .close
        case .close:
            self = .open
        }
    }
}

extension Switch {
    public func toBool() -> Bool {
        switch self {
        case .open:
            return true
        case .close:
            return false
        }
    }

    public static func fromBool(_ value: Bool) -> Self {
        switch value {
        case true:
            return .open
        case false:
            return .close
        }
    }
}
