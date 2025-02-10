import Factory
import Foundation

public protocol SaveLoadTimerStartAtService {
    func saveStartAt(_ startAt: Date) -> ResultNea<Void, CoffeeError>

    func loadStartAt() -> ResultNea<Date?, CoffeeError>

    func deleteStartAt() -> Void
}

public final class SaveLoadTimerStartAtServiceImpl: SaveLoadTimerStartAtService {
    private let key = "startTime"
    private let userDefaultsService = Container.shared.userDefaultsService()

    public func saveStartAt(_ startAt: Date) -> ResultNea<Void, CoffeeError> {
        userDefaultsService.setEncodable(startAt.toEpochTimeMillis(), forKey: key)
    }

    public func loadStartAt() -> ResultNea<Date?, CoffeeError> {
        userDefaultsService.getDecodable(forKey: key).map { (epochTimeMillisOpt: UInt64?) in
            epochTimeMillisOpt.map { epochTimeMillis in
                epochTimeMillis.toDate()
            }
        }
    }

    public func deleteStartAt() -> Void {
        userDefaultsService.delete(forKey: key)
    }
}

extension Container {
    public var saveLoadTimerStartAtService: Factory<SaveLoadTimerStartAtService> {
        Factory(self) { SaveLoadTimerStartAtServiceImpl() }
    }
}
