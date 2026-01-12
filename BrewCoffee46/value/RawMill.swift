import Foundation

struct RawMill: Equatable, Identifiable {
    /// `RawMill` is used in `ForEach` view and its ordering is editable by `EditButton`.
    /// If a `RawMill` data which is same `name` and `value` then `ForEach` doesn't distinguish
    /// which data will be edited. So `id` is required to identify which data would be edited.
    let id: UUID = UUID()

    var name: String
    var value: String
}

extension RawMill {
    static let defaultValue = RawMill(
        name: NSLocalizedString("config mill name default", comment: ""),
        value: NSLocalizedString("config mill value default", comment: ""),
    )
}
