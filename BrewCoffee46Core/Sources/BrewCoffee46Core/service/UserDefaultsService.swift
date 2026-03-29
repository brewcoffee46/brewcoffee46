import Factory
import Foundation

public protocol UserDefaultsService: Sendable {
    func setEncodable<A: Encodable>(_ value: A, forKey defaultName: String) -> ResultNea<Void, CoffeeError>

    func getDecodable<A: Decodable>(forKey: String) -> ResultNea<A?, CoffeeError>

    func delete(forKey: String) -> Void
}

public final class UserDefaultsServiceImpl: UserDefaultsService {
    public func setEncodable<A: Encodable>(_ value: A, forKey: String) -> ResultNea<Void, CoffeeError> {
        let encoder = JSONEncoder()
        do {
            let json = try String(data: encoder.encode(value), encoding: .utf8)!
            UserDefaults.standard.set(json, forKey: forKey)
            return .success(())
        } catch {
            return .failure(NonEmptyArray(CoffeeError.jsonError(error)))
        }
    }

    public func getDecodable<A: Decodable>(forKey: String) -> ResultNea<A?, CoffeeError> {
        let decoder = JSONDecoder()

        if let json = UserDefaults.standard.string(forKey: forKey)?.data(using: .utf8) {
            do {
                return .success(try decoder.decode(A.self, from: json))
            } catch {
                return .failure(NonEmptyArray(CoffeeError.jsonError(error)))
            }
        } else {
            return .success(.none)
        }
    }

    public func delete(forKey: String) -> Void {
        UserDefaults.standard.removeObject(forKey: forKey)
    }
}

extension Container {
    public var userDefaultsService: Factory<UserDefaultsService> {
        Factory(self) { UserDefaultsServiceImpl() }.cached
    }
}
