import Factory
import Foundation

/// # Save & load user's configuration.
public protocol SaveLoadConfigService: Sendable {
    func saveCurrentConfig(_ config: AppConfig) -> ResultNea<Void, CoffeeError>

    func loadCurrentConfig() -> ResultNea<AppConfig?, CoffeeError>

    func saveAll(configs: [CoffeeConfig]) -> ResultNea<Void, CoffeeError>

    func loadAll() -> ResultNea<[CoffeeConfig]?, CoffeeError>

    // Save `config` to the last of current all saved configurations.
    func saveConfig(config: CoffeeConfig) -> ResultNea<Void, CoffeeError>

    func delete(key: String) -> Void
}

public final class SaveLoadConfigServiceImpl: SaveLoadConfigService {
    private let userDefaultsService = Container.shared.userDefaultsService()

    public func saveCurrentConfig(_ config: AppConfig) -> ResultNea<Void, CoffeeError> {
        return userDefaultsService.setEncodable(config, forKey: userDefaultsKey(SaveLoadConfigServiceImpl.currentAppConfigKey))
    }

    public func loadCurrentConfig() -> ResultNea<AppConfig?, CoffeeError> {
        userDefaultsService.getDecodable(
            forKey: userDefaultsKey(SaveLoadConfigServiceImpl.currentAppConfigKey)
        ).flatMap { (appConfigOpt: AppConfig?) in
            if let appConfig = appConfigOpt {
                .success(appConfig)
            } else {
                // If `appConfig` is not found then try to load only legacy `CoffeeConfig`.
                userDefaultsService.getDecodable(
                    forKey: userDefaultsKey(SaveLoadConfigServiceImpl.lagacyCurrentConfigKey)
                ).map { (configOpt: CoffeeConfig?) in
                    if let config = configOpt {
                        .some(AppConfig(config, GlobalConfig.defaultValue()))
                    } else {
                        .none
                    }
                }
            }
        }
    }

    public func saveAll(configs: [CoffeeConfig]) -> ResultNea<Void, CoffeeError> {
        return userDefaultsService.setEncodable(configs, forKey: userDefaultsKey(SaveLoadConfigServiceImpl.configsKey))
    }

    public func loadAll() -> ResultNea<[CoffeeConfig]?, CoffeeError> {
        return userDefaultsService.getDecodable(forKey: userDefaultsKey(SaveLoadConfigServiceImpl.configsKey))
    }

    public func saveConfig(config: CoffeeConfig) -> ResultNea<Void, CoffeeError> {
        return loadAll().flatMap { configsOpt in
            if var configs = configsOpt {
                configs.insert(config, at: 0)

                return saveAll(configs: configs)
            } else {
                return saveAll(configs: [config])
            }
        }
    }

    public func delete(key: String) -> Void {
        userDefaultsService.delete(forKey: userDefaultsKey(key))
    }

    private func userDefaultsKey(_ key: String) -> String {
        "\(SaveLoadConfigServiceImpl.keyPrefix)_\(key)"
    }
}

extension SaveLoadConfigServiceImpl {
    static internal let keyPrefix = "saved_config"

    static internal let lagacyCurrentConfigKey = "temporaryCurrentConfig"

    static internal let currentAppConfigKey = "currentAppConfig"

    static internal let configsKey = "configs"
}

extension Container {
    public var saveLoadConfigService: Factory<SaveLoadConfigService> {
        Factory(self) { SaveLoadConfigServiceImpl() }.cached
    }
}
