import BrewCoffee46Core
import Factory
@preconcurrency import WatchConnectivity

@MainActor
final class ConfigViewModel: NSObject, ObservableObject {
    @Injected(\.validateInputService) private var validateInputService: ValidateInputService
    @Injected(\.calculateDripInfoService) private var calculateDripInfoService: CalculateDripInfoService
    @Injected(\.saveLoadConfigService) private var saveLoadConfigService: SaveLoadConfigService

    @Published var currentConfig: Config = Config.defaultValue() {
        didSet {
            if currentConfig != oldValue {
                switch validateInputService.validate(config: currentConfig) {
                case .success():
                    self.dripInfo = calculateDripInfoService.calculate(currentConfig)
                    saveLoadConfigService
                        .saveCurrentConfig(config: currentConfig)
                        .recoverWithErrorLog(&log)
                case .failure(let errors):
                    log = errors.getAllErrorMessage()
                    currentConfig = oldValue
                }
            }
        }
    }
    @Published var allConfigs: [Config] = [] {
        didSet {
            saveLoadConfigService
                .saveAll(configs: allConfigs)
                .recoverWithErrorLog(&log)
        }
    }
    @Published var dripInfo: DripInfo = DripInfo.defaultValue()
    @Published var log: String = ""

    private let session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()

        saveLoadConfigService
            .loadCurrentConfig()
            .map { $0.map { currentConfig = $0 } }
            .recoverWithErrorLog(&log)
    }
}

extension ConfigViewModel: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {

    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping (([String: Any]) -> Void)) {
        if let value = message[watchKitAppConfigsKey] as? String {
            switch fromJSON(value) {
            case .success(let configs):
                DispatchQueue.main.async { [self] in
                    allConfigs = configs
                }
                replyHandler([:])
            case .failure(let errors):
                DispatchQueue.main.async { [self] in
                    log = errors.toArray().map { $0.getMessage() }.joined(separator: "\n")
                }
            }
        }
    }
}

private func fromJSON(_ json: String) -> ResultNea<[Config], CoffeeError> {
    let decoder = JSONDecoder()
    let jsonData = json.data(using: .utf8)!
    do {
        let configs = try decoder.decode([Config].self, from: jsonData)
        if configs.contains(where: { $0.version != Config.currentVersion }) {
            return Result.failure(NonEmptyArray(CoffeeError.loadedConfigIsNotCompatible))
        } else {
            return Result.success(configs)
        }
    } catch {
        return Result.failure(NonEmptyArray(CoffeeError.jsonError(error)))
    }
}
