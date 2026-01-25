import SwiftUI

struct NavigationModifier: ViewModifier {
    @EnvironmentObject var viewModel: ConfigViewModel

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
        // In WatchKit App, `RootView` sometimes won't appear when back from background,
        // and directly `StopWatchView` will be shown so if we would use `currentConfigSaveLoadModifier`
        // on `RootView` then the current configuration won't load and use the default configuration.
        .currentConfigSaveLoadModifier(
            $viewModel.currentConfig,
            // For now, there is no load & save function on WatchKit App, so
            // it's OK that `lastUpdateAt` is always `.none`.
            Binding(
                get: { .none },
                set: { _ in () }
            ),
            $viewModel.log
        )
    }
}

extension View {
    func navigation(path: Binding<[Route]>) -> some View {
        self.modifier(NavigationModifier(path: path))
    }
}
