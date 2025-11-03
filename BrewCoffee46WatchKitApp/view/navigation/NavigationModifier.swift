import SwiftUI

struct NavigationModifier: ViewModifier {
    @Binding var path: [Route]

    @ViewBuilder
    fileprivate func coordinator(_ route: Route) -> some View {
        switch route {
        case .root:
            RootView()
        case .config:
            ConfigView()
        case .selectConfig:
            SelectConfigView()
        case .stopwatch:
            StopwatchView()
        case .info:
            InfoView()
        }
    }

    func body(content: Content) -> some View {
        NavigationStack {
            content
                .navigationDestination(for: Route.self) { route in
                    coordinator(route)
                }
        }
    }
}

extension View {
    func navigation(path: Binding<[Route]>) -> some View {
        self.modifier(NavigationModifier(path: path))
    }
}
