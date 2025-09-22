import Factory
import Foundation

/// # Save & load user's configuration.
public protocol SaveLoadConfigService: Sendable {
    func saveCurrentConfig(config: Config) -> ResultNea<Void, CoffeeError>

    func loadCurrentConfig() -> ResultNea<Config?, CoffeeError>

    func saveAll(configs: [Config]) -> ResultNea<Void, CoffeeError>

    func loadAll() -> ResultNea<[Config]?, CoffeeError>

    // Save `config` to the last of current all saved configurations.
    func saveConfig(config: Config) -> ResultNea<Void, CoffeeError>

    func delete(key: String) -> Void
}

public final class SaveLoadConfigServiceImpl: SaveLoadConfigService {
    private let userDefaultsService = Container.shared.userDefaultsService()

    public func saveCurrentConfig(config: Config) -> ResultNea<Void, CoffeeError> {
        return userDefaultsService.setEncodable(config, forKey: userDefaultsKey(SaveLoadConfigServiceImpl.temporaryCurrentConfigKey))
    }

    public func loadCurrentConfig() -> ResultNea<Config?, CoffeeError> {
        return userDefaultsService.getDecodable(forKey: userDefaultsKey(SaveLoadConfigServiceImpl.temporaryCurrentConfigKey))
    }

    public func saveAll(configs: [Config]) -> ResultNea<Void, CoffeeError> {
        return userDefaultsService.setEncodable(configs, forKey: userDefaultsKey(SaveLoadConfigServiceImpl.configsKey))
    }

    public func loadAll() -> ResultNea<[Config]?, CoffeeError> {
        return
            userDefaultsService
            .getDecodable(forKey: userDefaultsKey(SaveLoadConfigServiceImpl.configsKey))
            .map { (configsOpt: [Config]?) in
                if var configs = configsOpt {
                    // Order by desc.
                    configs.sort {
                        ($0.editedAtMilliSec ?? 0) > ($1.editedAtMilliSec ?? 0)
                    }
                    return configs
                } else {
                    return .none
                }
            }
    }

    public func saveConfig(config: Config) -> ResultNea<Void, CoffeeError> {
        return loadAll().flatMap { configsOpt in
            if var configs = configsOpt {
                configs.append(config)

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

    static internal let temporaryCurrentConfigKey = "temporaryCurrentConfig"

    static internal let configsKey = "configs"
}

extension Container {
    public var saveLoadConfigService: Factory<SaveLoadConfigService> {
        Factory(self) { SaveLoadConfigServiceImpl() }
    }
}
