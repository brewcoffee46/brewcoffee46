import BrewCoffee46Core

public final class MockUserDefaultsService<T>: UserDefaultsService, @unchecked Sendable {
    public var inputValues: [T] = []
    public var dummyResult: ResultNea<Any?, CoffeeError>

    public init(_ dummyResult: ResultNea<Any?, CoffeeError>) {
        self.dummyResult = dummyResult
        //self.inputValues = inputValues
    }

    public func setEncodable<A: Encodable>(_ value: A, forKey defaultName: String) -> ResultNea<Void, CoffeeError> {
        inputValues.append(value as! T)
        return .success(())
    }

    public func getDecodable<A: Decodable>(forKey: String) -> ResultNea<A?, CoffeeError> {
        return dummyResult.map({ a in a as? A })
    }

    public func delete(forKey: String) {
        return ()
    }

}
