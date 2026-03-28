import BrewCoffee46Core
import BrewCoffee46TestsShared
import Factory
import XCTest

@testable import BrewCoffee46

final class MockJWTService: JWTService, @unchecked Sendable {
    let dummyConfigClaims: ResultNea<ConfigClaims, CoffeeError>
    let dummyStringFunc: (CoffeeConfig) -> ResultNea<String, CoffeeError>

    init(
        dummyConfigClaims: ResultNea<ConfigClaims, CoffeeError>,
        dummyStringFunc: @escaping (CoffeeConfig) -> ResultNea<String, CoffeeError>
    ) {
        self.dummyConfigClaims = dummyConfigClaims
        self.dummyStringFunc = dummyStringFunc
    }

    func verify(jwt: String) -> ResultNea<ConfigClaims, CoffeeError> {
        return dummyConfigClaims
    }

    func sign(config: CoffeeConfig) -> ResultNea<String, CoffeeError> {
        return dummyStringFunc(config)
    }
}

final class ConfigurationLinkServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    let configClaims = ConfigClaims.init(
        iss: "iss",
        iat: getDate(),
        version: 1,
        config: CoffeeConfig.defaultValue()
    )

    func testGetFromURLSuccessfully() throws {
        let mockJWTService = MockJWTService(
            dummyConfigClaims: .success(configClaims),
            dummyStringFunc: { _ in .success("dummy") }
        )
        Container.shared.jwtService.register {
            mockJWTService
        }
        let sut = ConfigurationLinkServiceImpl()

        let actual = sut.get(url: URL(string: "https://example.com/index?\(ConfigurationLinkServiceImpl.universalLinksQueryItemName)=data")!)
        XCTAssertEqual(actual, .success(configClaims))
    }

    func testGetReturnErrorIfQueryParameterIsNotFound() throws {
        let mockJWTService = MockJWTService(
            dummyConfigClaims: .success(configClaims),
            dummyStringFunc: { _ in .success("dummy") }
        )
        Container.shared.jwtService.register {
            mockJWTService
        }
        let sut = ConfigurationLinkServiceImpl()

        let actual = sut.get(url: URL(string: "https://example.com/index")!)
        XCTAssertTrue(actual.isFailure())
        actual.forEachError { error in
            XCTAssertEqual(error.head, .configQueryParameterNotFound)
        }
    }

    func testGenerateURLSuccessfully() throws {
        let dummyString = "dummy"
        let config = CoffeeConfig.defaultValue()
        let expectedEditedAtMilliSec = config.editedAtMilliSec
        let mockJWTService = MockJWTService(
            dummyConfigClaims: .success(configClaims),
            dummyStringFunc: { config in
                XCTAssertEqual(config.editedAtMilliSec, expectedEditedAtMilliSec)

                return .success(dummyString)
            }
        )
        Container.shared.jwtService.register {
            mockJWTService
        }
        let sut = ConfigurationLinkServiceImpl()

        let actual = sut.generate(config: config, currentConfigLastUpdatedAt: .none)
        XCTAssertEqual(
            actual,
            .success(
                ConfigurationLinkServiceImpl.universalLinksBaseURL.appending(
                    queryItems: [URLQueryItem(name: ConfigurationLinkServiceImpl.universalLinksQueryItemName, value: dummyString)]
                )
            ))
    }

    func testGenerateURLWithUpdateLastUpdatedAtSuccessfully() throws {
        let dummyString = "dummy"
        let currentConfigLastUpdatedAt: UInt64 = 1000
        let mockJWTService = MockJWTService(
            dummyConfigClaims: .success(configClaims),
            dummyStringFunc: { config in
                XCTAssertEqual(config.editedAtMilliSec, .some(currentConfigLastUpdatedAt))

                return .success(dummyString)
            }
        )
        Container.shared.jwtService.register {
            mockJWTService
        }
        let sut = ConfigurationLinkServiceImpl()

        let actual = sut.generate(config: CoffeeConfig.defaultValue(), currentConfigLastUpdatedAt: currentConfigLastUpdatedAt)
        XCTAssertEqual(
            actual,
            .success(
                ConfigurationLinkServiceImpl.universalLinksBaseURL.appending(
                    queryItems: [URLQueryItem(name: ConfigurationLinkServiceImpl.universalLinksQueryItemName, value: dummyString)]
                )
            ))
    }
}
