import BrewCoffee46Core
import Factory
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appEnvironment: WatchKitAppEnvironment
    @EnvironmentObject var viewModel: ConfigViewModel

    @Injected(\.saveLoadConfigService) private var saveLoadConfigService

    var body: some View {
        List {
            NavigationLink(value: Route.selectConfig) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("watch kit app current setting")
                            .font(.system(size: 10))
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        Text(viewModel.currentConfig.note ??? NSLocalizedString("config note empty string", comment: ""))
                        Spacer()
                        Image(systemName: "ellipsis.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                    }
                }
            }
            .disabled(appEnvironment.isTimerStarted)

            Stepper(value: $viewModel.currentConfig.coffeeBeansWeight, step: 0.1) {
                Text("\(viewModel.currentConfig.coffeeBeansWeight, specifier: "%.1f")\(weightUnit)")
                    .font(.system(size: 19))
            }
            .disabled(appEnvironment.isTimerStarted)

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

            navigationLink(
                route: .info,
                imageName: "info.circle",
                imageColor: .gray,
                navigationTitle: "navigation title information"
            )
        }
        .onAppear {
            if viewModel.allConfigs.isEmpty {
                saveLoadConfigService.loadAll().map {
                    if let allConfigs = $0 {
                        viewModel.allConfigs = allConfigs
                    }
                }.forEachError { viewModel.log = $0.getAllErrorMessage() }
            }
        }
        .navigation(path: $appEnvironment.rootPath)
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
                .environmentObject(ConfigViewModel())
        }
    }
#endif
