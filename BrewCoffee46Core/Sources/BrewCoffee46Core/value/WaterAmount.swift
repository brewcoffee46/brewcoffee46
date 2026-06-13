/// # Water amount for 4:6 method.
public struct WaterAmount: Equatable {
    // The first and second water amounts.
    // Note that the second value can be `0.0` but the first value cannot be `0.0`.
    public let fortyPercent: (Double, Double)

    // Others water amounts (gram)
    public let sixtyPercent: NonEmptyArray<Double>

    public init(fortyPercent: (Double, Double), sixtyPercent: NonEmptyArray<Double>) {
        self.fortyPercent = fortyPercent
        self.sixtyPercent = sixtyPercent
    }
}

public func == (lhs: WaterAmount, rhs: WaterAmount) -> Bool {
    return lhs.fortyPercent == rhs.fortyPercent && lhs.sixtyPercent == rhs.sixtyPercent
}

extension WaterAmount {
    static public func defaultValue() -> WaterAmount {
        WaterAmount(
            fortyPercent: (90.0, 90.0),
            sixtyPercent: NonEmptyArray(90.0, [90.0, 90.0])
        )
    }

    // Return total amount of the water (gram).
    public func totalAmount() -> Double {
        fortyPercent.0 + fortyPercent.1
            + sixtyPercent.toArray().reduce(
                0.0,
                { (acc, v) in return acc + v }
            )
    }

    // If the second value of `fortyPercent` is `0.0` then the size of return array is `sixtyPercent + 1`,
    // the otherwise the size of that is `sixtyPercent + 2`.
    public func toArray() -> [Double] {
        if fortyPercent.1 <= 0 {
            return [fortyPercent.0] + sixtyPercent.toArray()
        } else {
            return [fortyPercent.0, fortyPercent.1] + sixtyPercent.toArray()
        }
    }
}
