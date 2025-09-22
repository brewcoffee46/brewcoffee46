import BrewCoffee46Core
import Foundation
import SwiftJWT

struct ConfigClaims: Claims, Equatable {
    let iss: String
    let iat: Date
    let version: Int
    let config: Config
}

struct ConfigClaimsWithURL: Equatable {
    let url: URL
    let configClaims: ConfigClaims
}
