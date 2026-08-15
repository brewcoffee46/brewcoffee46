import BrewCoffee46Core
import Foundation
import SwiftUI

struct ConfigLoadAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedConfig: CoffeeConfig?

    let onLoad: (CoffeeConfig) -> Void

    func body(content: Content) -> some View {
        content.alert(
            "config load setting alert title",
            isPresented: $isPresented,
            presenting: selectedConfig
        ) { config in
            Button("config load setting alert cancel", role: .cancel) {
                selectedConfig = nil
            }
            Button("config load setting alert load", role: .destructive) {
                onLoad(config)
                selectedConfig = nil
            }
        } message: { config in
            Text(
                String(
                    format: NSLocalizedString("config load setting alert message", comment: ""),
                    config.note ??? NSLocalizedString("config note empty string", comment: ""),
                    config.editedAtMilliSec?.toDate().formattedWithSec()
                        ?? NSLocalizedString("config none last edited at", comment: "")
                )
            )
        }
    }
}

extension View {
    func configLoadAlert(
        isPresented: Binding<Bool>,
        selectedConfig: Binding<CoffeeConfig?>,
        onLoad: @escaping (CoffeeConfig) -> Void
    ) -> some View {
        modifier(
            ConfigLoadAlertModifier(
                isPresented: isPresented,
                selectedConfig: selectedConfig,
                onLoad: onLoad
            )
        )
    }
}
