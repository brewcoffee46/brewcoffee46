import BrewCoffee46Core
import Factory
import Foundation

/// # Share configurations using universal links & JWT.
protocol ConfigurationLinkService: Sendable {
    /// Get `ConfigClaims` from URL.
    func get(url: URL) -> ResultNea<ConfigClaims, CoffeeError>

    /// Generate configuration link URL from `Config`.
    func generate(config: CoffeeConfig, currentConfigLastUpdatedAt: UInt64?) -> ResultNea<URL, CoffeeError>
}

extension ConfigurationLinkServiceImpl {
    static let universalLinksBaseURL = URL(string: "https://brewcoffee46.github.io/app/v1.html")!
    static let universalLinksQueryItemName: String = "config"
}

final class ConfigurationLinkServiceImpl: ConfigurationLinkService {
    private let jwtService = Container.shared.jwtService()

    func get(url: URL) -> ResultNea<ConfigClaims, CoffeeError> {
        if let jwt = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first(where: {
            $0.name == ConfigurationLinkServiceImpl.universalLinksQueryItemName
        })?.value {
            return jwtService.verify(jwt: jwt)
        } else {
            return .failure(NonEmptyArray(CoffeeError.configQueryParameterNotFound))
        }
    }

    func generate(config: CoffeeConfig, currentConfigLastUpdatedAt: UInt64?) -> ResultNea<URL, CoffeeError> {
        var updateConfig = config
        if let lastUpdatedAt = currentConfigLastUpdatedAt {
            updateConfig.editedAtMilliSec = lastUpdatedAt
        }

        return jwtService.sign(config: updateConfig).map { jwt in
            return ConfigurationLinkServiceImpl.universalLinksBaseURL.appending(queryItems: [
                URLQueryItem(name: ConfigurationLinkServiceImpl.universalLinksQueryItemName, value: jwt)
            ])
        }
    }
}

extension Container {
    var configurationLinkService: Factory<ConfigurationLinkService> {
        Factory(self) { ConfigurationLinkServiceImpl() }
    }
}
