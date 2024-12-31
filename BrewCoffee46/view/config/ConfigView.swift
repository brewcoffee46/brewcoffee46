import BrewCoffee46Core
import Factory
import SwiftUI
import SwiftUITooltip

@MainActor
struct ConfigView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Injected(\.saveLoadConfigService) private var saveLoadConfigService
    @Injected(\.watchConnectionService) private var watchConnectionService
    @Injected(\.configurationLinkService) private var configurationLinkService

    @Environment(\.scenePhase) private var scenePhase

    @State var showTips: Bool = false
    @State var calculateCoffeeBeansWeightFromWater: Bool = false {
        didSet {
            temporaryWaterAmount = viewModel.currentConfig.totalWaterAmount()
        }
    }
    @State var temporaryWaterAmount: Double = Config.initCoffeeBeansWeight * Config.initWaterToCoffeeBeansWeightRatio {
        didSet {
            viewModel.currentConfig.coffeeBeansWeight = roundCentesimal(temporaryWaterAmount / viewModel.currentConfig.waterToCoffeeBeansWeightRatio)
        }
    }
    @State var didSuccessSendingConfig: Bool? = .none

    // This will be calculated initially using the current configuration so it's not necessary ` ConfigurationLinkServiceImpl.universalLinksBaseURL`
    // but if the type of `universalLinksConfigUrl` would be `URL?` it's not convenience so
    // for now we assign `ConfigurationLinkServiceImpl.universalLinksBaseURL`.
    @State var universalLinksConfigUrl: URL = ConfigurationLinkServiceImpl.universalLinksBaseURL

    private let digit = 1
    private let timerStep: Double = 1.0
    private let coffeeBeansWeightMax = 50.0
    private let coffeeBeansWeightMin = 1.0

    var body: some View {
        Form {
            Toggle("config show tips", isOn: $showTips)

            Section(header: Text("config save load setting")) {
                TipsView(
                    showTips,
                    content: HStack {
                        Text(viewModel.currentConfig.note ??? NSLocalizedString("config note empty string", comment: ""))
                        Spacer()
                        Text(
                            (viewModel.currentConfigLastUpdatedAt ?? viewModel.currentConfig.editedAtMilliSec)?.toDate().formattedWithSec()
                                ?? NSLocalizedString("config none last edited at", comment: ""))
                    },
                    tips: Text("config show current note tips")
                )

                NavigationLink(value: Route.saveLoad) {
                    Text("config save load setting")
                }

                ShareLink(item: universalLinksConfigUrl) {
                    Label("config universal links url share current config", systemImage: "square.and.arrow.up")
                }.onChange(of: viewModel.currentConfig, initial: true) {
                    configurationLinkService
                        .generate(
                            config: viewModel.currentConfig,
                            currentConfigLastUpdatedAt: viewModel.currentConfigLastUpdatedAt
                        )
                        .map { universalLinksConfigUrl = $0 }
                        .recoverWithErrorLog(&viewModel.errors)
                }
            }

            if watchConnectionService.isPaired() {
                Section(header: Text("config watchos app setting")) {
                    Button(action: {
                        didSuccessSendingConfig = .none
                        switch viewModel.currentConfig.toJSON(isPrettyPrint: false) {
                        case .success(let json):
                            Task {
                                let result = await watchConnectionService.sendConfigAsJson(json)
                                switch result {
                                case .success():
                                    didSuccessSendingConfig = true
                                case .failure(let error):
                                    viewModel.errors = error.getAllErrorMessage()
                                    didSuccessSendingConfig = false
                                }
                            }
                        case .failure(let error):
                            didSuccessSendingConfig = false
                            viewModel.errors = error.getAllErrorMessage()
                        }
                    }) {
                        VStack {
                            HStack {
                                Text("config send current setting to watchos app")
                                Spacer()
                                Group {
                                    if let didSuccessSendingConfig {
                                        if didSuccessSendingConfig {
                                            Image(systemName: "gear.badge.checkmark")
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "gear.badge.xmark")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .onChange(of: viewModel.currentConfig) {
                                    didSuccessSendingConfig = .none
                                }
                            }
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }

            Section(header: Text("config weight settings")) {
                TipsView(
                    showTips,
                    content: Picker("", selection: $calculateCoffeeBeansWeightFromWater) {
                        Text("config calculate water from coffee beans").tag(false)
                        Text("config calculate coffee beans from water").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: calculateCoffeeBeansWeightFromWater) { _, newValue in
                        if newValue {
                            temporaryWaterAmount = viewModel.currentConfig.totalWaterAmount()
                        }
                    },
                    tips: Text("config calculate coffee beans from water tips")
                )
                if calculateCoffeeBeansWeightFromWater {
                    waterAmountSettingView
                } else {
                    coffeeBeansWeightSettingView
                }
                VStack {
                    TipsView(
                        showTips,
                        content: HStack {
                            Text("config water ratio")
                            Text("\(String(format: "%.1f%", viewModel.currentConfig.waterToCoffeeBeansWeightRatio))")

                        },
                        tips: Text("config water ratio tips")
                    )
                    ButtonSliderButtonView(
                        maximum: 20,
                        minimum: 3,
                        sliderStep: 1,
                        buttonStep: 0.1,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $viewModel.currentConfig.waterToCoffeeBeansWeightRatio
                    )
                    .onChange(of: viewModel.currentConfig.waterToCoffeeBeansWeightRatio) {
                        temporaryWaterAmount = viewModel.currentConfig.totalWaterAmount()
                    }
                }
            }

            Section(header: Text("config 4:6 settings")) {
                VStack {
                    TipsView(
                        showTips,
                        content: HStack {
                            Text("config 1st water percent")
                            Text("\(String(format: "%.0f%", viewModel.currentConfig.firstWaterPercent * 100))%")

                        },
                        tips: Text("config 1st water percent tips")
                    )
                    ButtonSliderButtonView(
                        maximum: 1.0,
                        minimum: 0.01,
                        sliderStep: 0.05,
                        buttonStep: 0.01,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $viewModel.currentConfig.firstWaterPercent
                    )
                }

                VStack {
                    TipsView(
                        showTips,
                        content: Text("config number of partitions of later 6"),
                        tips: Text("config number of partitions of later 6 tips")
                    )
                    ButtonNumberButtonView(
                        maximum: 10,
                        minimum: 1,
                        step: 1.0,
                        isDisable: appEnvironment.isTimerStarted.getOnlyBinding,
                        target: $viewModel.currentConfig.partitionsCountOf6
                    )
                }
            }

            Section(header: Text("config timer setting")) {
                VStack {
                    TipsView(
                        showTips,
                        content: HStack {
                            Text("config total time")
                            Text(
                                "\(String(format: "%.0f", viewModel.currentConfig.totalTimeSec))\(NSLocalizedString("config sec unit", comment: ""))")
                            Spacer()
                        },
                        tips: Text("config total time tips")
                    )
                    ButtonSliderButtonView(
                        maximum: 300.0,
                        // If `totalTime` would be going down less than `steamingTime` + its step,
                        // then `SliderView` will crash so this `steamingTime + timerStep` is needed to avoid crash.
                        minimum: viewModel.currentConfig.steamingTimeSec + timerStep,
                        sliderStep: timerStep,
                        buttonStep: timerStep,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $viewModel.currentConfig.totalTimeSec
                    )
                }

                VStack {
                    HStack {
                        Text("config steaming time")
                        Text("\(String(format: "%.0f", viewModel.currentConfig.steamingTimeSec))\(NSLocalizedString("config sec unit", comment: ""))")
                        Spacer()
                    }
                    ButtonSliderButtonView(
                        // This is required to avoid crash.
                        // If the maximum is `viewModel.totalTime - timerStep` then
                        // `totalTime`'s slider range could be 300~300 and it will crash
                        // so that's the why `timerStep` double subtractions are required.
                        maximum: viewModel.currentConfig.totalTimeSec - timerStep - timerStep > 1 + timerStep
                            ? viewModel.currentConfig.totalTimeSec - timerStep - timerStep : 1 + timerStep,
                        minimum: 1,
                        sliderStep: timerStep,
                        buttonStep: timerStep,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $viewModel.currentConfig.steamingTimeSec
                    )
                }
            }

            Section(header: Text("config json")) {
                NavigationLink(value: Route.jsonImportExport) {
                    Text("config import export")
                }
            }

            Section {
                HStack {
                    FeedbackView()
                }
                HStack {
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/jp/app/brewcoffee46/id6449224023")!
                    ) {
                        Label("info share app", systemImage: "square.and.arrow.up")
                    }
                }
                NavigationLink(value: Route.info) {
                    Text("config information")
                }
            }
        }
        .navigationTitle("navigation title configuration")
        .navigation(path: $appEnvironment.configPath)
        .currentConfigSaveLoadModifier(
            $viewModel.currentConfig,
            $viewModel.currentConfigLastUpdatedAt,
            $viewModel.errors
        )
    }

    private var coffeeBeansAndWaterWeightView: some View {
        HStack {
            Spacer()
            Group {
                Text("config coffee beans weight")
                    .font(
                        !calculateCoffeeBeansWeightFromWater ? Font.headline.weight(.bold) : Font.headline.weight(.regular)
                    )
                Text("\(String(format: "%.1f", viewModel.currentConfig.coffeeBeansWeight))\(weightUnit)")
                    .onChange(of: temporaryWaterAmount) { _, newValue in
                        viewModel.currentConfig.coffeeBeansWeight = roundCentesimal(newValue / viewModel.currentConfig.waterToCoffeeBeansWeightRatio)
                    }
            }
            .font(
                !calculateCoffeeBeansWeightFromWater ? Font.headline.weight(.bold) : Font.headline.weight(.regular)
            )
            Spacer()
            Spacer()
            Spacer()
            Group {
                Text("config water amount")
                Text("\(String(format: "%.1f", temporaryWaterAmount))\(weightUnit)")
                    .onChange(of: viewModel.currentConfig.coffeeBeansWeight, initial: true) { _, newValue in
                        // When `calculateCoffeeBeansWeightFromWater = true` then `temporaryWaterAmount` has more priority than the coffee beans weight so
                        // we stop calculation of `temporaryWaterAmount` from the coffee beans weight.
                        if !calculateCoffeeBeansWeightFromWater {
                            temporaryWaterAmount = viewModel.currentConfig.totalWaterAmount()
                        }
                    }
            }
            .font(
                calculateCoffeeBeansWeightFromWater ? Font.headline.weight(.bold) : Font.headline.weight(.regular)
            )
            Spacer()
        }
    }

    private var coffeeBeansWeightSettingView: some View {
        VStack {
            coffeeBeansAndWaterWeightView
            NumberPickerView(
                digit: digit,
                max: coffeeBeansWeightMax,
                target: $viewModel.currentConfig.coffeeBeansWeight,
                isDisable: $appEnvironment.isTimerStarted
            )
        }
    }

    private var waterAmountSettingView: some View {
        VStack {
            coffeeBeansAndWaterWeightView
            NumberPickerView(
                digit: digit,
                max: coffeeBeansWeightMax * viewModel.currentConfig.waterToCoffeeBeansWeightRatio,
                target: $temporaryWaterAmount,
                isDisable: $appEnvironment.isTimerStarted
            )
        }
    }
}

extension ConfigView {
    static let temporaryCurrentConfigKey = "temporaryCurrentConfig"
}

#if DEBUG
    struct ConfigView_Previews: PreviewProvider {
        static var previews: some View {
            ConfigView()
                .environment(\.locale, .init(identifier: "ja"))
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
        }
    }
#endif
