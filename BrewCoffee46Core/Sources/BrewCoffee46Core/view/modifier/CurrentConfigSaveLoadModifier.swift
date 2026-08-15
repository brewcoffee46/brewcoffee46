import FactoryKit
import SwiftUI

/// When leave/back app, load/save the current configuration.
public struct CurrentConfigSaveLoadModifier: ViewModifier {
    @Binding var currentConfig: AppConfig
    @Binding var errors: String

    @Injected(\.saveLoadConfigService) private var saveLoadConfigService
    @Environment(\.scenePhase) private var scenePhase

    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldValue, newValue in
                switch newValue {
                case .background:
                    saveLoadConfigService
                        .saveCurrentConfig(currentConfig)
                        .recoverWithErrorLog(&errors)
                case .inactive:
                    switch oldValue {
                    case .active:
                        saveLoadConfigService
                            .saveCurrentConfig(currentConfig)
                            .recoverWithErrorLog(&errors)
                    case .background:
                        ()
                    default:
                        ()
                    }
                case .active:
                    // In ConfigViewModel(watchOS App) / CurrentConfigViewModel(iOS App), their `init()` load
                    // the previous current configuration so in strictly speaking it's maybe not necessary to load
                    // current config at this case.
                    saveLoadConfigService
                        .loadCurrentConfig()
                        .map { $0.map { currentConfig = $0 } }
                        .recoverWithErrorLog(&errors)
                @unknown default:
                    ()
                }
            }
    }
}

extension View {
    public func currentConfigSaveLoadModifier(
        _ config: Binding<AppConfig>,
        _ errors: Binding<String>
    ) -> some View {
        self.modifier(
            CurrentConfigSaveLoadModifier(
                currentConfig: config,
                errors: errors
            )
        )
    }
}
