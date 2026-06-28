import SwiftUI

extension Bool {
    public var getOnlyBinding: Binding<Bool> {
        Binding(
            get: { self },
            set: { _ in () }
        )
    }
}
extension Binding where Value == Bool {
    public func withAnimation(_ animation: Animation? = .default) -> Binding<Bool> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                SwiftUI.withAnimation(animation) {
                    wrappedValue = newValue
                }
            }
        )
    }
}
