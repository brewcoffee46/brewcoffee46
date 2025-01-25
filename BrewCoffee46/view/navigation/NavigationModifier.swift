import SwiftUI

struct NavigationModifier: ViewModifier {
    @Binding var path: [Route]

    @ViewBuilder
    fileprivate func coordinator(_ route: Route) -> some View {
        switch route {
        case .setting:
            SettingView()
        case .stopwatch:
            StopwatchView()
        case .jsonImportExport:
            JsonImportExportView()
        case .universalLinksImport:
            UniversalLinksImportView()
        case .saveLoad:
            SaveLoadView()
        case .info:
            InfoView()
        case .beforeChecklist:
            BeforeChecklistView()
        }
    }

    func body(content: Content) -> some View {
        NavigationStack(path: $path) {
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
