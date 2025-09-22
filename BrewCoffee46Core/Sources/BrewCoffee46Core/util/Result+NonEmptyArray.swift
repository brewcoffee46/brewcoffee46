/// # A `Result` uses `NonEmptyArray<Failure>` as errors.
public typealias ResultNea<Success, Failure: Error> =
    Result<Success, NonEmptyArray<Failure>>

infix operator |+| : AssociativityRight

public func |+| <A, B, E: Error>(
    r1: ResultNea<A, E>,
    r2: ResultNea<B, E>
) -> ResultNea<(A, B), E> {
    switch (r1, r2) {
    case (.success(let a), .success(let b)):
        return .success((a, b))
    case (.success(_), .failure(let eb)):
        return .failure(eb)
    case (.failure(let ea), .success(_)):
        return .failure(ea)
    case (.failure(let ea), .failure(let eb)):
        return .failure(ea ++ eb)
    }
}

// It is required to use `NonEmptyArray` for `Failure` type parameter of `Result`
extension NonEmptyArray: Error where A: Error {}

extension ResultNea: Sendable where Success: Sendable, Failure: Sendable {}

extension ResultNea {
    public func forEach(_ f: (Success) -> Void) -> Void {
        switch self {
        case .success(let result):
            f(result)
        case .failure(_):
            return
        }
    }

    public func forEachError(_ f: (Failure) -> Void) -> Void {
        switch self {
        case .success(_):
            return
        case .failure(let error):
            f(error)
        }
    }

    public func recoverWithErrorLog(_ errorLog: inout String) where Failure == NonEmptyArray<CoffeeError> {
        switch self {
        case .success(_):
            ()

        case .failure(let errors):
            errorLog += errors.getAllErrorMessage()
        }
    }
}

extension Result {
    public func isSuccess() -> Bool {
        return switch self {
        case .success(_): true
        case .failure(_): false
        }
    }

    public func isFailure() -> Bool {
        return !isSuccess()
    }

    public func getOrElse(elseValue: Success) -> Success {
        if case .success(let success) = self {
            success
        } else {
            elseValue
        }
    }

    public func flatMap<NewSuccess>(_ transform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            await transform(success)

        case .failure(let error):
            .failure(error)
        }
    }
}
