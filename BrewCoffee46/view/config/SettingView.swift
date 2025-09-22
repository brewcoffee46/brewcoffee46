import BrewCoffee46Core
import Factory
import SwiftUI
import SwiftUITooltip
import TipKit

@MainActor
struct SettingView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Injected(\.dateService) private var dateService
    @Injected(\.rawSettingConvertService) private var rawSettingConvertService
    @Injected(\.watchConnectionService) private var watchConnectionService
    @Injected(\.configurationLinkService) private var configurationLinkService

    @Environment(\.scenePhase) private var scenePhase

    @State private var rawSetting: RawSetting = RawSetting.defaultValue()

    @State private var showTips: Bool = false
    @State private var didSuccessSendingConfig: Bool? = .none
    @State private var showTipsWhenSendingConfigFailure: Bool = false

    // This will be calculated initially using the current configuration so it's not necessary ` ConfigurationLinkServiceImpl.universalLinksBaseURL`
    // but if the type of `universalLinksConfigUrl` would be `URL?` it's not convenience so
    // for now we assign `ConfigurationLinkServiceImpl.universalLinksBaseURL`.
    @State private var universalLinksConfigUrl: URL = ConfigurationLinkServiceImpl.universalLinksBaseURL

    private let digit = 1
    private let timerStep: Double = 1.0
    private let coffeeBeansWeightMax = 125.0
    private let coffeeBeansWeightMin = 1.0

    var body: some View {
        Form {
            Toggle("config show tips", isOn: $showTips)
            TipView(TipsTip(), arrowEdge: .top)

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
                TipView(UniversalLinksIssueTip(), arrowEdge: .top)
            }

            if watchConnectionService.isPaired() {
                Section(header: Text("config watchos app setting")) {
                    Button(action: {
                        didSuccessSendingConfig = .none
                        showTipsWhenSendingConfigFailure = false

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
                                    showTipsWhenSendingConfigFailure = true
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

                    if showTipsWhenSendingConfigFailure {
                        HStack(alignment: .center) {
                            Image(systemName: "lightbulb.max")
                            Text("config watchos sending failure tips")
                                .font(Font.footnote.weight(.light))
                        }
                    }
                }
            }

            Section(header: Text("config weight settings")) {
                TipsView(
                    showTips,
                    content: Picker("", selection: $rawSetting.calculateCoffeeBeansWeightFromWater) {
                        Text("config calculate water from coffee beans").tag(false)
                        Text("config calculate coffee beans from water").tag(true)
                    }
                    .pickerStyle(.segmented),
                    tips: Text("config calculate coffee beans from water tips")
                )
                Group {
                    if rawSetting.calculateCoffeeBeansWeightFromWater {
                        waterAmountSettingView
                    } else {
                        coffeeBeansWeightSettingView
                    }
                }
                TipView(WeightTip(), arrowEdge: .top)
                VStack {
                    TipView(OtherTip(), arrowEdge: .bottom)
                    TipsView(
                        showTips,
                        content: HStack {
                            Text("config water ratio")
                            Text("\(String(format: "%.1f%", rawSetting.waterToCoffeeBeansWeightRatio))")

                        },
                        tips: Text("config water ratio tips")
                    )
                    ButtonSliderButtonView(
                        maximum: 20,
                        minimum: 3,
                        sliderStep: 1,
                        buttonStep: 0.1,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $rawSetting.waterToCoffeeBeansWeightRatio
                    )
                }
            }

            Section(header: Text("config 4:6 settings")) {
                VStack {
                    TipsView(
                        showTips,
                        content: HStack {
                            Text("config 1st water percent")
                            Text("\(String(format: "%.0f%", rawSetting.firstWaterPercent * 100))%")

                        },
                        tips: Text("config 1st water percent tips")
                    )
                    ButtonSliderButtonView(
                        maximum: 1.0,
                        minimum: 0.01,
                        sliderStep: 0.05,
                        buttonStep: 0.01,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $rawSetting.firstWaterPercent
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
                        target: $rawSetting.partitionsCountOf6
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
                                "\(String(format: "%.0f", rawSetting.totalTimeSec))\(NSLocalizedString("config sec unit", comment: ""))")
                            Spacer()
                        },
                        tips: Text("config total time tips")
                    )
                    ButtonSliderButtonView(
                        maximum: 300.0,
                        // If `totalTime` would be going down less than `steamingTime` + its step,
                        // then `SliderView` will crash so this `steamingTime + timerStep` is needed to avoid crash.
                        minimum: rawSetting.steamingTimeSec + timerStep,
                        sliderStep: timerStep,
                        buttonStep: timerStep,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $rawSetting.totalTimeSec
                    )
                }

                VStack {
                    HStack {
                        Text("config steaming time")
                        Text("\(String(format: "%.0f", rawSetting.steamingTimeSec))\(NSLocalizedString("config sec unit", comment: ""))")
                        Spacer()
                    }
                    ButtonSliderButtonView(
                        // This is required to avoid crash.
                        // If the maximum is `viewModel.totalTime - timerStep` then
                        // `totalTime`'s slider range could be 300~300 and it will crash
                        // so that's the why `timerStep` double subtractions are required.
                        maximum: rawSetting.totalTimeSec - timerStep - timerStep > 1 + timerStep
                            ? rawSetting.totalTimeSec - timerStep - timerStep : 1 + timerStep,
                        minimum: 1,
                        sliderStep: timerStep,
                        buttonStep: timerStep,
                        isDisable: appEnvironment.isTimerStarted,
                        target: $rawSetting.steamingTimeSec
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
        .onChange(of: viewModel.currentConfig, initial: true) { _, newValue in
            rawSetting = rawSettingConvertService.fromConfig(newValue, rawSetting)
        }
        .onChange(of: rawSetting) { _, newValue in
            rawSettingConvertService.toConfig(newValue, viewModel.currentConfig).map { config in
                viewModel.currentConfig = config
                viewModel.currentConfigLastUpdatedAt = dateService.nowEpochTimeMillis()

                // We have to feedback beans weight from water amount or its inverse.
                // Due to this feedback, this `onChange` will be called at most twice unfortunately
                // but for now we don't know the better way.
                if rawSetting.calculateCoffeeBeansWeightFromWater {
                    rawSetting.coffeeBeansWeight = config.coffeeBeansWeight
                } else {
                    rawSetting.waterAmount = config.totalWaterAmount()
                }
            }
            .recoverWithErrorLog(&viewModel.errors)
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
                Text("\(String(format: "%.1f", rawSetting.coffeeBeansWeight))\(weightUnit)")
            }
            .font(
                !rawSetting.calculateCoffeeBeansWeightFromWater ? Font.headline.weight(.bold) : Font.headline.weight(.regular)
            )
            Spacer()
            Spacer()
            Spacer()
            Group {
                Text("config water amount")
                Text("\(String(format: "%.1f", rawSetting.waterAmount))\(weightUnit)")
            }
            .font(
                rawSetting.calculateCoffeeBeansWeightFromWater ? Font.headline.weight(.bold) : Font.headline.weight(.regular)
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
                target: $rawSetting.coffeeBeansWeight,
                isDisable: $appEnvironment.isTimerStarted
            )
        }
    }

    private var waterAmountSettingView: some View {
        VStack {
            coffeeBeansAndWaterWeightView
            NumberPickerView(
                digit: digit,
                max: coffeeBeansWeightMax * rawSetting.waterToCoffeeBeansWeightRatio,
                target: $rawSetting.waterAmount,
                isDisable: $appEnvironment.isTimerStarted
            )
        }
    }
}

extension SettingView {
    static let temporaryCurrentConfigKey = "temporaryCurrentConfig"
}

#if DEBUG
    struct SettingView_Previews: PreviewProvider {
        static var previews: some View {
            SettingView()
                .environment(\.locale, .init(identifier: "ja"))
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
        }
    }
#endif
