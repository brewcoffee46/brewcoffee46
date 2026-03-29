import BrewCoffee46Core
import Factory
import SwiftJWT

/// # Sign/Verify `Config` which is encoded/decoded JWT.
protocol JWTService: Sendable {
    func verify(jwt: String) -> ResultNea<ConfigClaims, CoffeeError>

    func sign(config: CoffeeConfig) -> ResultNea<String, CoffeeError>
}

final class JWTServiceImpl: JWTService {
    private let dateService = Container.shared.dateService()

    func verify(jwt: String) -> ResultNea<ConfigClaims, CoffeeError> {
        do {
            let configClaims = try JWT<ConfigClaims>(jwtString: jwt, verifier: JWTVerifier.none)
            return .success(configClaims.claims)
        } catch {
            return .failure(NonEmptyArray(CoffeeError.configClamesJwtError(error)))
        }
    }

    func sign(config: CoffeeConfig) -> ResultNea<String, CoffeeError> {
        var jwt = JWT(
            claims: ConfigClaims(
                iss: "BrewCoffee46",
                iat: dateService.now(),
                version: 1,
                config: config
            )
        )

        do {
            let jwtString = try jwt.sign(using: JWTSigner.none)
            return .success(jwtString)
        } catch {
            return .failure(NonEmptyArray(CoffeeError.configClamesJwtError(error)))
        }
    }
}

extension Container {
    var jwtService: Factory<JWTService> {
        Factory(self) { JWTServiceImpl() }.cached
    }
}
