import SwiftUI

public struct MillItemModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

extension View {
    public func millItemModifier() -> some View {
        self.modifier(MillItemModifier())
    }
}
