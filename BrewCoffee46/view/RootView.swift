import SwiftUI

struct RootView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    var body: some View {
        TabView(selection: appEnvironment.tabSelection) {
            BeforeChecklistView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("navigation title before checklist")
                }
                .tag(Route.beforeChecklist)
            StopwatchView()
                .tabItem {
                    Image(systemName: "stopwatch")
                    Text("navigation title stopwatch")
                }
                .tag(Route.stopwatch)
            SettingView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("navigation title configuration")
                }
                .tag(Route.setting)
        }
    }
}

#if DEBUG
    struct RootView_Previews: PreviewProvider {
        @ObservedObject static var appEnvironment: AppEnvironment = .init()
        @ObservedObject static var viewModel: CurrentConfigViewModel = CurrentConfigViewModel()
        @State static var progressTime = 55
        static var previews: some View {
            RootView()
                .environmentObject(appEnvironment)
                .environmentObject(viewModel)
        }
    }
#endif
