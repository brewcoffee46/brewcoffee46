import BrewCoffee46Core
import BrewCoffee46TestsShared
import Factory
import SwiftJWT
import XCTest

@testable import BrewCoffee46

final class JWTServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.reset()
    }

    let config = CoffeeConfig(
        partitionsCountOf6: 3,
        waterToCoffeeBeansWeightRatio: 15.0,
        firstWaterPercent: 0.5,
        totalTimeMilliSec: 210_000,
        steamingTimeMilliSec: 45_000,
        note: "note",
        beforeChecklist: [],
        editedAtMilliSec: .none,
        version: 2
    )
    func testGenerateJWTFromConfigSuccessfully() {
        Container.shared.dateService.register {
            MockDateService()
        }

        let sut = JWTServiceImpl()
        let actual = sut.sign(config: config)
        XCTAssertTrue(actual.isSuccess())
        actual.forEach { jwtToken in
            do {
                let configClaims = try JWT<ConfigClaims>(jwtString: jwtToken, verifier: JWTVerifier.none)

                XCTAssertEqual(configClaims.claims.iat, BrewCoffee46TestsShared.epochTimeMillis.toDate())
                XCTAssertEqual(configClaims.claims.config, config)
            } catch {
                XCTFail("Not able to decode JWT: \(error)")
            }
        }
    }

    func testDecodeConfigFromJWTSuccessfully() {
        Container.shared.dateService.register {
            MockDateService()
        }
        let jwtToken =
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJpYXQiOjE3MjM3OTI1MzkuODQzLCJ2ZXJzaW9uIjoxLCJpc3MiOiJCcmV3Q29mZmVlNDYiLCJjb25maWciOnsidmVyc2lvbiI6MSwidG90YWxUaW1lU2VjIjoyMTAsInBhcnRpdGlvbnNDb3VudE9mNiI6Mywibm90ZSI6Im5vdGUiLCJiZWZvcmVDaGVja2xpc3QiOltdLCJjb2ZmZWVCZWFuc1dlaWdodCI6MzAsImZpcnN0V2F0ZXJQZXJjZW50IjowLjUsInN0ZWFtaW5nVGltZVNlYyI6NDUsIndhdGVyVG9Db2ZmZWVCZWFuc1dlaWdodFJhdGlvIjoxNX19"

        let sut = JWTServiceImpl()
        let actual = sut.verify(jwt: jwtToken)
        XCTAssertTrue(actual.isSuccess())
        actual.forEach { configClames in
            XCTAssertEqual(configClames.config, config)
        }
    }
}
