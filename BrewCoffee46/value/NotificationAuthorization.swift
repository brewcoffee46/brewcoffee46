import Foundation

struct NotificationAuthorization: Equatable {
    var appVersion: String

    var requestedDate: Date

    var isAuthorized: Bool

    enum CodingKeys: String, CodingKey {
        case appVersion
        case requestedDate
        case isAuthorized
    }
}

extension NotificationAuthorization: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appVersion = try values.decode(String.self, forKey: .appVersion)
        requestedDate = Date(timeIntervalSince1970: try values.decode(Double.self, forKey: .requestedDate))
        isAuthorized = try values.decode(Bool.self, forKey: .isAuthorized)
    }
}

extension NotificationAuthorization: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(requestedDate.timeIntervalSince1970, forKey: .requestedDate)
        try container.encode(isAuthorized, forKey: .isAuthorized)
    }
}
