import BrewCoffee46Core
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    var body: some View {
        List {
            if let note = viewModel.currentConfig.note, note != "" {
                VStack(alignment: .leading) {
                    HStack {
                        Text("watch kit app current setting")
                            .font(.system(size: 10))
                    }
                    Spacer()
                    Text(note)
                }
            }

            Stepper(value: $viewModel.currentConfig.coffeeBeansWeight, step: 0.1) {
                Text("\(String(format: "%.1f", viewModel.currentConfig.coffeeBeansWeight))\(weightUnit)")
                    .font(.system(size: 19))
            }

            navigationLink(
                route: .stopwatch,
                imageName: "stopwatch",
                imageColor: .yellow,
                navigationTitle: "navigation title stopwatch"
            )

            navigationLink(
                route: .config,
                imageName: "slider.horizontal.3",
                imageColor: .green,
                navigationTitle: "navigation title configuration"
            )
        }
        .navigation(path: $appEnvironment.rootPath)
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

    private func navigationLink(
        route: Route,
        imageName: String,
        imageColor: Color,
        navigationTitle: String
    ) -> some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(imageColor)
                        .frame(width: 30, height: 40, alignment: .leading)
                    Spacer()
                    Image(systemName: "ellipsis.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
                HStack {
                    Spacer()
                    Text(NSLocalizedString(navigationTitle, comment: ""))
                }
            }
        }
    }
}

#if DEBUG
    struct RootView_Perviews: PreviewProvider {
        static var previews: some View {
            RootView()
                .environmentObject(WatchKitAppEnvironment())
                .environmentObject(CurrentConfigViewModel())
        }
    }
#endif
