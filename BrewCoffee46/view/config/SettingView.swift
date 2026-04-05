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
    @Injected(\.saveLoadConfigService) private var saveLoadConfigService

    @Environment(\.scenePhase) private var scenePhase

    @State private var rawSetting: RawSetting = RawSetting.defaultValue()
    @State private var hasRawSettingInitialized: Bool = false

    @State private var showTips: Bool = false
    @State private var didSuccessSendingConfig: Bool? = .none
    @State private var showTipsWhenSendingConfigFailure: Bool = false

    // This will be calculated initially using the current configuration so it's not necessary ` ConfigurationLinkServiceImpl.universalLinksBaseURL`
    // but if the type of `universalLinksConfigUrl` would be `URL?` it's not convenience so
    // for now we assign `ConfigurationLinkServiceImpl.universalLinksBaseURL`.
    @State private var universalLinksConfigUrl: URL = ConfigurationLinkServiceImpl.universalLinksBaseURL

    @State private var showMillEditSheet: Bool = false

    private let timerStep: Double = 1.0

    var body: some View {
        Form {
            Toggle("config show tips", isOn: $showTips)
            TipView(TipsTip(), arrowEdge: .top)

            Section(header: Text("config save load setting")) {
                TipsView(
                    showTips,
                    content: HStack {
                        Text(viewModel.currentConfig.coffeeConfig.note ??? NSLocalizedString("config note empty string", comment: ""))
                        Spacer()
                        Text(
                            (viewModel.currentConfigLastUpdatedAt ?? viewModel.currentConfig.coffeeConfig.editedAtMilliSec)?.toDate()
                                .formattedWithSec()
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
                            config: viewModel.currentConfig.coffeeConfig,
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

                        switch saveLoadConfigService.loadAll() {
                        case .success(let configsOpt):
                            if let configs = configsOpt {
                                Task {
                                    let result = await watchConnectionService.sendConfigs(configs)
                                    switch result {
                                    case .success():
                                        didSuccessSendingConfig = true
                                    case .failure(let error):
                                        viewModel.errors = error.getAllErrorMessage()
                                        didSuccessSendingConfig = false
                                        showTipsWhenSendingConfigFailure = true
                                    }
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
                            Text("\(rawSetting.waterToCoffeeBeansWeightRatio, specifier: "%.1f%")")

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
                            Text("\(rawSetting.firstWaterPercent * 100, specifier: "%.0f%")%")

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
                                "\(rawSetting.totalTimeSec, specifier: "%.0f")\(NSLocalizedString("config sec unit", comment: ""))")
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
                        Text("\(rawSetting.steamingTimeSec, specifier: "%.0f")\(NSLocalizedString("config sec unit", comment: ""))")
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

            Section(
                header: HStack {
                    Text("config mill settings")
                    Spacer()
                    Button(action: {
                        showMillEditSheet.toggle()
                    }) {
                        Text("config mill setting edit")
                    }
                    .buttonStyle(.bordered)
                    .disabled(appEnvironment.isTimerStarted)
                }
            ) {
                TipView(MillTip(), arrowEdge: .none)
                VStack {
                    MillListView(items: viewModel.currentConfig.coffeeConfig.mills)
                        .sheet(isPresented: $showMillEditSheet) {
                            MillSettingView(
                                mills: $rawSetting.mills,
                                showMillEditSheet: $showMillEditSheet
                            )
                        }
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
        .onChange(of: viewModel.currentConfig, initial: true) { oldValue, newValue in
            // Avoid infinite loop between `onChange(of: viewModel.currentConfig)` and .onChange(of: rawSetting),
            // update only if `updatedRawSetting` is not the same `rawSetting`.
            if hasRawSettingInitialized && oldValue == newValue {
                return
            }
            hasRawSettingInitialized = true

            rawSetting = rawSettingConvertService.fromConfig(
                viewModel.currentConfig, rawSetting,
            )
        }
        .onChange(of: rawSetting) { oldValue, newValue in
            // This check is also to avoid the infinite loop.
            if oldValue == newValue {
                return
            }

            // `rawSetting` is update in `onChange(of: rawSetting)` so it seems to enter infinite loop
            // but `Equatable` of `RawSetting` does not care `editedAtMilliSec` field so
            // infinite loop will be avoided by `if oldValue == newValue { return }` above.
            rawSetting.editedAtMilliSec = dateService.nowEpochTimeMillis()

            rawSettingConvertService.toConfig(newValue, viewModel.currentConfig).map { config in
                viewModel.currentConfig = config

                // We have to feedback beans weight from water amount or its inverse.
                // Due to this feedback, this `onChange` will be called at most twice unfortunately
                // but for now we don't know the better way.
                if rawSetting.calculateCoffeeBeansWeightFromWater {
                    rawSetting.coffeeBeansWeight = viewModel.currentConfig.globalConfig.coffeeBeansWeightG
                } else {
                    rawSetting.waterAmount = viewModel.currentConfig.totalWaterAmountG()
                }
            }
            .recoverWithErrorLog(&viewModel.errors)
        }
        .navigation(
            path: $appEnvironment.configPath,
            title: "navigation title configuration"
        )
        .currentConfigSaveLoadModifier(
            $viewModel.currentConfig,
            // To synchronise `viewModel.currentConfigLastUpdatedAt` & `rawSetting.editedAtMilliSec`
            // this custom `Binding` is required. Note that `viewModel.currentConfig.coffeeConfig.editedAtMilliSec`
            // will be set on `onChange(of: rawSetting)`.
            Binding<MilliSecond?>(
                get: { viewModel.currentConfigLastUpdatedAt },
                set: { newValue in
                    viewModel.currentConfigLastUpdatedAt = newValue
                    rawSetting.editedAtMilliSec = newValue
                }
            ),
            $viewModel.errors
        )
    }

    private var coffeeBeansAndWaterWeightView: some View {
        HStack {
            Spacer()
            Group {
                Text("config coffee beans weight")
                Text("\(rawSetting.coffeeBeansWeight, specifier: "%.1f")\(weightUnit)")
            }
            .font(
                !rawSetting.calculateCoffeeBeansWeightFromWater ? Font.headline.weight(.bold) : Font.headline.weight(.regular)
            )
            Spacer()
            Spacer()
            Spacer()
            Group {
                Text("config water amount")
                Text("\(rawSetting.waterAmount, specifier: "%.1f")\(weightUnit)")
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
                digit: numberPickerDigit,
                max: coffeeBeansWeightMaxGram,
                min: coffeeBeansWeightMinGram,
                target: $rawSetting.coffeeBeansWeight,
                isDisable: $appEnvironment.isTimerStarted
            )
        }
    }

    private var waterAmountSettingView: some View {
        VStack {
            coffeeBeansAndWaterWeightView
            NumberPickerView(
                digit: numberPickerDigit,
                max: coffeeBeansWeightMaxGram * rawSetting.waterToCoffeeBeansWeightRatio,
                min: coffeeBeansWeightMinGram,
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
