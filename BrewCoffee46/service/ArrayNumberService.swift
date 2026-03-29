import BrewCoffee46Core
import Factory
import Foundation

/// # ArrayNumber to/from `Double`
///
/// This service the `Double` number for example `12.3` to/from `[1, 2, 3]` (we called this _ArrayNumber_)`.
protocol ArrayNumberService: Sendable {
    /**
     Minimum value that this service handles is `0.1`. The smaller value more than 0.05 would be rounding,
     for example since the input is `12.39` with `digit = 3` then the return value is `[1, 2, 4]`.
     */
    func fromDouble(digit: Int, from: Double) -> ResultNea<NonEmptyArray<Int>, CoffeeError>

    func toDouble(_ arrayNumber: NonEmptyArray<Int>) -> Double

    func toDoubleWithError(_ arrayNumber: [Int]) -> ResultNea<Double, CoffeeError>
}

final class ArrayNumberServiceImpl: ArrayNumberService {
    func fromDouble(digit: Int, from: Double) -> ResultNea<NonEmptyArray<Int>, CoffeeError> {
        let value = roundCentesimal(from)

        if value > pow(10.0, Double(digit - 1)) {
            return .failure(NonEmptyArray(.arrayNumberConversionError("`from` must be less than 10 ** (`digit` - 1).")))
        } else if digit <= 0 {
            return .failure(NonEmptyArray(.arrayNumberConversionError("`digit` must be greater than 0.")))
        } else {
            let head: Int = Int(floor(value / pow(10.0, Double(digit - 2))))
            var tail: [Int] = []
            var previous: Int = head * 10

            if digit > 1 {
                for index in 1..<(digit - 1) {
                    tail += [Int(floor(value / pow(10.0, Double(digit - index - 2)))) - previous]
                    previous = (previous * 10) + tail[index - 1] * 10
                }
                // We want to use `round` rather than `floor` for the last value, so the last case is special.
                tail += [Int(round(value * 10.0 /*= value / pow(10.0, -1) */)) - previous]
            }

            return .success(NonEmptyArray(head, tail))
        }
    }

    func toDouble(_ arrayNumber: NonEmptyArray<Int>) -> Double {
        var result: Double = 0.0

        for (i, item) in arrayNumber.toArray().enumerated() {
            result += Double(item) * pow(10.0, Double(arrayNumber.count() - (i + 2)))
        }

        return result
    }

    func toDoubleWithError(_ arrayNumber: [Int]) -> ResultNea<Double, CoffeeError> {
        if let head = arrayNumber.first {
            .success(toDouble(NonEmptyArray(head, Array(arrayNumber[1...]))))
        } else {
            .failure(NonEmptyArray(.arrayNumberConversionError("`arrayNumber` must not be empty.")))
        }
    }
}

extension Container {
    var arrayNumberService: Factory<ArrayNumberService> {
        Factory(self) { ArrayNumberServiceImpl() }.cached
    }
}
