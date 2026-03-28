import Factory
import Foundation

public struct CoffeeConfig: Equatable, Hashable, Sendable {
    public var partitionsCountOf6: Int

    public var waterToCoffeeBeansWeightRatio: Double

    public var firstWaterPercent: Double

    public var totalTimeMilliSec: MilliSecond

    public var steamingTimeMilliSec: MilliSecond

    public var mills: [Mill]

    public var note: String

    public var beforeChecklist: [String]

    /// Unix epoch time as milli seconds.
    public var editedAtMilliSec: MilliSecond?

    // If the JSON compatibility of `Config` falls then `version` will increment.
    public let version: Int

    enum CodingKeys: String, CodingKey {
        case partitionsCountOf6
        case waterToCoffeeBeansWeightRatio
        case firstWaterPercent
        case totalTimeSec  // legacy config key
        case totalTimeMilliSec
        case steamingTimeSec  // legacy config key
        case steamingTimeMilliSec
        case version
        case mills
        case note
        case beforeChecklist
        case editedAtMilliSec
    }

    public init(
        partitionsCountOf6: Int,
        waterToCoffeeBeansWeightRatio: Double,
        firstWaterPercent: Double,
        totalTimeMilliSec: UInt64,
        steamingTimeMilliSec: UInt64,
        note: String,
        beforeChecklist: [String],
        editedAtMilliSec: UInt64?,
        mills: [Mill] = [],
        version: Int = CoffeeConfig.currentVersion
    ) {
        self.partitionsCountOf6 = partitionsCountOf6
        self.waterToCoffeeBeansWeightRatio = waterToCoffeeBeansWeightRatio
        self.firstWaterPercent = firstWaterPercent
        self.totalTimeMilliSec = totalTimeMilliSec
        self.steamingTimeMilliSec = steamingTimeMilliSec
        self.mills = mills
        self.note = note
        self.beforeChecklist = beforeChecklist
        self.editedAtMilliSec = editedAtMilliSec
        self.version = version
    }
}

extension CoffeeConfig {
    public static let currentVersion: Int = 2

    public static let validVersions: Set<Int> = [currentVersion, 1]

    public static let initWaterToCoffeeBeansWeightRatio: Double = 15.0

    public static let maxCheckListSize = 100

    public static let initBeforeCheckList: [String] = (1...9).map { i in
        NSLocalizedString("before check list \(i)", comment: "")
    }

    public static func defaultValue() -> CoffeeConfig {
        CoffeeConfig(
            partitionsCountOf6: 3,
            waterToCoffeeBeansWeightRatio: CoffeeConfig.initWaterToCoffeeBeansWeightRatio,
            firstWaterPercent: 0.5,
            totalTimeMilliSec: 210_000,
            steamingTimeMilliSec: 45_000,
            note: "",
            beforeChecklist: CoffeeConfig.initBeforeCheckList,
            editedAtMilliSec: .none,
            version: CoffeeConfig.currentVersion
        )
    }

    public var totalTimeSec: Double {
        Double(totalTimeMilliSec) / 1000.0
    }

    public var steamingTimeSec: Double {
        Double(steamingTimeMilliSec) / 1000.0
    }

    public func toJSON(isPrettyPrint: Bool) -> ResultNea<String, CoffeeError> {
        let encoder = JSONEncoder()
        if isPrettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        do {
            return Result.success(try String(data: encoder.encode(self), encoding: .utf8)!)
        } catch {
            return Result.failure(NonEmptyArray(CoffeeError.jsonError(error)))
        }
    }

    public static func fromJSON(_ json: String) -> ResultNea<CoffeeConfig, CoffeeError> {
        let decoder = JSONDecoder()
        let jsonData = json.data(using: .utf8)!
        do {
            let config = try decoder.decode(CoffeeConfig.self, from: jsonData)
            if config.version == currentVersion {
                return Result.success(config)
            } else {
                return Result.failure(NonEmptyArray(CoffeeError.loadedConfigIsNotCompatible))
            }
        } catch {
            return Result.failure(NonEmptyArray(CoffeeError.jsonError(error)))
        }
    }
}

extension CoffeeConfig: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let version = try values.decode(Int.self, forKey: .version)
        partitionsCountOf6 = try values.decode(Int.self, forKey: .partitionsCountOf6)
        waterToCoffeeBeansWeightRatio = try values.decode(Double.self, forKey: .waterToCoffeeBeansWeightRatio)
        firstWaterPercent = try values.decode(Double.self, forKey: .firstWaterPercent)

        if version == 1 {
            let totalTimeSec = try values.decode(Double.self, forKey: .totalTimeSec)
            let steamingTimeSec = try values.decode(Double.self, forKey: .steamingTimeSec)
            totalTimeMilliSec = MilliSecond.fromSecond(totalTimeSec)
            steamingTimeMilliSec = MilliSecond.fromSecond(steamingTimeSec)
        } else {
            totalTimeMilliSec = try values.decode(UInt64.self, forKey: .totalTimeMilliSec)
            steamingTimeMilliSec = try values.decode(UInt64.self, forKey: .steamingTimeMilliSec)
        }

        mills = try values.decodeIfPresent([Mill].self, forKey: .mills) ?? []
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        let rawBeforeChecklist = try values.decodeIfPresent([String].self, forKey: .beforeChecklist) ?? CoffeeConfig.initBeforeCheckList
        beforeChecklist = Array(rawBeforeChecklist.prefix(CoffeeConfig.maxCheckListSize))
        editedAtMilliSec = try values.decodeIfPresent(UInt64.self, forKey: .editedAtMilliSec)

        self.version = CoffeeConfig.currentVersion
    }
}

extension CoffeeConfig: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(partitionsCountOf6), forKey: .partitionsCountOf6)
        try container.encode(waterToCoffeeBeansWeightRatio, forKey: .waterToCoffeeBeansWeightRatio)
        try container.encode(firstWaterPercent, forKey: .firstWaterPercent)
        try container.encode(totalTimeMilliSec, forKey: .totalTimeMilliSec)
        try container.encode(steamingTimeMilliSec, forKey: .steamingTimeMilliSec)
        try container.encode(mills, forKey: .mills)
        try container.encode(note, forKey: .note)
        try container.encode(beforeChecklist, forKey: .beforeChecklist)
        try container.encodeIfPresent(editedAtMilliSec, forKey: .editedAtMilliSec)
        try container.encode(version, forKey: .version)
    }
}
