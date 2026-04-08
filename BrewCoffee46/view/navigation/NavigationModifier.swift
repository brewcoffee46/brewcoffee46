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
    func navigation(path: Binding<[Route]>, title: String) -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.system(size: 28, weight: .bold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .modifier(NavigationModifier(path: path))
    }
}
