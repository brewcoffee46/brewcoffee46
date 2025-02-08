import Foundation

struct RequestReviewItem: Equatable {
    var appVersion: String

    var requestedDate: Date

    enum CodingKeys: String, CodingKey {
        case appVersion
        case requestedDate
    }
}

extension RequestReviewItem: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appVersion = try values.decode(String.self, forKey: .appVersion)
        requestedDate = Date(timeIntervalSince1970: try values.decode(Double.self, forKey: .requestedDate))
    }
}

extension RequestReviewItem: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(requestedDate.timeIntervalSince1970, forKey: .requestedDate)
    }
}

struct RequestReviewInfo: Equatable {
    var requestHistory: [RequestReviewItem]

    enum CodingKeys: String, CodingKey {
        case requestHistory
    }
}

extension RequestReviewInfo: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        requestHistory = try values.decode([RequestReviewItem].self, forKey: .requestHistory)
    }
}

extension RequestReviewInfo: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestHistory, forKey: .requestHistory)
    }
}

struct RequestReviewGuard {
    var tryCount: Int

    enum CodingKeys: String, CodingKey {
        case tryCount
    }
}

extension RequestReviewGuard: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tryCount = try values.decode(Int.self, forKey: .tryCount)
    }
}

extension RequestReviewGuard: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tryCount, forKey: .tryCount)
    }
}
