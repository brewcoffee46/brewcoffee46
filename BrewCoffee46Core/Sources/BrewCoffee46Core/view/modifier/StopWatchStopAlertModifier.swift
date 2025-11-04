import Factory
import SwiftUI

public struct StopWatchStopAlertModifier: ViewModifier {
    @Binding var isStop︎AlertPresented: Bool
    let stopTimer: () -> Void

    public func body(content: Content) -> some View {
        content
            .alert("stop alert title", isPresented: $isStop︎AlertPresented) {
                Button(role: .cancel, action: { isStop︎AlertPresented.toggle() }) {
                    Text("stop alert cancel")
                }
                Button(
                    role: .destructive,
                    action: {
                        isStop︎AlertPresented.toggle()
                        stopTimer()
                    }
                ) {
                    Text("stop alert stop")
                }
            } message: {
                Text("stop alert message")
            }
    }

}

extension View {
    public func stopWatchStopAlertModifier(
        _ isStop︎AlertPresented: Binding<Bool>,
        _ stopTimer: @escaping () -> Void
    ) -> some View {
        self.modifier(
            StopWatchStopAlertModifier(
                isStop︎AlertPresented: isStop︎AlertPresented,
                stopTimer: stopTimer
            )
        )
    }
}
